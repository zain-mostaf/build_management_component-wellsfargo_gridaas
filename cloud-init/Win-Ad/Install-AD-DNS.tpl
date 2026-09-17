Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline; filename="setup.ps1"

######################################################################
# Create Admin User and add it to Administrators Group
######################################################################

function Create-UserAndAddToAdminGroup {
    param (
        [string]$Username,
        [string]$Password
    )

    # Convert the password to a secure string
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Create the new user
    try {
        $NewUser = New-LocalUser -Name $Username -Password $SecurePassword  -ErrorAction Stop
        Write-Host "User $Username created successfully."
    } catch {
        Write-Host "Error creating user: $_"
        return
    }

    # Add the new user to the Administrators group
    try {
        Add-LocalGroupMember -Group "Administrators" -Member $Username -ErrorAction Stop
        Write-Host "User $Username added to the Administrators group successfully."
    } catch {
        Write-Host "Error adding user to Administrators group: $_"
    }
}

##############################################
#  Reset Administrator Password
##############################################
function Reset-AdministratorPassword {
    param (
        [string]$newPassword
    )

    # Check if the password is provided
    if (-not $newPassword) {
        Write-Host "Error: No password provided. Please specify a new password."
        return
    }

    # Convert the password to a secure string
    $securePassword = ConvertTo-SecureString $newPassword -AsPlainText -Force

    # Get the Administrator account
    $adminAccount = Get-LocalUser -Name "Administrator"

    # Check if the Administrator account exists
    if ($adminAccount) {
        # Reset the password
        $adminAccount | Set-LocalUser -Password $securePassword
        Write-Host "The Administrator password has been reset successfully."
    } else {
        Write-Host "Error: The Administrator account does not exist on this machine."
    }
}

##############################################
# Install Domain Controller and DNS 
##############################################
# Function to install Active Directory and DNS
function Install-ADAndDNS {
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
}

###########################################
# sleep function
###########################################
function Pause-Script {
    param (
        [int]$Seconds = 180  # Default pause time is set to 180 seconds
    )
    
    Write-Host "Script will pause for $Seconds seconds..."
    Start-Sleep -Seconds $Seconds
    Write-Host "Pause completed."
}

##########################################
# Decode and save ZIP file to Windows directory
##########################################
function Save-Base64Zip {
    param (
        [string]$base64String,
        [string]$destinationPath = "C:\script\postreboot.zip"
    )

    # Ensure the destination directory exists
    $destinationDir = [System.IO.Path]::GetDirectoryName($destinationPath)
    if (!(Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Force -Path $destinationDir
    }

    # Decode and save the file
    Write-Host "Saving base64 ZIP file to $destinationPath..."
    [System.IO.File]::WriteAllBytes($destinationPath, [Convert]::FromBase64String($base64String))
    Write-Host "ZIP file saved successfully."
}


##########################################
# Extract ZIP file to Windows directory
##########################################
function Extract-ZipFile {
    param (
        [string]$sourceFilePath = "C:\script\postreboot.zip",
        [string]$destinationFolderPath = "C:\script\"
    )

    # Ensure the destination directory exists
    if (!(Test-Path -Path $destinationFolderPath)) {
        New-Item -ItemType Directory -Path $destinationFolderPath | Out-Null
    }

    # Use Shell.Application COM object to extract
    Write-Host "Extracting ZIP file using Shell.Application..."
    $shell = New-Object -ComObject shell.application
    $zip = $shell.NameSpace($sourceFilePath)
    foreach ($item in $zip.Items()) {
        $shell.NameSpace($destinationFolderPath).CopyHere($item)
    }
    Write-Host "Extraction complete: $destinationFolderPath"
}

##########################################
# Function to initialize Domain Controller
###########################################
function Initialize-DomainController {
    param (
        [string]$domainPassword
    )
    
    $secureSafeModePassword = ConvertTo-SecureString $domainPassword -AsPlainText -Force

    Install-ADDSForest -DomainName "citihpc.com" -DomainNetbiosName "CITIHPC" -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" `
        -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword $secureSafeModePassword
}

########################
# Main script execution
########################
Pause-Script -Seconds 30
Create-UserAndAddToAdminGroup -Username ${AdminUserName} -Password ${AdminPassword}
Pause-Script -Seconds 30
Reset-AdministratorPassword -newPassword ${AdminPassword}
Pause-Script -Seconds 30
Save-Base64Zip -base64String "${EncodedPostRebootGZ}"
Pause-Script -Seconds 30
Extract-ZipFile
Pause-Script -Seconds 30
Install-ADAndDNS
Pause-Script -Seconds 30
Initialize-DomainController -domainPassword ${AdminPassword}
--==BOUNDARY==