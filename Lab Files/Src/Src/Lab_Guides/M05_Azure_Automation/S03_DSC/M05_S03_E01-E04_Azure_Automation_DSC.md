# WorkshopPLUS - Azure: Infrastructure as Code

Module 5: Azure Automation - Section 2: Desired State Configuration (DSC)

## Exercise 1: Create a DSC Configuration

### Excercise 1: Introduction

In this lab, we will look at how to create Desired State Configuration (DSC), to
configure a Windows Server with IIS, download website source code then deploy
the website to the server. Once the configuration is applied, it will result in
a ready-to-go web server.

### Exercise 1: Scenario

In this lab, we will create a DSC Configuration File to:

- Download Website source files from Azure Storage
- Unzip Website source files on the web server
- Install IIS and ASP.Net on the Web Server
- Disable the default IIS Website
- Create a New Website based on the downloaded source files

### Excercise 1: Estimated Time to Complete This Lab

60 minutes

### Task Description

1. Pre-requisites.

   a. We will be using the VSCode PowerShell Tools extension to execute scripts in this module.
   If VSCode is not already installed on the system that you will be executing the scripts from, it can be downloaded from: [VScode](https://code.visualstudio.com/Download)

   b. You will also require the PowerShell Language Support for Visual Studio Code extension. See: [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell). For instructions on installing extensions in VSCode, see the  [Extension Gallery](https://code.visualstudio.com/docs/editor/extension-gallery) section of this user guide for details.

2. On your lab machine, from the start menu, open **Visual Studio Code** as an administrator.

3. From the Help menu in **Visual Stdudio Code**, select the **Check for Updates...** option to install the latest versions of VSCode and its extensions.

4. In **Visual Studio Code** create a new file using **[CTRL+N]** keyboard shortcut, then immediately save the current blank file by pressing **[CTRL+S]**. Save it as **C:\Lab_Files\M05\S03\E01\DeployWebsite.ps1**

 **IMPORTANT**: There is also a sample script in the **C:\Lab_Files\M05\S03\scripts** folder with the same name DeployWebsite.ps1, so please ensure that the current new file is saved in the  **C:\Lab_Files\M05\S03\E01** subfolder to avoid overwriting the sample file!

5. In order to execute PowerShell script, we must first modify the execution policy. Run the following command in the terminal pane:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Verbose
```

6. To setup the default package provider and repository, and to install the required modules and remove any legacy modules if necessary, open the following script by pressing **[CTRL+O]** and navigate to the file: **C:\Lab_Files\M05\S03\scripts\Setup-ProvidersReposAndModules.ps1**. Select this file to open it in VS Code.

7. Next, we need to execute this script in order to pass the Intellisense static checks when authoring the configuration. Execute the script by pressing F5. The script will take several minutes to run when it is executed for the first time, so you can proceed to the next steps while the script executes.

8. Switch tabs in the script editing pane to the original empty script **DeployWebsite.ps1** created in step 4.

9.  You should now be able to see the script editing pane.

    ![dsc-m05-s03-e01-ScriptEditingPane.png](dsc-m05-s03-e01-ScriptEditingPane.png)

10. Enter the following code into the Script Pane:

    ```powershell
    Configuration DeployWebsite
    {
        Node "localhost"
        {
        } # end node
    } # end configuration
    ```

11. We are creating a PowerShell DSC configuration, called DeployWebsite,
to the ```"localhost"``` machine where the configuration will later be applied.

12. The first thing we want the DSC configuration to do, is download the website
source files from an Azure Storage Account (you will upload this later ). To do
this, we are going to make use of the **cAzureStorage** DSC resource that was installed from step 7 above. You can
read more about this resource at:
<https://www.powershellgallery.com/packages/cAzureStorage.>

13. Inside of the curly brackets for the **DeployWebsite** configuration {} on the line above  ```Node "localhost"```  in your script, type in the following to import the cAzureStorage and xWebAdministration modules:

```powershell
Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName cAzureStorage
Import-DscResource -ModuleName xWebAdministration
```

14. After the curly brackets following ```Node "localhost"```, enter the following code:

```powershell
cAzureStorage DownloadWebsiteZip
{
    Path = $outputPath
    StorageAccountName = $StorageAccountName
    StorageAccountContainer = $StorageAccountContainer
    StorageAccountKey = $StorageAccountKey
    Blob = $downloadFileName
} # end resource
```

15. This block of code called **DownloadWebsiteZip** will use the cAzureStorage
resource to download a file. Notice, we have not told it which file to download
or where from. We have just created some variables, which will be set later.

16. Next, we want DSC to unzip the source files, which will be downloaded by
DownloadWebsiteZip. To do this, write in the following code, making sure you
put this **below** the closing curly bracket which closes the
DownloadWebsiteZip block, called **UnzipWebsiteFiles:**

```powershell
Archive UnzipWebsiteFiles
{
    Ensure = "Present"
    Path = "$($outputPath)\$($downloadFileName)"
    Destination = $outputPath
    DependsOn = "[cAzureStorage]DownloadWebsiteZip"
} # end resource
```

Notice how this contains the **DependsOn** property. This means that this
resource cannot be configured until the DownloadWebsiteZip resource configuration has completed. This makes sense, as we need to download the zip file, before it is unzipped.

17. Next, enter the following two blocks of DSC configuration, which will
Install IIS and ASP.Net on the Server. Be sure to enter these after the
closing curly bracket from the UnzipWebsiteFiles block:

    ```powershell
    WindowsFeature IIS
    {
        Ensure = "Present"
        Name = "Web-Server"
        DependsOn = "[Archive]UnzipWebsiteFiles"
    } # end resource

    WindowsFeature AspNet45
    {
        Ensure = "Present"
        Name = "Web-Asp-Net45"
        DependsOn = "[Archive]UnzipWebsiteFiles"
    } # end resource
    ```

18. Notice how both these actions use **DependsOn** to make sure they are configured only after the website files have been unzipped by the UnzipWebsiteFiles resource.

19. At this point we have configured DSC to download and unzip the website files, then
install IIS and ASP. Next, we want to use DSC to create a new website based
on the unzipped website source files. To configure websites, we need to make
use of a DSC resource **xWebAdministration**. You can read information about
this module:
<https://www.powershellgallery.com/packages/xWebAdministration/.>

20. Next, enter the following configuration blocks to create a new site and
    stop the default IIS website. Put these blocks below the closing curly
    bracket of the **AspNet45** block:

```powershell
xWebsite StopDefaultSite
{
    Ensure = "Present"
    Name = "Default Web Site"
    State = "Stopped"
    PhysicalPath = "C:\inetpub\wwwroot"
    DependsOn = "[WindowsFeature]IIS"
} # end resource

xWebsite DeploySimpleWebsite
{
    Ensure          = "Present"
    Name            = "DSCDemo"
    State           = "Started"
    PhysicalPath    = $outputPath
    DependsOn       = "[xWebsite]StopDefaultSite"
} # end resource
```

21. **IMPORTANT!** You may have noticed that there is a variable in the configuration named
\$outputPath. This is the directory where the Website source files are
unzipped to and used to create the new IIS site. We need to set a location
in the script. To do this, write in the following line **above** the
**DownloadWebsiteZip** configuration block (but under Node ```"localhost"```):

```powershell
$outputPath = "C:\Lab_Files\M05\S03\Website"
```

22. As we discussed earlier, the **DownloadWebsiteZip** configuration block
    requires some input, to configure where to download the website files from.
    To set these, we will configure input parameters for the DSC configuration.
    We want to enter this code after the opening the curly bracket for **Configuration DeployWebsite**

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$downloadFileName,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountContainer,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountKey
)
```

23. The completed script should look like this:

```powershell
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
```

24. Re-save your code to **C:\Lab_Files\M05_Azure_Automation\S02_DSC\E01\DeployWebsite.ps1**

25. It\'s highly recommended that you check your code to ensure it\'s correct.
**Visual Studio Code** has an excellent compare feature if you would like to try it. You will
find a complete example in your lab files at
**C:\Lab_Files\M05_Azure_Automation\S02_DSC\DeployWebsite.ps1**

# WorkshopPLUS - Azure: Infrastructure as Code

Module 5: Azure Automation - Section 2: Desired State Configuration (DSC)

## Exercise 2: Upload Website Files to Azure Storage

### Exercise 2: Introduction

The DSC Configuration you created in the previous exercise will securely download the Contoso
website source code and install it on a Web Server. For this Exercise, all required resources have already been pre-provisioned using an ARM template during the lab setup phase for the virtual machine.

The resources deployed includes:

1 x Automation account

1 x Storage account with a container named "websitedata"

1 x Standard_A1_v2 Virtual Machine that will be configured as a web server with 1 operating systems managed disk.

1 x NIC for the VM

1 x Public IP for the VM

1 x Virtual Network

You will use the PowerShell script **New-DscWebConfiguration.ps1** to upload the website source code to the pre-provisioned storage account container. This will be the source URL used by the DSC configuration script **DeployWebsite.ps1** to deploy the website.

### Exercise 2: Scenario

In this lab, we will:

- Execute a PowerShell script to upload the website content to a container in the provisioned storage account.
- The script will also record and display all the required information for the DSC script to deploy the website. This information includes the storage account key, storage account name, container and the web content file name.

### Exercise 2: Estimated Time to Complete This Lab

30 minutes

### Exercise 2: Task Description

1. From your workstation, if you haven't already done so, open an instance of **Visual Studio Code** as administrator.

2. Open the script **C:\Lab_Files\M05\S03\scripts\New-DscWebConfiguration.ps1**

3. Change the directory to the sript path, import the Az modules and and execute the script using the following commands.

   ```powershell
   # Change directory to script path
   Set-Location -Path C:\Lab_Files\M05\S03\scripts -Verbose
   # Import the Az modules
   Import-Module -Name Az -Verbose
   # Execute the script
   .\New-DscWebConfiguration.ps1
   ```

4. After a few seconds you will be prompted to authenticate to your Azure subscription with the following message:

    **Please see the open dialogue box in your browser to authenticate to your Azure subscription...**

   To see your Azure subscription username and password, select the **Resources** tab on the right navigation pane of the lab VM.

   Minimize VS Code to see your sign-in dialog box.

   Press the **T** symbols from the **Resources** tab to type in your **Username** and **Password** to log in.

    ![Enter-AzureCredentials](dsc-m05-s03-e02-Enter-AzureCredentials.png)

   Maximize VS Code to continue.

6. The script will take approximatly 2-3 minutes to retrieve the appropriate information from the Azure resources.

   After the script completes, the following information will be displayed in the console:

    * Storage Account Key: (Storage Account key)
    * Storage Account Name: (Storage account name)
    * Download File Name: (SimpleWebsite.zip)
    * Storage Container Name: (websitedata)

    * Automation Account Name: (IAC-DSC-NP-(storage account name)-AAA-01)

    * Virtual Machine Name: (IACDSCNPWES01)
    * Virtual Machine FQDN: (dns+(storage account name).eastus.cloudapp.azure.com)
    * Local machine public IP: aaa.bbb.ccc.ddd (In case you want to use Just in Time access for RDP)

7. The credentials for the username are shown in the resources tab of the lab navigation pane, which is **azure-admin** and the password (not shown in the resources tab) is **Fun!nTh3Cloud**, but this Virtual Machine does not yet have a network security group, and it will not be necessary to RDP to this server anyway. A network security group will still be required however to allow http traffic inbound to the VM.

    **NOTE: This DSC node is a Windows Server 2016 Core edition, so it does not have a GUI interface.**

    ![dsc-m05-s03-e02-Open-TranscriptLogNow.png](dsc-m05-s03-e02-Open-TranscriptLogNow.png)

8.  A prompt asking to open the log files will also appear as:
   Would you like to open the transcript log now ? [YES/NO]:

9. Type "yes" to open the transcript and scroll to the end where the information shown in step 6 is available in the transcript.

10. From your workstation, open the Azure Portal at [Azure Portal](http://portal.azure.com)

11. In the top left corner of the Azure portal, click this ```>>``` to expand out the left panel. From the panel click **All Services**. Search for **Storage Accounts**.  Click **Storage Accounts**.

   ![Expand Services](dsc-ExpandServices.png)

   ![Open Storage Accounts](dsc-OpenStorageAccounts.png)

12. From the **Storage accounts** pane, click Refresh. You should now see the storage account and be able to select it.

13. Once you have clicked on the Storage Account, from the many options on the left, under **BLOB SERVICE** click **Blobs**.

14. Click the new **websitedata** container.

15. You should see that the **SimpleWebsite.zip** file was uploaded successfully by the script.

16. You can also view the contents of the deployed resource group **iac-lod#######**, which should look similar to the image below:

![dsc-m05-s03-e02-List-AzureResources.png](dsc-m05-s03-e02-List-AzureResources.png)

17. To create a network security group, launch the cloud shell in bash mode and execute the commands below:
*NOTE, you may have to select advanced settings and create a new share. Specify "cloudshell" for the share name*

```bash
# Get current resource group name
rg=$(az group list --query "[].name" -o tsv)
# Get the location of the resource group
location=$(az group list --query "[].location" -o tsv)
# Set the NSG name
nsg="IAC-DSC-NP-NSG-01"
# Set NSG rule name
ruleName="allowHttpInbound"
# create a network security group
az network nsg create --name $nsg --resource-group $rg --location $location
# Create inbound http rule
az network nsg rule create --name $ruleName --nsg-name $nsg --priority 100 --resource-group $rg --protocol Tcp --source-port-ranges '*' --destination-port-ranges 80 --source-address-prefixes Internet \
--destination-address-prefixes VirtualNetwork --direction Inbound --access Allow --description http
# Get vnet
vnet=$(az network vnet list --resource-group $rg --query "[].name" -o tsv)
# Get subnet
subnet=$(az network vnet subnet list -g $rg --vnet-name $vnet --query "[].name" -o tsv)
# Associate nsg with subnet
az network vnet subnet update --name $subnet --g $rg --vnet-name $vnet --network-security-group $nsg
```

18. Keep the transcript open to refer to the storage account name and the access key for the next exercise.

# WorkshopPLUS - Azure: Infrastructure as Code

Module 5: Azure Automation - Section 2: Desired State Configuration (DSC)

## Exercise 3: Create DSC Node Configuration

### Exercise 3: Introduction

Now that you've created your DSC Configuration, we will upload and compile
this into a DSC Node Configuration in DSC. This needs to be completed before the
DSC configuration can be applied to a server.

### Exercise 3: Scenario

In this lab, we will:

- Upload DSC Configuration to Azure Automation
- Import DSC Resources into Azure Automation Assets
- Compile DSC Configuration into a DSC node Configuration

### Exercise 3: Estimated Time to Complete This Lab

30 minutes

### Exercise 3: Task Description

1. From your workstation, open the Azure Portal at <http://portal.azure.com/>

2. In the Azure Portal, navigate to your Automation Account **IAC-DSC-NP-#############-AAA-01**.

3. From the menu pane in your ContosoAutomationAccount, click **State configuration (DSC)**
under **CONFIGURATION MANAGEMENT**

4. From DSC Configurations, select the **Configurations** tab and click the plus sign **+** to add a configuraiton

5. Upload the **DeployWebsite.ps1** file, which you saved to **C:\Lab_Files\M05\S03\E01** in
the previous exercise.

6. Enter the Description as: "DSC configuration to install IIS, download and create new website." then click **OK**.

    ![Import Configuration](dsc-rtyu-small.png)

7. Click the refresh icon. You should now see that your **DeployWebsite** DSC configuration is displayed under the CONFIGURATION column
   and the LAST MODIFIED time stamp is shown also.

8. Now that we've uploaded the DSC Configuration, we are almost ready to compile it. However, there is another step first - Remember we used 2 DSC Resources in the DSC Configuration you built in Exercise 1? Those Resources now need to be imported into your Automation Account. From the menu on the left of the screen, click **Modules** under SHARED RESOURCES

8. Azure Automation allows us to directly import resources from the PowerShell Gallery. To do this, click the **Browse gallery** button:

    ![ContosoAutomationAccount-Modules](dsc-5678.png)

9. In the **Browse Gallery** pane, search for **cAzureStorage** and click it: ![Browse Gallery](dsc-3456.png)

10. In the **cAzureStorage** window click the **Import** button. Click **OK** when prompted to import the resource. This will import the resource into
your Azure Automation account.

11. Go back to the **Browse Gallery** pane. Repeat the previous few steps to search for and import the module called: **xWebAdministration**

12. When you import a Resource to your Automation Account, it can take several minutes for the activities to be extracted. Go back to the **Modules**
section of your Automation Account and see the module status:

    ![Refresh Modules List](dsc-7890.png)

13. Click refresh every couple of minutes and wait until both modules you imported are in status **Available**

14. Now that the resources are imported, we can compile your DSC Configuration. In your Automation Account, go back to the **State Configurations (DSC)** section and select the **Configurations** tab.

15. Click the **DeployWebsite** configuration you imported earlier:

16. Click **Compile.**

    ![Compile Configuration](dsc-ffgh.png)

17. You may also recall that in Exercise 1, we defined that the DSC configuration will require some input parameters. Now that we are compiling the configuration, we must supply those values. These parameters are to define the file to download, which we uploaded to Azure Storage in the previous excercise with the deployment script. Fill in the following values from the output of the transcript from exercise 2:

- **STORAGEACCOUNTKEY**: This is the key to access your storage account.
- **STORAGEACCOUNTNAME**: This is the name of the storage account you created in the previous lab. You should have made a note of this in notepad. **NOTE: This must be in lower case**
- **DOWNLOADFILENAME**: SimpleWebsite.zip
- **STORAGEACCOUNTCONTAINER:** websitedata

18. Once you have filled in each field, click **OK**

    ![Start Compilation Job](dsc-StartCompilationJob.png)

19. You should now see that a Compilation job is Queued.

    ![Compilation Job Queued](dsc-wejk.png)

20. It will take several minutes to process this. Close the pane, and reopen after a few minutes and you should see that the DSC Configuration is now
successfully **Completed**:

![Compilation Job Completed](dsc-opfg.png)

# WorkshopPLUS - Azure: Infrastructure as Code

Module 5: Azure Automation - Desired State Configuration (DSC)

## Exercise 4: Deploy Azure VM and Apply DSC

## Exercise 4: Introduction

Now that you've created your DSC Configuration and compiled it into a DSC node
configuration, it can be applied to a Virtual Machine. Applying the DSC node
configuration to a VM will automatically complete the configuration.

## Exercise 4: Scenario

In this lab, we will:

- Apply DSC Configuration to an existing Virtual Machine
- Verify DSC applied successfully

## Exercise 4: Estimated Time to Complete This Lab

30 minutes

## Task Description

1. From your workstation, open the Azure Portal at <http://portal.azure.com>

2. Navigate to **Virtual Machines** from the menu on the
left. After a bit, you should see the VM is in a **Running** state:

    ![VM in Running State](dsc-m05-s02-e04-Get-VmStatus.png)

3. Now that your VM is running, we can go ahead and apply the DSC Node
Configuration to it. Start by navigating back to your
**IAC-DSC-NP-#############-AAA-01** Automation Account in the Azure Portal.

4. From your Automation Account, click **State configuratin (DSC)**.

5. Click the **Add** button.

6. Select the **IACDSCNPWES01** VM.

7. Click **+Connect** in the new blade.

8. Set the following values in the Registration pane. (leave all other values at default):

    - **Node Configuration Name**: DeployWebsite.localhost
    - **Configuration Mode:** ApplyAndAutoCorrect
    - **Reboot Node if Needed:** Check this box

    ![Register Node](dsc-RegisterNodeWithDSC.png)

9. At this point, the Azure DSC Extension is getting installed on your VM, then
synchronizing with your DSC Automation Account. This will take several minutes to complete.

10. In the **Nodes** tab of the **State configuration (DSC)** section of your automation account, click the **Refresh** button. After a few minutes, you should see the **IACDSCNPWES01** VM with a STATUS of **Compliant**.

    ![Refresh Node Status](dsc-RefreshCompliantNode.png)

11. From the **Nodes** tab, click the **IACDSCNPWES01** node. You may notice that the Initial STATUS is **Compliant**, but the Consistency has as a STATUS of **In progress**.  This is because we must wait for the DSC client to receive and apply the configuration. This may take around 15 minutes. You can check the status by going back to the **Nodes** tab, clicking **Refresh** then clicking on **IACDSCNPWES01**

    ![Consistency Status](dsc-CheckInProgress.png)

12. After a while, when you have refreshed the view, you should see that the DSC
Configuration has been successfully applied to your VM. You will be able to
see a **Consistency** report with the status **Compliant**. Click the
Consistency report:

    ![Consistency Compliant](dsc-CheckConsistencyCompliant.png)

13. From the Report, you should be able to see each of the configurations which
were applied to the node successfully. You can click each to see detailed
information. You may also click the **View raw report** button at the top, to
see the verbose data from when the configuration was applied. This is useful
for troubleshooting.

    ![Consistency Report](dsc-Reporting.png)

14. Finally, let's navigate to the website, to make sure it works.

15. We are now ready to navigate to the website which was deployed to your VM via
DSC! First, we need to find the external IP address of your Virtual Machine.
To get this, navigate back to your **IACDSCNPWES01** VM. From the left of the Azure
Portal, select **Virtual Machines \> **IACDSCNPWES01**.

16. You should be able to see the **DNS name** of the VM listed from the Overview:

    ![Get-DnsName](dsc-m05-s02-e04-Get-DnsName.png)

17. From a web browser on your workstation, connect to the DNS name of
your VM. E.g.: <http://dns#############.eastus.cloudapp.azure.com/>, where ######## represents a 13 character random infix string value of lowercase letters and number and is included to ensure other deployments do not accidentally use the same DNS A record for this registration. This is also derived from the storage account name.

18. If you see the following website displayed, congratulations! You have
successfully configured the new VM with the website automatically via DSC,
without ever logging into the machine!

    ![DSC Demo Website](dsc-m05-s02-e04-Show-Website.png)
