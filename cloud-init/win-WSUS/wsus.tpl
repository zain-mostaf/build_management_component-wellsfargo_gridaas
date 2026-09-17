Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline; filename="setup.ps1"
#########################################################

# Configurable Variables
$Activition_key = $Activition_key
$proxyEnabled = $false
$wsusContentDir = "C:\WSUS"
$wsusServerIP = (Test-Connection -ComputerName (hostname) -Count 1).IPv4Address.IPAddressToString
$wsusServerURL = "http://$wsusServerIP:8530"
$language = "en"
$targetGroupName = "Servers"
# Install WSUS and Management Tools
Write-Output "Starting to Activition WSUS Server"
slmgr.vbs /ipk $Activition_key
slmgr.vbs /ato
Write-Output "Installing WSUS features..."
try {
    Install-WindowsFeature -Name UpdateServices,UpdateServices-RSAT -IncludeManagementTools -ErrorAction Stop
    Write-Output "WSUS Role and Management Tools Installed Successfully."
} catch {
    Write-Output "Failed to install WSUS Role: $_"
    exit
}
# Create WSUS content directory
try {
    if (!(Test-Path -Path $wsusContentDir)) {
        New-Item -Path $wsusContentDir -ItemType Directory -ErrorAction Stop
    }
    & 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=$wsusContentDir
    Write-Output "WSUS post-installation completed successfully."
} catch {
    Write-Output "Failed during WSUS post-installation: $_"
    exit
}
# Configure WSUS settings
try {
    $wsus = Get-WSUSServer
    $wsusConfig = $wsus.GetConfiguration()
    # Configure Synchronization Source
    Set-WsusServerSynchronization -SyncFromMU
    # Set Language Settings
    $wsusConfig.AllUpdateLanguagesEnabled = $false
    $wsusConfig.SetEnabledUpdateLanguages($language)
    $wsusConfig.Save()
    # Set Targeting Mode
    $wsusConfig.TargetingMode = 'Client'
    $wsusConfig.OobeInitialized = $true
    Start-Sleep -Seconds 5
    $wsusConfig.Save()

    Write-Output "WSUS Configuration completed successfully."
} catch {
    Write-Output "Error during WSUS configuration: $_"
    exit
}
# Set Product and Classification Filters
try {
    # Enable only Windows Server 2019 and 2022 updates
    Get-WsusProduct | Where-Object { $_.Product.Title -ne "Windows Server 2019" -and $_.Product.Title -ne "Windows Server 2022" } | Set-WsusProduct -Disable
    Get-WsusProduct | Where-Object { $_.Product.Title -eq "Windows Server 2019" -or $_.Product.Title -eq "Windows Server 2022" } | Set-WsusProduct
    # Enable specific update classifications
    Get-WsusClassification | Where-Object { $_.Classification.Title -notin 'Update Rollups', 'Security Updates', 'Critical Updates', 'Updates', 'Service Packs' } | Set-WsusClassification -Disable
    Get-WsusClassification | Where-Object { $_.Classification.Title -in 'Update Rollups', 'Security Updates', 'Critical Updates', 'Updates', 'Service Packs' } | Set-WsusClassification
    Write-Output "Product and Classification Filters set successfully."
} catch {
    Write-Output "Failed to set product and classification filters: $_"
}
# Start WSUS synchronization
try {
    $subscription = $wsus.GetSubscription()
    $subscription.StartSynchronization()
    # Wait for WSUS Synchronization to Complete
    while ($subscription.GetSynchronizationStatus() -eq "Running") {
        Write-Output "WSUS Synchronization in progress... Please wait."
        Start-Sleep -Seconds 30
    }
    Write-Output "WSUS Synchronization completed."
} catch {
    Write-Output "Failed to start full synchronization: $_"
}
# Create WSUS target groups and approve updates
try {
    $wsus.CreateComputerTargetGroup($targetGroupName)
    $group = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq $targetGroupName }
    $wsus.CreateComputerTargetGroup("General", $group)
    # Approve updates for the "Servers" target group
    Get-WsusUpdate | Select-Object -Skip 30 -First 1 | Approve-WsusUpdate -Action Install -TargetGroupName $targetGroupName
    Write-Output "Update approved for target group: $targetGroupName."
} catch {
    Write-Output "Failed to create target groups or approve updates: $_"
}
# Fix WSUS App Pool Recycling
try {
    Import-Module WebAdministration
    Set-ItemProperty IIS:\AppPools\WsusPool -Name recycling.periodicrestart.privateMemory -Value 2100000
    $time = New-TimeSpan -Hours 4
    Set-ItemProperty IIS:\AppPools\WsusPool -Name recycling.periodicrestart.time -Value $time
    Restart-WebAppPool -Name WsusPool
    Write-Output "WSUS App Pool recycling configuration set successfully."
} catch {
    Write-Output "Failed to configure WSUS App Pool recycling: $_"
}
# Install WSUS Reporting Components
try {
    Install-WindowsFeature NET-Framework-Core -Source D:\sources\sxs -ErrorAction Stop
    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\2012.msi', '/qn', '/norestart' -Wait
    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i "C:\ReportViewer 2012.msi"', '/qn', '/norestart', 'ALLUSERS=2' -Wait
    Write-Output "WSUS Reporting components installed successfully."
} catch {
    Write-Output "Failed to install reporting components: $_"
}
Write-Output "WSUS installation, configuration, and reporting setup completed successfully."

--==BOUNDARY==