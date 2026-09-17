#!/bin/bash
set -x

############################################
# Function to install required dependencies
############################################
function install_dependencies {
  echo "Installing required dependencies..."
  dnf install oddjob oddjob-mkhomedir psmisc ansible sssd -y

}
#########################################
# Function to enable and update mkhomedir
#########################################
function enable_mkhomedir {
  echo "Configuring system to enable automatic home directory creation..."
  authconfig --enablemkhomedir --update
}

#############################################
#  Enable SSH Password Authentication
#############################################
function configure_ssh_password_auth {
  local ssh_config="/etc/ssh/sshd_config"
  echo "Configuring SSH password authentication..."

  # Remove existing 'PasswordAuthentication no' line
  sed -i '/^PasswordAuthentication no$/d' "$ssh_config"

  # Add or uncomment 'PasswordAuthentication yes'
  if grep -qE '^\#*\s*PasswordAuthentication yes' "$ssh_config"; then
    sed -i 's/^\#*\s*PasswordAuthentication yes/PasswordAuthentication yes/' "$ssh_config"
  else
    echo "PasswordAuthentication yes" >> "$ssh_config"
  fi

  # Restart SSHD
  echo "Restarting SSHD..."
  systemctl restart sshd || { echo "Failed to restart SSHD"; exit 1; }
}

#######################################
# Enable SSSD authentication
#######################################
function enable_sssd_auth {
  echo "Enabling SSSD authentication..."
  authconfig --enablesssd --update || { echo "Failed to configure SSSD authentication"; exit 1; }
}

#############################################
# Create directory for LDAP server public key
##############################################
function create_ldap_cert_dir {
  local cert_dir="/etc/openldap/certs"
  echo "Creating directory for LDAP server public key..."

  mkdir -p "$cert_dir"
  chmod 600 "$cert_dir"
}
########################################
# Copy LDAP server public key
######################################
function copy_ldap_cert  {
  local base64_input=$1
  local output_path="/tmp/cert.zip"
  local unzip_dir="/tmp/unzipped"
  local dest_cert="/etc/openldap/certs/server_cert.pem"
  local src_cert="/tmp/unzipped/server_cert.pem"
  local src_conf="/tmp/unzipped/sssd.conf"
  local dest_conf="/etc/sssd/sssd.conf"
  echo "$base64_input" | base64 -d > "$output_path"

  if ! command -v unzip &> /dev/null; then
    yum install -y unzip
  fi
  
  if [[ -n "$unzip_dir" ]]; then
    unzip "$output_path" -d "$unzip_dir"
  fi
  
  echo "Copying LDAP server public key..."

  cp "$src_cert" "$dest_cert" || { echo "Failed to copy LDAP server public key"; exit 1; }
  chmod 600 "$dest_cert"
  
  echo "Copying SSSD configuration file..."

  cp "$src_conf" "$dest_conf" || { echo "Failed to copy SSSD configuration file"; exit 1; }
  chmod 600 "$dest_conf"

  rm -rf $unzip_dir $output_path
}

######################
# Restart SSSD service
######################
function restart_sssd {
  echo "Restarting SSSD service..."
  systemctl restart sssd || { echo "Failed to restart SSSD"; exit 1; }
}

###################################################
# Function to create and mount the data volume
###################################################
function mount_data_volume {
    found=0
    fstype="ext4"
    SHARED="/var/log" 
    while [ $found -eq 0 ]; do
        for vdx in `lsblk -d -n --output NAME`; do
            desc=$(file -s /dev/$vdx | grep ': data$' | cut -d : -f1)
            if [ "$desc" != "" ]; then
                mkfs -t $fstype $desc
                uuid=`blkid -s UUID -o value $desc`
                echo "UUID=$uuid $SHARED $fstype defaults,noatime 0 0" >> /etc/fstab
                mkdir -p $SHARED
                mount $SHARED
                if [ $? -eq 0 ]; then
                  echo "mount /var/log completed" 
                else
                  echo "mount /var/log failed"
                fi
                chmod 0755 -R  $SHARED
                found=1
                break
            fi
        done
        sleep 5s
    done
}

###########
# Variables
###########
base64_zip="${base64_zip}"

########################################
# Main function to orchestrate the tasks
########################################
install_dependencies
enable_mkhomedir
configure_ssh_password_auth
enable_sssd_auth
create_ldap_cert_dir
copy_ldap_cert "$base64_zip"
restart_sssd
mount_data_volume
reboot