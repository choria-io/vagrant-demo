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
    [ValidateSet('install', 'uninstall', 'upgrade', 'status')]
    [String]
    $Action
  )
}

function Invoke-PackageAction($Package, $Action, $Version)
{

  $commandLine = "choco"

  if ($Action -eq "status")
  {
    $commandLine += " search $Package -y --exact --lo --limit-output"
  } else {
    $commandLine += " $Action $Package -y"

    if (([string]::IsNullOrEmpty($Version) -eq $false) -and (($Action -eq "install") -or ($Action -eq "upgrade")))
    {
       $commandLine += " --version $Version"
    }
  }

  $cmdOutput = cmd /c "$commandLine 2>&1"
  if ($LastExitCode -eq 0) {
    if ($Action -eq "status")
    {
      $cmdOutput = if ($cmdOutput) {$cmdOutput} else {"Uninstalled"}
    }
    return $cmdOutput
  }

  throw "$cmdOutput"
}

try
{
  ValidateParams -Action $action
  $status = Invoke-PackageAction -Package $Name -Action $Action -Version $Version

  if ($Action -eq "status")
  {
    if ($status -ne "Uninstalled")
	{
	  $info = $status.split("|")
	  $status = "Installed"
	  $version = $info[1]
	}
  }

  switch ($Action)
  {
    'install'
    {
      Write-Host @"
{
  "status"  : "Installed $Name",
  "version" : "$version"
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
    'status'
    {
      Write-Host @"
{
  "status"      : "$status",
  "old_version" : "",
  "version"     : "$version"
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
