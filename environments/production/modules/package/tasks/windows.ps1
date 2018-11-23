[CmdletBinding()]
param(
  # NOTE: init.json cannot yet be shared, so must have windows.json / windows.ps1
  [Parameter(Mandatory = $true)]
  [String]
  $Name,

  [Parameter(Mandatory = $true)]
  [ValidateSet('install', 'uninstall', 'upgrade')]
  [String]
  $Action,

  [Parameter(Mandatory = $false)]
  [String]
  $Version
)

function Invoke-PackageAction($Package, $Action, $Version)
{
  $commandLine = "choco $Action $Package -y"
  if (([string]::IsNullOrEmpty($Version) -eq $false) -and (($Action -eq "install") -or ($Action -eq "upgrade")))
  {
      $commandLine += " --version $Version"
  }

  $cmdOutput = cmd /c "$commandLine 2>&1"
  if ($LastExitCode -eq 0) {
    return
  }

  throw "$cmdOutput"
}

try
{
  $status = Invoke-PackageAction -Package $Name -Action $Action -Version $Version

  # TODO: could use ConvertTo-Json, but that requires PS3
  # if embedding in literal, should make sure Name / Status doesn't need escaping
  Write-Host @"
  {
    "status"      : "success",
    "name"        : "$Name",
    "action"      : "$Action"
  }
"@
}
catch
{
  Write-Host @"
  {
    "status"  : "failure",
    "name"    : "$Name",
    "action"  : "$Action",
    "_error"  : {
      "msg" : "Unable to perform '$Action' on '$Name': $($_.Exception.Message)",
      "kind": "powershell_error",
      "details" : {}
    }
  }
"@
}