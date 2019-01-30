#requires -version 2 
<#
.SYNOPSIS
  Compare Active Directory computers to Orion.Nodes Inventory
  REQUIRES ActiveDirectory PowerShell module

.DESCRIPTION
  Run to compare AD computer names with Orion.Nodes.Caption and export deltas to text file

.INPUTS
  AD Query for Shortname (Line 42)
  AD Query for FQDN (Line 46)

.OUTPUTS
  ADcompare.txt saved in the C:\Scripts directory

.NOTES
  Version:        1.0
  Author:         Zach Mutchler
  Creation Date:  January 29th, 2015
  Purpose/Change: Initial Development  
#>

#----------------------------------------------------------------------------------------------------------------------------------------

# load the snappin if it's not already loaded
if (!(Get-PSSnapin | Where-Object { $_.Name -eq "SwisSnapin" })) {
    Add-PSSnapin "SwisSnapin"
}

# configure connection information using key/pass
$hostname = "L1Orion"
$username = "L1S\zmutchler"
$sdkKey   = "C:\Scripts\_Keys\sdk-key.txt"
$sdkPass  = "C:\Scripts\_Keys\sdk-password.txt"

# connect to swis
$password = (Get-Content $sdkPass | ConvertTo-SecureString -Key (Get-Content $sdkKey))
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$swis = Connect-Swis -host $hostname -cred $cred

# Active Directory Query
# Use this line for Shortname comparison
$adQuery = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Use this line for FQDN comparison
#$adQuery = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName

# SWIS query for the 'Caption' column of the Nodes table
$swisQuery = Get-SwisData $swis "SELECT Caption FROM Orion.Nodes"


Compare-Object $swisQuery $adQuery | Where-Object { $_.SideIndicator -eq '=>' } | Format-Table InputObject -HideTableHeaders | Out-File C:\Scripts\ADcompare.txt -Force