##If to create an elevated instance, current folder passed as param
param($location)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
	$args = $PSScriptRoot
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$args`"" -Verb RunAs; exit 
}
function Is-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}
function GetStartup
{
	$common = $ENV:UserProfile + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
	$common
}
function GetProgramFiles
{
	$common = $ENV:ProgramFiles + "\AutoHotkey"
	$common
}
function GetNIRInstall
{
	$common = $ENV:ProgramFiles + "\NIRCMD"
	$common
}
Add-Type -AssemblyName PresentationFramework
$msgBoxInput =  [System.Windows.MessageBox]::Show('This will install autohotkey and its macros?','CUSTOM INSTALLER AUTOHOTKEY AND MACROS','YesNo','Error')
switch  ($msgBoxInput) {

  'Yes' {
  
	##Run INSTALLER
	$installed = 0
	DO{
		echo "Run installer of AutoHotkey..."
		$process = start-process ($location + "\AutoHotkey_1.1.29.01_setup.exe") -PassThru -Wait
		Start-Sleep 2
		echo "Check if installed"
		$program = GetProgramFiles
		if(Test-Path $program -PathType Container) { 
			$program = $program + "\*"
			if(Test-Path -Path $program) {
				write-host "Installed correctly"
				$installed = 1
			} else {
				write-host "Directory Empty"
				write-host "--Please Reinstall--"
			}
		} else {
			write-host "--Please reinstall--"
		}
	}
	UNTIL ($installed -eq 1)
	Start-Sleep 2
	
	
	##Get Program Files Path
	$path = GetNIRInstall
	if(!(Test-Path $path -PathType Container)){
		##Create Folder
		New-Item -ItemType directory -Path $path
	}
	##Copy NIRCMD files
	write-host "Copying files to NIRCMD folder"
	Copy-Item  -Path ($location + "\nircmd-x64\nircmd.exe") -Destination $path -Recurse -force
	Copy-Item  -Path ($location + "\nircmd-x64\nircmdc.exe") -Destination $path -Recurse -force
	
	Start-Sleep 3
	
	##Set Enviroment variable
	$oldpath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).path
	
	write-host "Checking enviromental variable"
	if(!($oldpath.Contains($path))){
		write-host "Adding path to enviromental variable"
		$newpath = $oldpath + ";" + $path
		Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $newpath
	}
	write-host "...enviromental path ok"
	
	
	##Get Statup Path
	$path = GetStartup
	
	
	##Copy AHK files
	write-host "Copying files to startup folder"
	Copy-Item  -Path ($location + "\Audio.ahk") -Destination $path -Recurse -force
	$path = $path + "\Audio.ahk"
	##start-process $path
	Start-Sleep 2
	write-host "Succesufull"
	
	echo "Exiting app"
	Start-Sleep 5
	exit
  }

  'No' {
  
	echo "Exiting app"
	Start-Sleep 5
	exit
  }
}
Read-Host "Press Enter to continue..." | Out-Null
exit