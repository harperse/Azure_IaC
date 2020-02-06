# Setup default package provider and repository, install required modules and remove legacy modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose
Install-PackageProvider -Name Nuget -Force -Verbose
Install-Module -Name PowerShellGet -Force -Verbose
Install-Module -Name cAzureStorage, xWebAdministration -Verbose
Uninstall-Module -Name Azure, AzureRM -Force -Verbose -ErrorAction SilentlyContinue
Remove-Module -Name Azure, AzureRM -Force -Verbose -ErrorAction SilentlyContinue
Install-Module -Name Az -Force -Verbose -AllowClobber
# Remove legacy Azure and AzureRM modules
$targetModulePath = $env:PSModulePath.Split(";") | Where-Object { $_ -match '\\Program Files\\WindowsPowerShell\\Modules' }
Get-ChildItem -Path $targetModulePath | Where-Object { $_.Name -match '^Azure'} |
Remove-Item -Recurse -Force -Verbose -ErrorAction SilentlyContinue