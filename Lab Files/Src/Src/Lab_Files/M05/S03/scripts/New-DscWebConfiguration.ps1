#requires -version 5.1
#requires -RunAsAdministrator
#requires -Module Az

Using Namespace System.Net

<#
.SYNOPSIS
Create a storage account as a staging area for web content package.

.DESCRIPTION
This script will upload website content to an existing storage account conteiner and retrieve the storage account keys that will be used as parameters for building a web server using Azure Automation DSC.

PRE-REQUISITES:

1. If you already have the Az modules installed, you may still encounter the following error:
    The script 'New-DscWebConfiguration.ps1' cannot be run because the following modules that are specified by the "#requires" statements of the script are missing: Az.
    At line:0 char:0
To resolve, please run the following command to import the Az modules into your current session.
Import-Module -Name Az -Verbose

.PARAMETER StorageAccountContainer
This is the storage account container name where web content package will be uploaded to and referenced during the configuration of the web server.
The default value of "websitedata" will be assigned for this parameter.

.PARAMETER DownloadFileName
This parameter represents the current directory from where this script executes.

.EXAMPLE [Use default values for the StorageAccountContainer ("websitedata") and DownloadFileName ("SimpleWebsite.zip") parameters]
.\New-DscWebConfiguration.ps1

.EXAMPLE [Use custom values for the StorageAccountContainer and DownloadFileName parameters]
.\New-DscWebConfiguration.ps1 -StorageAccountContainer <StorageAccountContainer> -DownloadFileName <DownloadFileName>

.INPUTS
None

.OUTPUTS
The outputs generated from this script includes:
1. A transcript log file to provide the full details of script execution. It will use the name format: New-DscWebConfiguration-TRANSCRIPT-<Date-Time>.log

.NOTES
LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.
.LINK

.COMPONENT
Azure Infrastructure, PowerShell, Storage Account

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Retrieves Azure storage resources information to upload DSC artifacts to build a simple web site.
#>

<#
    RELEASE NOTES
#>

Param (
    [string] $StorageContainerName = "websitedata",
    [string] $DownloadFileName = "SimpleWebsite.zip"
) # end param

$ErrorActionPreference = 'Stop'
# Set-StrictMode -Version Latest

#region Environment setup
# Use TLS 1.2 to support Nuget provider
Write-Output "Configuring security protocol to use TLS 1.2 for Nuget support when installing modules." -Verbose
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
#endregion

#region FUNCTIONS
function script:New-Header
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$label,
        [Parameter(Mandatory = $true)]
        [int]$charCount
    ) # end param

    $script:header = @{
        # Draw double line
        SeparatorDouble = ("=" * $charCount)
        Title           = ("$label :" + " $(Get-Date)")
        # Draw single line
        SeparatorSingle = ("-" * $charCount)
    } # end hashtable
} # end function

function New-LogFiles
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogDirectory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPrefix
    ) # end param

    # Get curent date and time
    $TimeStamp = (get-date -format u).Substring(0, 16)
    $TimeStamp = $TimeStamp.Replace(" ", "-")
    $TimeStamp = $TimeStamp.Replace(":", "")

    # Construct transcript file full path
    $TranscriptFile = "$LogPrefix-TRANSCRIPT" + $TimeStamp + ".log"
    $script:Transcript = Join-Path -Path $LogDirectory -ChildPath $TranscriptFile

    # Create log and transcript files
    New-Item -Path $Transcript -ItemType File -ErrorAction SilentlyContinue
} # end function
function Get-PSGalleryModule
{
	[CmdletBinding(PositionalBinding = $false)]
	Param
	(
		# Required modules
		[Parameter(Mandatory = $true,
				   HelpMessage = "Please enter the PowerShellGallery.com modules required for this script",
				   ValueFromPipeline = $true,
				   Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$ModulesToInstall
	) #end param

    # NOTE: The newest version of the PowerShellGet module can be found at: https://github.com/PowerShell/PowerShellGet/releases
    # 1. Always ensure that you have the latest version

	$Repository = "PSGallery"
	Set-PSRepository -Name $Repository -InstallationPolicy Trusted
	Install-PackageProvider -Name Nuget -ForceBootstrap -Force
	foreach ($Module in $ModulesToInstall)
	{
        if (Get-InstalledModule -Name $Module)
        {
            # If module exists, update it
            [string]$currentVersion = (Find-Module -Name $Module).Version
            [string]$installedVersion = (Get-InstalledModule -Name $Module).Version
            If ($currentVersion -ne $installedVersion)
            {
                # Update modules if required
                Update-Module -Name $Module -Force -ErrorAction SilentlyContinue -Verbose
            } # end if
        } # end if
	    # If the modules aren't already loaded, install and import it
		else
		{
			Install-Module -Name $Module -Repository $Repository -Force -Verbose
			Import-Module -Name $Module -Verbose
		} #end If
	} #end foreach
} #end function

#endregion FUNCTIONS

#region INITIALIZE VALUES
$storageAccountKey = $null
$storageAccountName = $null
$resourceGroupName = $null

# Create Log file
[string]$Transcript = $null

$scriptName = $MyInvocation.MyCommand.name
# Use script filename without exension as a log prefix
$LogPrefix = $scriptName.Split(".")[0]
$modulePath = (Get-InstalledModule -Name Az).InstalledLocation | Split-Path -Parent | Split-Path -Parent

$LogDirectory = Join-Path $modulePath -ChildPath $LogPrefix -Verbose
# Create log directory if not already present
If (-not(Test-Path -Path $LogDirectory))
{
    New-Item -Path $LogDirectory -ItemType Directory -Verbose
} # end if

# funciton: Create log files for transcript
New-LogFiles -LogDirectory $LogDirectory -LogPrefix $LogPrefix -Verbose

Start-Transcript -Path $Transcript -IncludeInvocationHeader -Verbose

# funciton: Create new header
$label = "UPLOAD WEBSITE CONTENTE"
New-Header -label $label -charCount 100 -Verbose

#endregion INITIALIZE VALUES

Write-Output $header.SeparatorDouble  -Verbose
Write-Output $Header.Title  -Verbose
Write-Output $header.SeparatorSingle  -Verbose

#endregion

# Set script path
Write-Output "Changing path to script directory..." -Verbose
Set-Location -Path $PSScriptRoot -Verbose
Write-Output "Current directory has been changed to script root: $PSScriptRoot" -Verbose

$ModuleToRemove = "AzureRM"
# Remove AzureRM module if present.
# This is to avoid conflicts with installing the new Az modules since it's not recommended to have both installed on the same system.
# Ref: https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.6.0
if (Get-InstalledModule -Name $ModuleToRemove -ErrorAction SilentlyContinue -Verbose)
{
    Uninstall-Module -Name $ModuleToRemove -ErrorAction SilentlyContinue -Verbose
    # TASK-ITEM: Fix error message. suppress errors
    Remove-Module -Name $ModuleToRemove -ErrorAction SilentlyContinue -Verbose
} # end if
# Get required PowerShellGallery.com modules.
Get-PSGalleryModule -ModulesToInstall "cAzureStorage","xWebAdministration"

Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."

# Authenticate to subscription

Connect-AzAccount -Environment AzureCloud

Select-AzSubscription -SubscriptionName (Get-AzSubscription).Name

# Create APP resource group
$resourceGroupName = (Get-AzResourceGroup).ResourceGroupName

$AutomationAccountName = (Get-AzAutomationAccount).AutomationAccountName

$storageAccountName = (Get-AzStorageAccount).StorageAccountName

$storageAccountResource = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

$storageAccountContext = $storageAccountResource.Context

$storageContainer = Get-AzStorageContainer -Context (Get-AzStorageAccount).Context | Where-Object {$_.Name -eq 'websitedata' }

$SourcePath = (Resolve-Path -path ".\$DownloadFileName").Path
# Copy files to storage account
# From local storage staging area to the storage account container
Set-AzStorageBlobContent -File $SourcePath -Blob $DownloadFileName -Container $storageContainer.Name -Context $StorageAccountContext -Force
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value

$vm = Get-AzVm | Where-Object { $_.Name -match 'WES01' }

# Find local machine's public IP address
$localMachinePublicIP = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip

$fqdnEndPoint = (Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName | Where-Object {$_.Name -match "$($vm.name)"}).DnsSettings.fqdn

# Resource group and log files cleanup messages
Write-Output ""
Write-Output "SUMMARY"
Get-AzResourceGroup -Name "*iac-lod*" -Verbose
Write-Output ""
Write-Output "Storage Account Key: $storageAccountKey" -Verbose
Write-Output "Storage Account Name: $storageAccountName" -Verbose
Write-Output "Download File Name: $DownloadFileName" -Verbose
Write-Output "Storage Account Container: $StorageContainerName" -Verbose
Write-Output ""
Write-Output "Automation Account Name: $AutomationAccountName" -Verbose
Write-Output ""
Write-Output "VM INFO"
Write-Output "NAME: $($vm.Name)"
Write-Output "FQDN: $fqdnEndpoint"
Write-Output "Local machine public IP: $localMachinePublicIP"
Write-Output ""

# To remove the resource groups, use the command below:
# Get-AzResourceGroup -Name "*iac-lod*" | ForEach-Object { Remove-AzResourceGroup -ResourceGroupName $_.ResourceGroupName -Verbose -Force }

Write-Warning "Transcript logs are hosted in the directory: $LogDirectory to allow access for multiple users on this machine for diagnostic or auditing purposes."
Write-Warning "To examine, archive or remove old log files to recover storage space, run this command to open the log files location: Start-Process -FilePath $LogDirectory"

Stop-Transcript -Verbose

# Create prompt and response objects for continuing script and opening logs.
$openTranscriptResponse = $null
$openTranscriptPrompt = "Would you like to open the transcript log now ? [YES/NO]"
Do
{
    $openTranscriptResponse = read-host $openTranscriptPrompt
    $openTranscriptResponse = $openTranscriptResponse.ToUpper()
} # end do
Until ($openTranscriptResponse -eq "Y" -OR $openTranscriptResponse -eq "YES" -OR $openTranscriptResponse -eq "N" -OR $openTranscriptResponse -eq "NO")

# Exit if user does not want to continue
If ($openTranscriptResponse -in 'Y', 'YES')
{
    Start-Process -FilePath notepad.exe $Transcript -Verbose
    # Invoke-Item -Path $resultsPathCsv -Verbose
} #end condition
else
{
    # Terminate script
    Write-Output "End of Script!"
    New-Header -label $label -charCount 200 -Verbose
} # end else