# load the snappin only if it's not loaded already
if (!(Get-PSSnapin | Where-Object { $_.Name -eq "SwisSnapin" })) {
    Add-PSSnapin "SwisSnapin"
}

# get a SWIS connection, providing the hostname and credentials
$hostname = "192.168.21.55"
$username = "l1s\zmutchler"
$password = Read-Host "Password?" -AsSecureString

$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$swis = Connect-Swis -Hostname $hostname -Credential $cred

# query using the ExecuteSQL() verb from the Orion.Reporting table
$results = Invoke-SwisVerb $swis 'Orion.Reporting' 'ExecuteSQL' @('SELECT COUNT(1) Qty FROM Nodes')

"found {0} nodes" -f ($results).InnerText

<# output
found 69 nodes
#>