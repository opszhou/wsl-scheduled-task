# 设置Power shell脚本执行策略
Set-ExecutionPolicy -ExecutionPolicy Bypass

$taskname = "Windows Subsystem for Linux 2 (WSL2)"
$description = "Windows Subsystem for Linux 2 (WSL2) -- Start services on WSL2 after windows startup"
$action_args = "-WindowStyle Hidden -ExecutionPolicy Bypass $PSScriptRoot\InvokeWSLScript.ps1"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $action_args
$trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay (New-TimeSpan -minutes 1)
$principal = New-ScheduledTaskPrincipal -GroupId "Administrators" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -TaskName $taskname -Description $description -Action $action -Trigger $trigger -Settings $settings -Principal $principal
