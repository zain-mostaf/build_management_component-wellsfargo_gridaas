#!/bin/bash
set -x

###################################################
# mount data volume in /data
###################################################
function mount_data_volume {
    found=0
    fstype="ext4"
    SHARED="/var/ftp/pub" 
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
                  echo "mount /var/ftp/pub completed"
                else
                  echo "mount /var/ftp/pub failed"
                fi
                chmod 0755 -R  $SHARED
                found=1
                break
            fi
        done
        sleep 5s
    done
}


###########################################
# Function to register the VM with Red Hat
###########################################
function register_VSI {
    echo "Registering VM with Red Hat..."
    export RHEL_USER=${RHEL_USER}
    export RHEL_PASSWORD=${RHEL_PASSWORD}
    mv /etc/rhsm/rhsm.conf /etc/rhsm/rhsm.conf.sat-backup
    mv /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf
    subscription-manager remove --all
    subscription-manager unregister
    subscription-manager clean
    # Retry logic for the subscription-manager register command
    MAX_RETRIES=3
    RETRY_DELAY=5
    retry_count=0

    while ((retry_count < MAX_RETRIES)); do
        subscription-manager register --username "${RHEL_USER}" --password "${RHEL_PASSWORD}" --auto-attach
        if [[ $? -eq 0 ]]; then
            echo "Successfully registered VM with Red Hat."
            return 0
        else
            echo "Failed to register VM (attempt $((retry_count + 1))/$MAX_RETRIES)"
            ((retry_count++))
            sleep $RETRY_DELAY
        fi
    done

    echo "Failed to register VM with Red Hat after $MAX_RETRIES attempts." >&2
    return 1

}


##########################################
# Function to check available repositories
##########################################
function check_repos {
    echo "Checking available repositories..."
    yum repolist -v
}

#####################################
# Function to set the release version
#####################################
function set_release {
    echo "Setting release version to ${RHEL_VERSION}..."
    subscription-manager release --set="${RHEL_VERSION}"
}

###########################################
# Function to install and configure vsftpd
###########################################
function install_vsftpd {
    echo "Installing vsftpd..."
    yum install -y vsftpd

    echo "Enabling and starting vsftpd service..."
    systemctl enable vsftpd.service
    systemctl start vsftpd.service

    echo "Updating vsftpd configuration..."
    cat <<EOF > /etc/vsftpd/vsftpd.conf
anonymous_enable=YES
anon_root=/var/ftp/pub
local_enable=YES
write_enable=NO
local_umask=022
dirmessage_enable=NO
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
listen_ipv6=NO
pam_service_name=vsftpd
pasv_max_port=62000
pasv_min_port=42000
ftp_username=nobody
EOF

    echo "vsftpd configuration updated."
}

################################
# Function to sync repositories
################################
function sync_repos {
    echo "Syncing repositories for RHEL version ${RHEL_VERSION}..."

    if [[ "${RHEL_VERSION}" == "8.10" ]]; then

        # Sync repositories for RHEL 8.10 in parallel
        reposync --gpgcheck --repoid="rhel-8-for-x86_64-baseos-rpms" --download-metadata --download-path=/var/ftp/pub &
        reposync --gpgcheck --repoid="rhel-8-for-x86_64-appstream-rpms" --download-metadata --download-path=/var/ftp/pub &

    elif [[ "${RHEL_VERSION}" == "7.9" ]]; then
    
        # Sync repositories for RHEL 7.9 in parallel
        reposync --gpgcheck --repoid="rhel-7-server-extras-rpms" --download-metadata --download-path=/var/ftp/pub &
        reposync --gpgcheck --repoid="rhel-7-server-rpms" --download-metadata --download-path=/var/ftp/pub &

    else
        echo "Unsupported RHEL version: ${RHEL_VERSION}. Exiting."
        exit 1
    fi

    # Wait for all background tasks to complete
    wait
    echo "Repositories synced successfully."
}

###########################################
# Function to check downloaded repositories
###########################################
function check_synced_repos {
    echo "Checking downloaded repositories..."
    cd /var/ftp/pub

    if [[ "${RHEL_VERSION}" == "8.10" ]]; then
        ls -ltr /var/ftp/pub/rhel-8-for-x86_64-appstream-rpms/Packages/
        ls -ltr /var/ftp/pub/rhel-8-for-x86_64-baseos-rpms/Packages/
    elif [[ "${RHEL_VERSION}" == "7.9" ]]; then
        ls -ltr /var/ftp/pub/rhel-7-server-extras-rpms/Packages/
        ls -ltr /var/ftp/pub/rhel-7-server-rpms/Packages/
    fi
}

###############################################
# Function to set permissions for FTP directory
###############################################
function set_permissions {
    echo "Setting permissions for /var/ftp/pub..."
    chmod 0755 -R /var/ftp/pub
}

# Execute the functions in sequence
register_VSI
check_repos
set_release
install_vsftpd
mount_data_volume
sync_repos
check_synced_repos
set_permissions
