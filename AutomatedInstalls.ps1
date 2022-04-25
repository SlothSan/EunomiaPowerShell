##App Automation Scripts V.01
##Install Chocolatey mmmm 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
### install standard apps. 
choco install googlechrome -y
choco install firefox -y
choco install silverlight -y
choco install dotnetfx -y
choco install 7zip -y
choco install vlc -y
choco install office365business -y /updates:"True" /eula:"True"
choco upgrade microsoft-teams.install -y 
choco install adobereader -y
choco install zotero -y 
choco install eset-antivirus -y --ignorechecksums
## Copy EUN Templates too machine
robocopy "\\eun-fs01\company\Operations\Templates\Office templates" "C:\EUN_Templates" /Mir /XA:H /W:0 /R:1 /REG

## Remove Chocolatey
##Remove-Item C:\ProgramData\chocolatey -Recurse -Force

## Install ESET Agent from .bat
Start-Process "cmd.exe"  "/c \\EUN-FS01\SoftwareDeploy\Build Installs\8) PROTECTAgentInstaller.bat"

##Remove Desktop Shortcuts
Remove-Item C:\Users\*\Desktop\*lnk –Force

##Create Shortcut for Teams
$TargetFile = "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe"
$Argument = '--processStart "Teams.exe"'
$ShortcutFile = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Teams.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $Argument
$Shortcut.Save()

##Run GPupdate /Force to apply Taskbar Settings.
Start-Process "cmd.exe" "/c Gpupdate /force"

##Force Office 365 Update 
cmd /c "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user

##Set Execution Policy back to Restricted
Set-executionpolicy Restricted

### NEED TO ADD ESET AGENT & LICENCE ESET AV WITH REG INJECTION



