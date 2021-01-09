$RootPath = Split-Path $PSScriptRoot -Parent
$Logfile = "$RootPath\logs\wsl.log"

Function LogWrite {
  Param ([string]$logstring)

  Add-content $Logfile -value $logstring
}
Function ConvertTo-WSLPath {
  param(
    [Parameter(Mandatory = $true)]
    [String]$Path
  )

  process {
    $NPath = $Path -replace '\\', '\\'
    $WSLpath = wsl.exe wslpath -a $NPath
    return $WSLpath
  }

}

$ScriptDir = ConvertTo-WSLPath $RootPath
$WSLScript = $ScriptDir + '/wsl.sh'
wsl.exe -u root bash -c "$WSLScript" | Tee-Object -FilePath $Logfile
$wslip = $((wsl.exe hostname -I) -replace '\s', '')
[System.Environment]::SetEnvironmentVariable("wslip", "$wslip", [System.EnvironmentVariableTarget]::User)
