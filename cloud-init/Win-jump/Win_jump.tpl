Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline; filename="setup.ps1"

####################################################################
# Join a machine into an AD Domain
###################################################################
Function Join-Ad-Domain {

    # Set DNS Server
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses "${ADDNSServer}"

    # Create credentials for domain join
    $password = ConvertTo-SecureString "${JoinUserPass}" -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ("${JoinUser}", $password)

    # Join the computer to the domain
    Add-Computer -DomainName "${DomainName}" -Credential $Cred -Force
}

# Call the Function
Join-Ad-Domain

# Add DNS Search Suffix if needed
Set-DnsClientGlobalSetting -SuffixSearchList @("${DNSSuffix}")
Restart-Computer -Delay 30
--==BOUNDARY==
