Configuration DeployWebsite
{
    param(
        [parameter(Mandatory=$true)]
        [string]$downloadFileName,
        [parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        [parameter(Mandatory=$true)]
        [string]$StorageAccountContainer,
        [parameter(Mandatory=$true)]
        [string]$StorageAccountKey
    ) # end param

    # Each Import-DscResource command must be entered ona separate line. See https://github.com/PowerShell/PSDscResources/issues/43
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cAzureStorage
    Import-DscResource -ModuleName xWebAdministration

    Node "localhost"
    {
        $outputPath = "C:\Lab_Files\M05\S03\Website"
        # Get web content from Azure blob storage container
        cAzureStorage DownloadWebsiteZip
        {
            Path = $outputPath
            StorageAccountName = $StorageAccountName
            StorageAccountContainer = $StorageAccountContainer
            StorageAccountKey = $StorageAccountKey
            Blob = $downloadFileName
        } # end resource

        # Get web content and extract it to destination directory
        Archive UnzipWebsiteFiles
        {
            Ensure = "Present"
            Path = "$($outputPath)\$($downloadFileName)"
            Destination = $outputPath
            DependsOn = "[cAzureStorage]DownloadWebsiteZip"
        } # end resource

        # Install IIS
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
            DependsOn = "[Archive]UnzipWebsitefiles"
        } # end resource

        # Install ASP .NET 4.5
        WindowsFeature AspNet45
        {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
            DependsOn = "[Archive]UnzipWebsiteFiles"
        } # end resource

        # Stop the default web site so it doesn't interfere with the custom web site using the same port
        xWebsite StopDefaultSite
        {
            Ensure = "Present"
            Name = "Default Web Site"
            State = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn = "[WindowsFeature]IIS"
        } # end resource

        # Deploy custom website
        xWebSite DeploySimpleWebsite
        {
            Ensure = "Present"
            Name = "DSCDemo"
            State = "Started"
            PhysicalPath = $outputPath
            DependsOn = "[xWebsite]StopDefaultSite"
        } # end resource
    } # end node
} # end configuration

# Prepare build server with repository, package provider and required modules
<#
# Setup default packagae provider and repository, install required modules and remove legacy modules
# Setup default packagae provider and repository, install required modules and remove legacy modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose
Install-PackageProvider -Name Nuget -Force -Verbose
Install-Module -Name PowerShellGet -Force -Verbose
Install-Module -Name cAzureStorage, xWebAdministration -Verbose
Uninstall-Module -Name Azure, AzureRM -Force -Verbose -ErrorAction SilentlyContinue
Remove-Module -Name Azure, AzureRM -Force -Verbose -ErrorAction SilentlyContinue
Install-Module -Name Az -Force -Verbose -AllowClobber
# Remove legacy Azure and AzureRM modules
$targetModulePath = $env:PSModulePath.Split(";") | Where-Object { $_ -match '\\WindowsPowerShell\\Modules' }
Get-ChildItem -Path $targetModulePath | Where-Object { $_.Name -match '^Azure'} | Remove-Item -Recurse -Force -Verbose
#>