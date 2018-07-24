<#	
	.DESCRIPTION
		Applies Windows 10 clean up tasks
#>

# Configuration
$RemoveQuickAccess = "true" # Remove Quick Access Icon from Navigation Pane
$Remove3d = "true" # Remove 3D Objects Icon from the Navigation Pane
$RemoveNetworkPane = "true" #Removes network icon from navigation pane
$RemoveEdgeIcon = "true" #Removes Edge Icon from Desktop
$RemoveIntelIcons = "true" # Removes Intel Tray and context Icons
$DeleteScheduledTasks = "true"
$DisableOneDrive = "true"
$DisableServices = "true"

# Remove Quick Access Icon
If ($RemoveQuickAccess -eq "true")
{
	Write-Output "Removing Quick Access Icon from the Navigation Pane";
	New-PSDrive -Name "HKLM" -PSProvider "Registry" -Root "HKEY_LOCAL_MACHINE"
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "HubMode" -PropertyType DWORD -Value 1 -Force
	Remove-PSDrive -Name "HKLM"
}

# Remove Netowork Icon from Navigation Pane
If ($RemoveNetworkPane -eq "true")
{
	Write-Output "Removing Network Icon from the Navigation Pane";
	New-PSDrive -Name "HKLM" -PSProvider "Registry" -Root "HKEY_LOCAL_MACHINE"
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -PropertyType DWORD -Value 1 -Force
	Remove-PSDrive -Name "HKLM"
}

# Remove 3d Objects Icon
If ($Remove3d -eq "true")
{
    	Write-Output "Removing 3d Objects Icon from the Navigation Pane";
	New-PSDrive -Name "HKLM" -PSProvider "Registry" -Root "HKEY_LOCAL_MACHINE"
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force
    	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force
	Remove-PSDrive -Name "HKLM"
}

# Remove Edge Icon
If ($RemoveEdgeIcon -eq "true")
{
	Write-Output "Disabling Microsoft Edge desktop icon creation"
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'Explorer' -PropertyType DWORD -Value '1' -Force
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'DisableEdgeDesktopShortcutCreation' -PropertyType DWORD -Value '1' -Force
}

# Remove Intel Tray and context icons
If ($RemoveIntelIcons -eq "true")
{
    	Write-Output "Removing Intel Icons";
	New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT"
	Remove-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\igfxcui" -Force
    	Remove-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\igfxDTCM" -Force
	Remove-PSDrive -Name "HKCR"
    	New-PSDrive -Name "HKLM" -PSProvider "Registry" -Root "HKEY_LOCAL_MACHINE"
	New-ItemProperty -Path "HKLM:\SOFTWARE\Intel\Display\igfxcui\igfxtray\TrayIcon" -Name "ShowTrayIcon" -PropertyType DWORD -Value 0 -Force
	Remove-PSDrive -Name "HKLM"
}

# Disable Scheduled Tasks
If ($DeleteScheduledTasks -eq "true")
{
	Write-Output "Disabling Scheduled Tasks"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\StartupAppTask"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsToastTask"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsUpdateTask"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyMonitor"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\WDI\ResolutionHost"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Autochk\Proxy"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Feedback\Siuf\DmClient"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
	Disable-ScheduledTask -TaskName "\Microsoft\XblGameSave\XblGameSaveTask"
    	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
    	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Workplace Join\Recovery-Check"
    	Disable-ScheduledTask -TaskName "\Microsoft\XblGameSave\XblGameSaveTask"
}

# Disable OneDrive
If ($DisableOneDrive -eq "true")
{
	Write-Output "Turning off OneDrive"
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -PropertyType DWORD -Value '1' -Force
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'PreventNetworkTrafficPreUserSignIn' -PropertyType DWORD -Value '1' -Force
}

# Disable Services
If ($DisableServices -eq "true")
{
	Write-Output "Configuring Services..."
	
	Write-Output "Disabling Microsoft Account Sign-in Assistant Service..."
	Set-Service wlidsvc -StartupType Disabled
	
	Write-Output "Disabling Windows Error Reporting Service..."
	Set-Service WerSvc -StartupType Disabled
	
	Write-Output "Disabling Xbox Live Auth Manager Service..."
	Set-Service XblAuthManager -StartupType Disabled
	
	Write-Output "Disabling Xbox Live Game Save Service..."
	Set-Service XblGameSave -StartupType Disabled
	
	Write-Output "Disabling Xbox Live Networking Service Service..."
	Set-Service XboxNetApiSvc -StartupType Disabled
	
	Write-Output "Disabling Xbox Accessory Management Service..."
	Set-Service XboxGipSvc -StartupType Disabled
}
