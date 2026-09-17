Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline; filename="setup.ps1"

######################################################

$KmsHost = (Get-ComputerInfo).CsName
Write-Host "Hostname (Get-ComputerInfo): $KmsHost"

$KmsPort = 1688                    # Default KMS port
$KmsKey = ${KmsKey}
$FirewallRuleName = "KMS Port 1688"




# Function to check if a feature is installed
function Check-Feature {

    return (Get-WindowsFeature -Name Remote-Desktop-Services).Installed
}


# Install Volume Activation feature if not already installed
if (-not (Check-Feature -FeatureName "VolumeActivation")) {
    Write-Host "Installing Volume Activation feature..."
    Install-WindowsFeature -Name "VolumeActivation" -IncludeManagementTools
}

# Set the KMS Host Key
try {
    Write-Host "Setting KMS Host Key..."
    slmgr.vbs /ipk $KmsKey
} catch {
    Write-Host "Error setting KMS Key: $_"
}

# Activate the KMS Host
try {
    Write-Host "Activating KMS Host..."
    slmgr.vbs /ato
} catch {
    Write-Host "Error activating KMS Host: $_"
}

# Configure the KMS server
try {
    Write-Host "Configuring KMS server..."
    slmgr.vbs /skms "$${KmsHost}:$KmsPort"
} catch {
    Write-Host "Error configuring KMS server: $_"
}

# Create a firewall rule to allow KMS traffic
if (-not (Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating firewall rule to allow KMS traffic..."
    New-NetFirewallRule -DisplayName $FirewallRuleName -Direction Inbound -Protocol TCP -LocalPort $KmsPort -Action Allow
} else {
    Write-Host "Firewall rule already exists."
}

# Display KMS configuration details
try {
    Write-Host "Displaying KMS configuration..."
    slmgr.vbs /dlv
} catch {
    Write-Host "Error displaying KMS configuration: $_"
}

function Get-KMSInfo {   
  try {    
        $activationInfo = slmgr.vbs /dli         
        Write-Host "KMS Activation Information:"         
        Write-Host $activationInfo
     } 
catch {    
     Write-Host "Error retrieving KMS information: $_"     
} 
} 
# Call the function

function Restart-Machine {
    # Confirm before restarting    
    
    $confirmation = Read-Host "Are you sure you want to reboot the machine? (Y/N)"        
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {        
          try { 
                 Write-Host "Rebooting the machine..."            
                 Restart-Computer -Force        
              } 
          
          catch {            
            
            Write-Host "Error while trying to reboot: $_"        
          }    
        } 
    else {        
     
        Write-Host "Reboot canceled."    
     
     }
 }

Get-KMSInfo
Write-Host "KMS setup completed. The Windows machine will be rebooted"
Restart-Machine
--==BOUNDARY==