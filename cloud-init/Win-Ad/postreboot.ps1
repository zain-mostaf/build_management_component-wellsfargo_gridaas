###################################################
# Function to start the DNS service if not running
###################################################
function Start-DNSService {
    $dnsService = Get-Service -Name "DNS" -ErrorAction SilentlyContinue
    if ($null -eq $dnsService) {
        Write-Host "DNS service is not installed."
    }
    elseif ($dnsService.Status -ne 'Running') {
        Start-Service -Name "DNS"
        Write-Host "DNS service started."
    } else {
        Write-Host "DNS service is already running."
    }
}

######################################################################
# Function to create a forward DNS zone# Function to create a DNS zone
#######################################################################

function Create-DNSZone {
    if (Get-DnsServerZone -Name $domainName -ErrorAction SilentlyContinue) {
        Write-Host "DNS zone '$domainName' already exists. Skipping creation."
    } else {
        try {
            Add-DnsServerPrimaryZone -Name $domainName -ReplicationScope "Domain" -PassThru -ErrorAction Stop
            Write-Host "Successfully created DNS zone: '$domainName'"
        }
        catch {
            Write-Host "Failed to create DNS zone for '${domainName}': $_"
        }
    }
}

##############################################
# Function to create a reverse DNS zone
##############################################
function Create-ReverseDNSZone {
    
    Write-Host "Checking for reverse DNS zone with name: $reverseZoneName"

    if (Get-DnsServerZone -Name $reverseZoneName -ErrorAction SilentlyContinue) {
        Write-Host "Reverse DNS zone '$reverseZoneName' already exists. Skipping reverse zone creation."
    } else {
        try {
            Add-DnsServerPrimaryZone -NetworkId $networkID -ReplicationScope "Domain" -PassThru -ErrorAction Stop
            Write-Host "Successfully created reverse DNS zone: '$reverseZoneName'"
        } catch {
            Write-Host "Failed to create reverse DNS zone for '${reverseZoneName}': $_"
        }
    }
}

#######################################################
# Add A/PTR record for grid manager in EQT 
#######################################################

function Add-DnsRecords {

    foreach ($server in $servers) {
        $serverName = $server.Name
        $ipAddress = $server.IP

        # Convert IP to reverse format for PTR record
        $reverseIP = ($ipAddress -split '\.')[-1] + '.' + ($ipAddress -split '\.')[2..0] -join '.'
        $reverseZoneName = ($ipAddress -split '\.')[0..2] -join '.' + ".in-addr.arpa"

        # Create A Record
        try {
            Add-DnsServerResourceRecordA -Name $serverName -ZoneName $domainName -IPv4Address $ipAddress -CreatePtr -ErrorAction Stop
            Write-Host "Successfully created A record for $serverName with IP $ipAddress"
        } catch {
            Write-Host "Failed to create A record for $serverName with IP ${ipAddress}: $_"
        }

        # Check if the reverse zone exists, then create PTR record
        if (Get-DnsServerZone -Name $reverseZoneName -ErrorAction SilentlyContinue) {
            try {
                Add-DnsServerResourceRecordPtr -Name $reverseIP -ZoneName $reverseZoneName -PtrDomainName "$serverName.$domainName" -ErrorAction Stop
                Write-Host "Successfully created PTR record for $ipAddress pointing to $serverName.$domainName"
            } catch {
                Write-Host "Failed to create PTR record for $ipAddress pointing to $serverName.${domainName}: $_"
            }
        } else {
            Write-Host "Reverse DNS zone '$reverseZoneName' does not exist for IP $ipAddress. Skipping PTR record creation."
        }
    }
}


###########################
# Define parameters
############################
$domainName = "citihpc.com"
$networkID = "172.0.0.0/8" 
$reverseZoneName = "172.in-addr.arpa"
$servers = @(
    @{ Name = "tor2eqt-gm-01"; IP = "172.16.134.120" },
    @{ Name = "tor2eqt-gm-02"; IP = "172.16.134.121" },
    @{ Name = "tor2eqt-gm-03"; IP = "172.16.134.122" },
   # @{ Name = "tor3eqt-gm-01"; IP = "172.200.200.9" },
   # @{ Name = "tor3eqt-gm-02"; IP = "172.200.200.10" },
   # @{ Name = "tor3eqt-gm-03"; IP = "172.200.200.11" },
   # @{ Name = "dal2eqt-gm-01"; IP = "172.200.232.9" },
   # @{ Name = "dal2eqt-gm-02"; IP = "172.200.232.10" },
   # @{ Name = "dal2eqt-gm-03"; IP = "172.200.232.11" },
   # @{ Name = "wdc1eqt-gm-01"; IP = "172.200.208.9" },
   # @{ Name = "wdc1eqt-gm-02"; IP = "172.200.208.10" },
   # @{ Name = "wdc1eqt-gm-03"; IP = "172.200.208.11" }
)

#################################
# Main script execution
#################################
Start-DNSService
Create-DNSZone
Create-ReverseDNSZone
Add-DnsRecords -servers $servers
