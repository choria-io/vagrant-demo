[CmdletBinding()]
param(
  # NOTE: init.json cannot yet be shared, so must have windows.json / windows.ps1
  [Parameter(Mandatory = $true)]
  [String]
  $Name,

  [Parameter(Mandatory = $false)]
  [String]
  $Action,

  [Parameter(Mandatory = $false)]
  [String]
  $Version
)

function ErrorMessage($Action, $Name, $Message)
{
  Write-Host @"
{
  "status"  : "failure",
  "_error"  : {
    "msg" : "Unable to perform '$Action' on '$Name': $Message",
    "kind": "powershell_error",
    "details" : {}
  }
}
"@  
}

# Do this outside the initial script parameters in order to control the error message
function ValidateParams
{
  param(
    [ValidateSet('install', 'uninstall', 'upgrade')]
    [String]
    $Action
  )
}

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
  ValidateParams -Action $action
  $status = Invoke-PackageAction -Package $Name -Action $Action -Version $Version

  switch ($Action)
  {
    'install'
    {
      Write-Host @"
{
  "status"  : "Installed $Name",
  "version" : ""
}
"@
    }
    'uninstall'
    {
      Write-Host @"
{
  "status"  : "Uninstalled $Name"
}
"@
    }
    'upgrade'
    {
      Write-Host @"
{
  "status"      : "Upgraded $Name",
  "old_version" : "",
  "version"     : ""
}
"@
    }
  }
}
# parameter validation with controlled output
catch [System.Management.Automation.ParameterBindingException]
{
  ErrorMessage -Action $Action -Name $Name -Message "'$Action' action not supported for windows.ps1"
}
catch
{
  ErrorMessage -Action $Action -Name $Name -Message "$($_.Exception.Message)"
}
