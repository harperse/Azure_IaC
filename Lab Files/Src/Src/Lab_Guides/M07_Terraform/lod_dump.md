# Terraform and Azure

# Overview
In this lab, you will exercise hands-on labs with Terraform. You will learn how to authenticate with Terraform's Azure Provider, manage Terraform state on Azure, and how to stand up resources in Azure using Terraform.

# Labs

[Lab 0 - Setup](#lab-0---install-and-configure-terraform)

[Lab 1 - Azure Provider- Authenticating](#lab-01---azure-provider--authenticating)

[Lab 2 - Managing Terraform State on Azure](#lab-02---managing-terraform-state-on-azure)

[Lab 3 - Create a Terraform Module](#lab-03---create-a-terraform-module)

[Lab 4 - Deploying Resources](#lab-04---deploying-resources)

[Navigation Guide](#navigation-guide)

<!--
---
title: Module 7 - Lab 0
description: WorkshopPLUS - Azure Infra-as-Code
ms.author: Microsoft Enterprise Services
ms.date: 08/12/2019
ms.file: mod07-lab00.md
---


| Update: 08/12/2019  | 30 minutes to read and deploy |

---
-->

<br>

# Lab 0 - Install and Configure Terraform

## 1. Prerequisites

> Note: Visual Studio Code, Azure CLI, and Powershell Az will already be installed and configured in the lab.

- Install Visual Studio Code
    - [Windows](https://code.visualstudio.com/docs/setup/windows)
    - [macOS](https://code.visualstudio.com/docs/setup/mac)
    - [Linux](https://code.visualstudio.com/docs/setup/linux)
- Install Azure CLI
    - [Overview](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
    - [Windows](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)
    - [macOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
    - Install on Linux or [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/about)
        - [Install with apt on Debian or Ubuntu](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
        - [Install with yum on RHEL, Fedora, or CentOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest)
        - [Install with zypper on openSUSE or SLE](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-zypper?view=azure-cli-latest)
        - [Install from script](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest)
    - [Run in Docker container](https://docs.microsoft.com/en-us/cli/azure/run-azure-cli-docker?view=azure-cli-latest)

<br>

## 2. Download and Install Terraform for Windows

1. Create the folder ++++C:\Program Files\Terraform++++
2. Open Terraform download page [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
3. Select your version 32-bit or 64-bit and download the zip file (e.g.: terraform_0.xx.xx_windows_amd64.zip)
4. Open the folder where you saved the downloaded file, and unzip the package in the folder you created in the step 1 ++++C:\Program Files\Terraform\++++. Terraform runs as a single binary named **terraform.exe**
5. Now we will make sure that the terraform binary is available on the PATH. **Open Control Panel** -> **System** -> **Advanced System settings** -> **Environment Variables**
6. In the **System Variables** panel, scroll down until you find **PATH**, then select **Path** and click **Edit**
7. In the **Edit environment variable** window, click **New**
8. Enter ++++C:\Program Files\Terraform\++++
9. Click **OK** in all three windows closing the **System Properties** completely

<br>

## 3. Validating Terraform installation

After installing Terraform, verify that the installation worked, and what is the Terraform version.

1. Open CMD
2. Type ++++terraform++++ press **Enter**
3. You will see the following result

    ![_Picture: Terraform Validation](3-terraform-validation-1.png "Terraform Validation"){ width=100% }

4. Now type ++++terraform -version++++ to validate Terraform installed version (As of August 28, 2019, the latest version is 0.12.7. The version should be 0.12.7 or higher)


<br>

## 4. Install the Terraform Visual Studio Code extension

1. Launch **Visual Studio Code**
2. Open the **Extensions** view
   - Windows/Linux: **Ctrl+Shift+X**
   - macOS: **Shift+⌘+X**

    ![_Picture: Terraform VS Code extension installation](4-install-terraform-vscode-ext-1.png "Terraform VS Code extension installation"){ width=100% }

3. Use the **Search Extensions** in Marketplace text box to search for the *Terraform* extension
4. Select **Install** [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)

    !IMAGE[5ntg5kue.jpg](5ntg5kue.jpg)


<br>

## 5. Verify the Terraform extension is installed in Visual Studio Code

1. Select **Extensions**
2. Enter ++++@installed++++ in the search text box

    ![_Picture: Terraform VS Code extension validation](5-validate-terraform-vscode-ext-1.png "Terraform VS Code extension validation"){ width=100% }

3. The Terraform extension will appear in the list of installed extensions


4. You can now run all supported Terraform commands in your Cloud Shell environment from within Visual Studio Code

## 6. Module 7 - Lab 0 - Review

In this LAB we completeled the following activities

1. Installation of prerequisites to run a Terraform template, by installing Azure CLI and Microsoft VS Code
2. Download of Terraform, and system variables configuration to execute Terraform from Path in the local system
3. Validation of Terraforms by checking the Terraform version
4. Installation of Terraform extension for VS Code
5. Validation of Terraform VS Code extension

---



<!--
section: _SECTION_1
layout: "azurerm"
page_title: "Azure Provider: Authenticating via a Service Principal and a Client Secret"
sidebar_current: "docs-azurerm-guide-authentication-service-principal-client-secret"
description: |-
  This guide will cover how to use a Service Principal (Shared Account) with a Client Secret as authentication for the Azure Provider.

-->





# lab-01 - Azure Provider- Authenticating

Terraform supports a number of different methods for authenticating to Azure:

* Authenticating to Azure using the Azure CLI
* Authenticating to Azure using Managed Service Identity
* Authenticating to Azure using a Service Principal and a Client Certificate
* Authenticating to Azure using a Service Principal and a Client Secret (which is covered in this guide)

---

Terraform recommends using either a Service Principal or Managed Service Identity when running Terraform non-interactively (such as when running Terraform in a CI server) - and authenticating using the Azure CLI when running Terraform locally.

## Pre-requisites
1. [Install Azure CLI](#install-azure-cli)


## Creating a Service Principal

A Service Principal is an application within Azure Active Directory whose authentication tokens can be used as the **client_id**, **client_secret**, and **tenant_id** fields needed by Terraform (**subscription_id** can be independently recovered from your Azure account details).

It's possible to complete this task in either the [Azure CLI](#creating-a-service-principal-using-the-azure-cli) or in the Azure Portal - In this lab, we will create a Service Principal which has **Contributor** rights to the subscription. [It's also possible to assign other rights](https://azure.microsoft.com/en-gb/documentation/articles/role-based-access-built-in-roles/) depending on your configuration.

### Creating a Service Principal using the Azure CLI

1. [Open a terminal in VS code](#open-a-terminal-in-vs-code)

> **Note**: If you're using the **China**, **German** or **Government** Azure Clouds - you'll need to first configure the Azure CLI to work with that Cloud.  You can do this by running:

```shell
$ az cloud set --name AzureChinaCloud|AzureGermanCloud|AzureUSGovernment
```
---

2. [Login to azure with Azure CLI](#login-to-azure-azure-cli)

3. We can now create the Service Principal which will have permissions to manage resources in the specified Subscription using the following command. Please **replace** `insert SUBSCRIPTION ID` with your subscription id and **run**:

```shell
$ az ad sp create-for-rbac --name module7terraformdemo --role="Contributor" --scopes="/subscriptions/<insert SUBSCRIPTION ID>"
```

This command will output 5 values:

```json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

4. We will need these values for later. Simply **copy and paste** them in a text editor for now. They will map to the Terraform variables like so:

 - `appId` is the `client_id` defined above.
 - `password` is the `client_secret` defined above.
 - `tenant` is the `tenant_id` defined above.

---

5. Finally, it's possible to test these values work as expected by first logging out of your current session

```bash
$ az logout
```
   
6. Now, log in using the appId value which is the CLIENT_ID, password value which is the CLIENT_SECRET, and tenant value which is the TENANT_ID that you noted from step 4:

```shell
$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
```

7. Once logged in as the Service Principal - we should be able to run commands with Contributor permissions on the specified subscription. Let's test that you are authenticated by simply listing available regions in your subscription:

```shell
$ az account list-locations
```

8. Now that we know the Service Principal works, we can log out. Later, we will configure our Terraform provider to authenticate with this Service Principal

```bash
$ az logout
```

Information on how to configure the Terraform Provider block using the newly created Service Principal credentials can be found below.

---

### Configuring the Service Principal in Terraform

As we've obtained the credentials for this Service Principal - it's possible to configure them in a few different ways. Please spend ~2 minutes glancing over Terraform's official Input Variables [documentation](https://www.terraform.io/docs/configuration/variables.html). You will see various options for setting up variables:

- [In a Terraform Enterprise workspace](https://www.terraform.io/docs/enterprise/workspaces/variables.html)
- Individually, with the -var command line option.
- In variable definitions (.tfvars) files, either specified on the command line or automatically loaded.
- As environment variables.
- You always have the option to hard code them into your terraform files. However, that is not recommended, especially for for values as important as Service Principal secrets.

In this lab, we will be using .tfvars files to store our important values. We can then edit our [.gitignore](https://git-scm.com/docs/gitignore) to intentionally keep these values away from being pushed to source control. For even more safety, you can also inject secret values into the 5 types of variables described above by retrieving them from [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview). For the purpose of this lab, we will simply store them in a .tfvars file and ensure the file is not uploaded to source control.

In Terraform there are multiple [providers](https://www.terraform.io/docs/providers/index.html). A provider is responsible for understanding API interactions and exposing resources. Terraform basically adds an abstraction layer to json ARM templates which are the payloads that Azure's API interacts. You may create, manage, and update infrastructure for building resources such as physical machines, VMs, network switches, containers, and more.

In this lab, we will, of course, be using the [Azure provider](https://www.terraform.io/docs/providers/azurerm/index.html). The following Provider block can be specified. The Azure Provider version we will use in this lab will be `1.29.0`

Prerequisites
1. [Open the project folder](#open-a-folder-in-vs-code)

2. [Open a terminal in Vs Code](#open-a-terminal-in-vs-code)

3.  Navigate to the `terraform_lab_dir` where you will be writing code for your lab.
```console
cd C:\Lab_Files\M07\terraform_lab_dir
```

Lab continued

1. Ensure the below code exists in file, `.\main.tf`
```hcl
provider "azurerm" {
    version = "1.29.0"
    subscription_id = "${var.azurerm_provider_subscription_id}"
    client_id = "${var.azurerm_provider_client_id}"
    client_secret = "${var.azurerm_provider_client_secret}"
    tenant_id = "${var.azurerm_provider_tenant_id}"
}
```

2. Also, append the below code to the same file, `.\main.tf`
```hcl
resource "azurerm_resource_group" "terraformLabResourceGroup" {
  name     = "terraformLab"
  location = "eastus"

  tags = {
    environment = "dev"
  }
}
```
This will deploy a resource of type [azurerm_resource_group](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html) which is a resource that comes from the `azurerm` provider. We have given it a local name "terraformLabResource". Learn more on resource syntax [here](https://www.terraform.io/docs/configuration/resources.html). In addition, to learn more about the hcl configuration language, please review this [doc](https://www.terraform.io/docs/configuration/index.html)

3. Let's ensure we output the `terraformLabResourceGroup` object upon deploying. Later, you will run a command that will output this variable. Ensure the below code exists in `.\outputs.tf`
```hcl
output "terraformLabResourceGroup_output" {
  value = "${azurerm_resource_group.terraformLabResourceGroup}"
}
```
The above code will output the terraformLabResourceGroup_output object which has a value of azurerm_resource_group.terraformLabResourceGroup, the local object you instantiated at step 2 above.

4. In step 1, you see that we are using this syntax `${var."variable_name"}`. We need to ensure that these variables and their values are constructed. **Copy** and **paste** these variables in the file `.\variables.tf`
```hcl
###############################################################################
#   Azure RM Providers Variables 
#   for providers.tf 
#------------------------------------------------------------------------------
variable "azurerm_provider_subscription_id" {
    type = "string"
    description = "The subscription id of the azure Service Principal"
    default = "0000-00000000-0000000-00000"
}
variable "azurerm_provider_client_id" {
    type = "string"
    description = "The application id of the azure Service Principal"
    default = "0000-00000000-0000000-00000"
}
variable "azurerm_provider_client_secret" {
    type = "string"
    description = "The client secret of the azure Service Principal"
    default = "0000-00000000-0000000-00000"
}
variable "azurerm_provider_tenant_id" {
    type = "string"
    description = "The tenant id of the azure Service Principal"
    default = "0000-00000000-0000000-00000"
}
###############################################################################
```
 You will see that the Azure RM Provider variables default values are dummies. We will construct a tfvars file which will be injected into this variables file via command line argument later on.
 > Note: we could have simply appended the above code to the same `main.tf` file that the provider object sits on. However, it is best practice to separate variables from code

5. Use the output you obtained as a result of the above section [Creating a Service Principal using the Azure CLI](creating-a-service-principal-using-the-azure-cli) to edit the respective values in the file, `.\providers.tfvars`
```hcl
azurerm_provider_subscription_id = "<insert subscription id value>"
azurerm_provider_client_id = "<insert appId value>"
azurerm_provider_client_secret = "<insert password value>"
azurerm_provider_tenant_id = "<insert tenant value>"
```

#### Running Terraform

When using Terraform, there are 3 basic commands that you must know
- [terraform init](https://www.terraform.io/docs/commands/init.html) - to initialize the working directory
- [terraform plan](https://www.terraform.io/docs/commands/plan.html) - to create a plan
- [terraform apply](https://www.terraform.io/docs/commands/apply.html) - to apply the plan

Please follow the below steps to perform these commands

0. [Open the project folder](#open-a-folder-in-vs-code)

1. [Open a terminal in Vs Code](#open-a-terminal-in-vs-code)

2.  Navigate to the `terraform_lab_dir` where you will be writing code for your lab.
```console
cd C:\Lab_Files\M07\terraform_lab_dir
```
##### Lab Continued

0. Let's access the terraform init, plan, and apply methods. Run `terraform init --help` and skim through the capabilities. Feel free to ask questions during this time.
1. Run `terraform plan --help`
2. Run `terraform apply --help`

3. Run `terraform init`
> Note: every time we introduce a new module, we must run Terraform init. [Terraform init](https://www.terraform.io/docs/commands/init.html) is used to initialize a working directory containing terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

You should receive something similar to the below output

!IMAGE[terraform_init_result.PNG](terraform_init_result.PNG)

4. As a result of the last step, you will see a `.terraform` folder was automatically created in your working directory. Terraform's *init* managed a few things such as:
   1. Backend Initialization (which we will cover in a later lab)
   2. Child Module Installation
   3. Plugin Installation
   > For more detail on Terraform init, please visit [here](https://www.terraform.io/docs/commands/init.html)

5.  Inject the *providers.tfvars* file when running `terraform plan -var-file="providers.tfvars"`
  >Note: [terraform plan](https://www.terraform.io/docs/commands/plan.html) is an intermittant step to run before actually deploying your resources. This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state.

You should receive something similar to the below

!IMAGE[terraform_plan_result.PNG](terraform_plan_result.PNG)


6. Run `terraform apply -var-file="providers.tfvars"`. Then enter `yes` when prompted to perform the actions described in the output.

You should receive something similar to the below

!IMAGE[terraform_apply_result.PNG](terraform_apply_result.PNG))

   >Note: [terraform apply](https://www.terraform.io/docs/commands/apply.html) is the command that actually deploys your resources. This command is used to apply the changes required to reach the desired state of the configuration, or the pre-determined set of actions generated by a terraform plan execution plan.

7. Run `ls`. This will show the contents of the current working directory

!IMAGE[ls_apply.png](ls_apply.png)

>You will see that a new file was created after you ran `terraform apply`. This `.tfstate` file is needed for Terraform to keep track of the state of your target infrastructure. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures. If your `.terraform` folder uses a local backend to keep track of `.tfstate`, this state file will be updated upon each new `terraform apply`.
This [state](https://www.terraform.io/docs/state/) is stored by default in a local file named "terraform.tfstate", but it can also be stored remotely, which works better in a team environment. We will cover state more in depth in a separate lab.
8. Run `terraform plan -var-file="providers.tfvars" -out myplan` again.
 
You will see that there are no changes to apply since the code has already been applied to the target resources.

!IMAGE[terraform_plan_result2.PNG](terraform_plan_result2.PNG)

9. Run `terraform apply myplan`. (Because you used the -out argument, your plan was saved to *myplan*. Simply, you do not have to re-inject the tfvars files like you did for step 6 above). You will see that no changes will be made and it was quite pointless to run an apply after seeing the plan had 0 changes in the previous step.
10. Navigate to your subscription in the Azure Portal at https://portal.azure.com and click Resource Groups in the left blade.

!IMAGE[portal_rg.PNG](portal_rg.PNG)

11.  Click on the Resource Group named `terraformLab` and you will see that Terraform did indeed apply an empty Resource Group by authenticating through the service principal created during this lab
12.  Congrats! You finished the lab that will allow you to deploy resources using Terraform through a service principal. From this point, you are able to stand up Azure Resources scoped at the contributor level.
---


<!--
section: _SECTION_2
title: Use Azure Storage as a Terraform backend
description: An introduction to storing Terraform state in Azure Storage.
services: terraform
-->


# lab-02 - Managing Terraform State on Azure
Terraform state is used to reconcile deployed resources with Terraform configurations. Using state, Terraform knows what Azure resources to add, update, or delete. By default, Terraform state is stored locally when running *Terraform apply*. This configuration is not ideal for a few reasons:

- Local state does not work well in a team or collaborative environment
- Terraform state can include sensitive information
- Storing state locally increases the chance of inadvertent deletion

Centralizing your state file is a solution. In this lab, we will be doing just that. A common solution is to place your state file in an Azure Blob Storage Account that is locked down to the bare minimum. It is important to lock this down because Terraform prints out your state as is. This may include sensitive resource data like passowrds. Also, please note that terraform supports state locking and consistency checking via native capabilities of Azure Blob Storage. This ensures there are no conflicts if multiple processes to `terraform apply` were to run.


## Create the Storage Account and store the access key in key vault
Before using Azure Storage as a backend, a storage account must be created. The storage account can be created with the Azure portal, PowerShell, the Azure CLI, or Terraform itself. In this lab, we will deploy through the Azure CLI.

In this lab, there is a helper script that will
- create a resource group named *Terraform-States* 
- create a storage account named *terraformstate* followed by a random string
- create a container in the account named *terraformstate* (Note: we can create different containers to host terraform states for different environments like production, stage, etc.)
- create a key vault named *terraform-kv-* followed by the same random string as the storage account
- set access policies to the key vault for the account associated to the email given as input and application id given as input
- create a key vault secret with the name *ARM-ACCESS-KEY* and value of the storage account access key
- stores information to be used throughout the lab in a file at `terraform_lab_dir\lab_output_logs\remote_backend.log`

> Note: We can certainly place the storage account access key in a tfvars file as we did with the client secret in `providers.tfvars`. However, in this lab, we will show you a more secure option in which the secret only lives locally during the lifetime of your powershell session.

**Lab Steps:**
0. [Open the project folder](#open-a-folder-in-vs-code)

1. [Open a terminal in Vs Code](#open-a-terminal-in-vs-code)

2.   Navigate to the `terraform_lab_dir` where you will be writing code for your lab.
```console
cd C:\Lab_Files\M07\terraform_lab_dir
```
3. [Login to azure (Azure CLI)](#login-to-azure-azure-cli)
4. Copy the value of `azurerm_provider_client_id` found in your directory's `providers.tfvars` file. You will need to insert this value in the next command
5. In the terminal, ***run*** the script found at this location `.\helper_scripts\set_remote_backend.ps1` followed by parameters `-adminEmail <insert the email account you use to login to the Azure subscription> -applicationId <insert the value copied from the previous step>`. Below is an example of how this command will look like:

```
.\helper_scripts\set_remote_backend.ps1 -adminEmail joesmith@contoso.com -applicationId xxxx-4444-439a-lkj4-afa6f0983jrec
```
You should see output like the following
```
Checking for an active Azure login..............................................SUCCESS!

Creating Resource Group: [Terraform-States]....................................SUCCESS!

Creating Storage Account [terraformstate044330] and Container [terraformstate]...
SUCCESS!

Creating Terraform KeyVault: [terraform-kv-044330].............................SUCCESS!

Setting KeyVault Access Policy for Admin User: [joesmith@contoso.com]........SUCCESS!

Setting KeyVault Access Policy for Terraform SP with appid: [xxxx-4444-439a-lkj4-afa6f0983jrec]...SUCCESS!

Creating KeyVault Secret(s) for Terraform......................................SUCCESS!
Writing output to .\lab_output_logs\remote_backend.log
```
6. When the script completes, it will have written information about the storage account and key vault in `.\lab_output_logs\remote_backend.log` so that you can reference the information throughout the lab. (Please disregard that the storage access_key value is stored in this file which defeats the whole purpose of the lab. It is simply there for easy referencing)
7. Open `.\lab_output_logs\remote_backend.log` through vs code to see the contents

**Let's double check our work**
1. Navigate to your subscription in the Azure Portal at [https://portal.azure.com](https://portal.azure.com) and click Resource Groups in the left blade. Click on the *Terraform-States* Resource Group and see the resources that were deployed as a result of this script.

!IMAGE[portal_rg.PNG](portal_rg.PNG)

2. Navigate to the Azure Key Vault resource named `terraform-kv-*` (where * is a random string)
3. Check that the Access Policies were configured by navigating to `Access Policies` under `Settings` of the left blade. You should see two policies.
4. Check that the secret was uploaded to Key Vault by clicking on `Secrets` under `Settings`

!IMAGE[kv-secrets.PNG](kv-secrets.PNG)

5. Click on `ARM-ACCESS-KEY`
6. Click on the Current Version
7. Click on `Show Secret Value` and see that the Azure Storage Access Key value has been uploaded
8. Now, navigate to the storage account from the *Terraform-States* Resource Group
9. Click on `Blob` under `Blob Service`

!IMAGE[blob-check.PNG](blob-check.PNG)

10. Click on `terraformstate-dev` and see that it is a blank container. Later in the lab, this will be populated with a state file.
11. Congrats! You created and configured the resources needed for setting up a remote backend for Azure and Terraform.


## Configure state backend with an access key

The Terraform state backend is configured when running *Terraform init*. In this lab, we will be configuring the state backend using an Azure Storage Account access key. (Please note: there are a few other ways of configuring the backend that can be found [here](https://www.terraform.io/docs/backends/types/azurerm.html)). In order to configure the state backend, the following data is required.

- storage_account_name - The name of the Azure Storage account.
- container_name - The name of the blob container.
- key - The name of the state store file to be created.
- access_key - The storage access key.

You obtained this already from the previous section's step 5. Each of these values can be specified in the Terraform configuration file or on the command line, however it is recommended to use an environment variable for the `access_key`. Using an environment variable prevents the key from being written to disk.

**Steps:**
### Code the backend resource
To configure Terraform to use the [backend](https://www.terraform.io/docs/backends/types/azurerm.html) resource type, include a *backend* configuration with a type of *azurerm* inside of the Terraform configuration. You will see in the backend [documentation](https://www.terraform.io/docs/backends/types/azurerm.html), that when authenticating using the Access Key associated with the Storage Account, you will need: *storage_account_name*, *container_name*, *key*, and access_key values to the configuration block.

#### Prerequisites

1. [Open the project folder](#open-a-folder-in-vs-code)

2. [Open a terminal in Vs Code](#open-a-terminal-in-vs-code)

3.  Navigate to the `terraform_lab_dir` where you will be writing code for your lab.
```console
cd C:\Lab_Files\M07\terraform_lab_dir
```
#### Lab Continued

1. Open `.\main.tf`
2. **Append** the below code to the top of the file `main.tf` (Note: you can place this resource anywhere in the file or even in a new .tf file by itself, but for the sake of uniformity among the class, simply place at the top of main.tf)
```hcl
terraform {
    backend "azurerm" {
        
    }
}
```
Notice how we are not instantiating the values here. When setting up terraform backend, you may, instead, pass them in during the `terraform init` phase with a tfvars file.

### Set up backend.tfvars
1. Go back to your powershell session on vscode
2. Open `.\lab_output_logs\remote_backend.log`
3. Copy the value assigned to `storage_account_name`
4. Open `.\configs\dev\backend.tfvars`
5. Replace "<insert storage_account_name value from ..\..\lab_output_logs\remote_backend.log>" with value copied from step 3 above for the `storage_account_name` assignment
4. Open `.\configs\prod\backend.tfvars`
5. Replace "<insert storage_account_name value from ..\..\lab_output_logs\remote_backend.log>" with value copied from step 3 above for the `storage_account_name` assignment. We will use prod for a later lab.
  
Notice how access_key is not being instantiated in this file. Instead, we will assign it to an environment variable and retrieve it from our Key Vault.

### Create environment variable
1. Open `.\lab_output_logs\remote_backend.log`
2. Copy the value assigned to `key_vault_name`
3. In the terminal, run the following code (make sure the value for --vault-name is correct)
```console
$env:ARM_ACCESS_KEY=$(az keyvault secret show --name ARM-ACCESS-KEY --vault-name <insert value from step 2> --query value -o tsv)
```
4. Check out the value
```console
 Write-Host $env:ARM_ACCESS_KEY
```

Note: Everytime, you open a new powershell session, you will have to retrieve from Azure Key Vault again.

### Start Terraforming!
From the last lab, the below steps may be familiar to you. That is, terraform init, plan, and apply.
1. First off, let's delete the current `terraform.tfstate` file. This will no longer be needed as it will be uploaded to our Blob container instead
```
rm .\terraform.tfstate
```
#### terraform init (We will only initialize our dev environment during this time)
To inject both the backend.tfvars variables and the environment variable, we can run a [partial configuration](https://www.terraform.io/docs/backends/config.html#partial-configuration) in the command line with the -backend-config flag
1. In the terminal, **run**
```hcl
terraform init -backend-config="configs/dev/backend.tfvars" `
               -backend-config="access_key=$env:ARM_ACCESS_KEY" 
```
2. Your terraform configuration should be successfully initialized by this step
#### terraform plan
1.  Run `terraform plan -var-file="providers.tfvars" -out myplan`
  >Note: [terraform plan](https://www.terraform.io/docs/commands/plan.html) is an intermittant step to run before actually deploying your resources. This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state.
#### terraform apply

2. Run `terraform apply myplan`. Then enter `yes` when prompted to perform the actions described in the output.

   >Note: [terraform apply](https://www.terraform.io/docs/commands/apply.html) is the command that actually deploys your resources. This command is used to apply the changes required to reach the desired state of the configuration, or the pre-determined set of actions generated by a terraform plan execution plan.

3. Run `ls`. You will see that a .tfstate file was not created here like last time. Instead, it was updated in your Blob container.
4. Navigate to your subscription in the Azure Portal at https://portal.azure.com and click Resource Groups in the left blade.

!IMAGE[portal_rg.PNG](portal_rg.PNG)

5. Now, navigate to the storage account from the *Terraform-States* Resource Group
6. Click on `Blob` under `Blob Service`

!IMAGE[blob-check.PNG](blob-check.PNG)

7. Click on `terraformstate` and see that the `dev.terraform.tfstate` file has been updated
8. Congrats! You have just learned to secure Azure provisioning with Terraform backend and Azure Key Vault
---

## A couple things to note:
### State locking

When using an Azure Storage Blob for state storage, the blob is automatically locked before any operation that writes state. This configuration prevents multiple concurrent state operations, which can cause corruption. For more information, see [State Locking](https://www.terraform.io/docs/state/locking.html) on the Terraform documentation.

The lock can be seen when examining the blob though the Azure portal or other Azure management tooling.

!IMAGE[lock.png](lock.png)

### Encryption at rest

By default, data stored in an Azure Blob is encrypted before being persisted to the storage infrastructure. When Terraform needs state, it is retrieved from the backend and stored in memory on your development system. In this configuration, state is secured in Azure Storage and not written to your local disk.

For more information on Azure Storage encryption, see [Azure Storage Service Encryption for data at rest](https://docs.microsoft.com/en-us/azure/storage/common/storage-service-encryption).


Learn more about Terraform backend configuration at the [Terraform backend documentation](https://www.terraform.io/docs/backends/).

<!-- LINKS - internal -->
[azure-key-vault]: ../key-vault/quick-create-cli.md
[azure-storage-encryption]: ../storage/common/storage-service-encryption.md

<!-- LINKS - external -->
[terraform-azurerm]: https://www.terraform.io/docs/backends/types/azurerm.html
[terraform-backend]: https://www.terraform.io/docs/backends/
[terraform-state-lock]: https://www.terraform.io/docs/state/locking.html


<!--
title: Create a Terraform Module
description: Creating your own custom Terraform Module
services: terraform
-->

# lab-03 - Create a Terraform Module

## What is a Module
A module is a container for multiple resources that are used together. Modules can be used to create lightweight abstractions, so that you can describe your infrastructure in terms of its architecture, rather than directly in terms of physical objects.
The *.tf* files in your working directory when you run terraform plan or terraform apply together form the root module. That module may call other modules and connect them together by passing output values from one to input values of another.

An example use case for creating a module is a frontend and backend scenario. You may find it logical to make one module for your frontend, and one for your backend. Because you can create modules within modules, you may also find it logical to place both modules within a parent module that encompasses the whole solution. Please use this [doc](https://www.terraform.io/docs/modules/index.html#when-to-write-a-module) as guidance for understanding *when to write a module*. Because your terraform code is abstracted into modules, you can create releases specific to your dev, stage, and production environments by simply inputting a different *.tfvars* file respective to each stage in your release pipeline.

## Lab
In this lab, we will be following the *Standard Module Structure* as described in the official Terraform docs [here](https://www.terraform.io/docs/modules/index.html#standard-module-structure)

During this exercise, we will place the resource group code that we have been creating throughout section 1 and 2 in a module called *my-frontend-module* (Please note: Simply placing a resource group in a module is not a good use case. These steps are built to simply walk through the standard module structure).

### Prerequisites
1. [Open the project folder](#open-a-folder-in-vs-code)


### DIY (Do it Yourself) Challenge (Estimated time of completion 1 hr)
In this exercise, you will create your own module named *my-frontend-module* by referencing the [Standard Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure). If you get stuck, feel free to peek through the VS Code *Explorer* pane at *C:\Lab_Files\M07\terraform_lab_dir\m07-s03-e01-frontend-module*. You will see that the *m07-s03-e01-frontend-module* directory, has a *main.tf* file that simply mocks the *azurerm_resource_group* type of what is currently in the root main.tf found at *C:\Lab_Files\M07\terraform_lab_dir\main.tf*. Similarly, outputs.tf has a copy of the *output* type and variables.tf has the variables to inject to the *azurerm_resource_group* object.

#### Please follow the below requirements:
1. You must deploy 2 resource groups (RGs). First RG should be named "dev-frontendTerraformLab" with a tag "environment: dev". Second RG should be named "prod-frontendTerraformLab" with a tag "environment: prod". Both RG names should NOT have WHITESPACE.
2. You must use the *./configs/dev/m07-s03-e01-dev.tfvars* and *./configs/prod/m07-s03-e01-prod.tfvars* files WITHOUT editing the files. (Notice the whitespace on the environment variable)
3. You must output the azurerm_resource_group object through the command line with the output variable name "frontend_module". Example output like so:

```
Outputs:

frontend_module = {
  "terraformLabResourceGroup_output" = {
    "id" = "/subscriptions/XXXXXXXXXXXXXXXXXX/resourceGroups/prod-frontendTerraformLab"
    "location" = "westus"
    "name" = "prod-frontendTerraformLab"
    "tags" = {
      "environment" = "prod"
    }
  }
}
```

4. Both Resource Groups must exist at the same time
5. Use *./configs/prod/backend-prod.tfvars* when deploying *./configs/prod/m07-s03-e01-prod.tfvars* and *./configs/dev/backend-dev.tfvars* when deploying *./configs/dev/m07-s03-e01-dev.tfvars*. Please note, it is recommended practice to separate access from state files in lower environments from state files in higher environments like production. It is especially important since state files contain plain text (i.e. passwords) of the state of your target environment.

By the end of the challenge you should have the following target components:


1. Two state files in your Azure Storage Account like so:  
<br/>
!IMAGE[sdlkfsdlkPNG.PNG](sdlkfsdlkPNG.PNG)


2. Two resource groups in your Subscription like so:
<br/>
!IMAGE[Annotation2019-08-29125319.png](Annotation2019-08-29125319.png)[]
<br/>
!IMAGE[Annotation2019-08-29133041.png](Annotation2019-08-29133041.png)

> Note: If you need hints throughout this DIY challenge, feel free to check out the section below. Feel free to collaborate with your peers and ask your instructor for guidance throughout this challenge. You will probably stumble upon at least one road block along the way, but that's okay! We are all here to learn ;D

#### Extra Guidance and hints (if needed)

Hints: 
1. Terraform has built-in [functions](https://www.terraform.io/docs/configuration/functions.html) that include string manipulation.
2. You are creating a new module (rinse and repeat!). Don't forget what you learned in Lab 2! The backend state needs to be initialized when creating new modules.
3. Remember where your configuration values for the azurerm provider exist. Don't forget what you learned in Lab 1 when running *terraform plan* and *terraform apply*
4. For requirement 3, checkout [this](https://www.terraform.io/docs/configuration/outputs.html#accessing-child-module-outputs)
5. During this session, Terraform will eventually ask you, "Do you want to copy existing state to the new backend?" Do you...? In other words, do you want to copy your dev state into your prod state? What would happen to the first resource group you created if you were to say "yes" and apply that change? 
6. Feel free to peek at *./m07-s03-e01-frontend-module* or the full solution flow section below if you get stuck


### Full Solution Flow (for a recap or extra guidance):
You may have followed these steps (maybe in a different order):
1. Created a folder *C:\Lab_Files\M07\terraform_lab_dir\my-frontend-module*
2. Created a file README.md with your choice of text
3. Created a *main.tf* file and copied the root *main.tf* file's *azurerm_resource_group* resource object

```
resource "azurerm_resource_group" "terraformLabResourceGroup" {
  name     = "terraformLab"
  location = "eastus"

  tags = {
    environment = "dev"
  }
}
```
4. Realized the first requirement and edited this code to be more dynamic and look something like:
```
resource "azurerm_resource_group" "terraformLabResourceGroup" {
  name     = "${var.environment}-frontendTerraformLab"
  location = "${var.location}"

  tags = {
    environment = var.environment
  }
}
```
5. Looked at the *./configs/dev/m07-s03-e01-dev.tfvars* and *./configs/prod/m07-s03-e01-prod.tfvars* files and saw all the whitespace in the environment variable. You then realized the 2nd requirement. You took a look at the Terraform functions documentation and found this little gem, the [trimspace](https://www.terraform.io/docs/configuration/functions/trimspace.html) function. You then wrote something like this:

```
resource "azurerm_resource_group" "terraformLabResourceGroup" {
  name     = "${trimspace(var.environment)}-frontendTerraformLab"
  location = "${var.location}"

  tags = {
    environment = "${trimspace(var.environment)}"
  }
}
```
6. You might've even done some research into how to not rewrite the trimspace logic by using [locals](https://www.terraform.io/docs/configuration/locals.html) like so:

```
locals {
  environment = trimspace(var.environment) 
}


resource "azurerm_resource_group" "terraformLabResourceGroup" {
  name     = "${local.environment}-frontendTerraformLab"
  location = "${var.location}"

  tags = {
    environment = local.environment
  }
}
```

7. Because you just created the variables *environment* and *location* and did not instantiate them anywhere, you created *./my-frontend-module/variables.tf* file with code like so:
```
variable "location" {
    type = "string"
    description = "The location of the resource group"
    default = "eastus"
}

variable "environment" {
    type = "string"
    description = "The release stage of the environment"
    default = "dev"
}
```

8. Realized that we still need to call this module from the root *main.tf* file and edited it like so (learn [here](https://www.terraform.io/docs/configuration/syntax.html#comments) about comments):
   
```
terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  version         = "1.29.0"
  subscription_id = var.azurerm_provider_subscription_id
  client_id       = var.azurerm_provider_client_id
  client_secret   = var.azurerm_provider_client_secret
  tenant_id       = var.azurerm_provider_tenant_id
}

# resource "azurerm_resource_group" "terraformLabResourceGroup" {
#   name     = "terraformLab"
#   location = "eastus"

#   tags = {
#     environment = "dev"
#   }
# }

module "my-frontend-module" {
  source = "./my-frontend-module"

  location    = var.location
  environment = var.environment
}


```
9. Realized that var.location and var.environment do not exist at the root level and added it to the existing root *./variables.tf* file like so:

```
###############################################################################
#   Azure RM Providers Variables 
#   for providers.tf 
#------------------------------------------------------------------------------
variable "azurerm_provider_subscription_id" {
  type        = string
  description = "The subscription id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_id" {
  type        = string
  description = "The application id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_secret" {
  type        = string
  description = "The client secret of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_tenant_id" {
  type        = string
  description = "The tenant id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

###############################################################################
#
# For the frontend module
###############################################################################
variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}


```

10.  Saw the 3rd requirement and realized that we already did something similar to that in the root folder's *outputs.tf*. Realized that the resource group object is now coded in a module. Said to yourself, "We first need to output the azurerm_resource_group object from the module. Then, output it from the root."
11. You then created a *.\terraform_lab_dir\my-frontend-module\outputs.tf* file in the module that looks exactly how the original root outputs.tf file looks like

```
output "terraformLabResourceGroup_output" {
  value = "${azurerm_resource_group.terraformLabResourceGroup}"
}
```
12. You searched the internet for how to access child module outputs and found [this](https://www.terraform.io/docs/configuration/outputs.html#accessing-child-module-outputs). At the root *outputs.tf* file you coded:

```
output "frontend_module" {
  value = "${module.my-frontend-module}"
}
```

13. You might have ran...

```
 terraform plan -var-file="configs/dev/m07-s03-e01-dev.tfvars" -var-file="providers.tfvars" -out devplan     
```

14. ...before running the init. You received the below error message if so:

<br>

!IMAGE[lkfjsdldkfj.PNG](lkfjsdldkfj.PNG)


15. Because you created a new module and remembered this concept from lab 2's *setting the remote backend*, you realized that you first had to run:

```
terraform init -backend-config="configs/dev/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY"
```

16. You reran
```
 terraform plan -var-file="configs/dev/m07-s03-e01-dev.tfvars" -var-file="providers.tfvars" -out devplan     

```
17. You ran ...

```
terraform apply devplan
```

18. ... which output

```
Outputs:

frontend_module = {
  "terraformLabResourceGroup_output" = {
    "id" = "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXXX/resourceGroups/dev-frontendTerraformLab"
    "location" = "eastus"
    "name" = "dev-frontendTerraformLab"
    "tags" = {
      "environment" = "dev"
    }
  }
}
```

19. You patted yourself on the back! Great job! You then set on a mission to deploy to production.
20. You flawlessly remember to run terraform init first:

```
terraform init -backend-config="configs/prod/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY"
```

21. You are prompted
```
Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.


Do you want to copy existing state to the new backend? ...
```

22. You select yes. Run *terraform plan* and realize that this will overwrite your dev target resources. You may even mistakenly run *terraform apply*. No worries! You run through steps 14 to 18 again and select no this time.

23. After selecting either yes or no, you see these state files created in your Azure Storage account.

![](../media/sdlkfsdlkPNG.PNG)

24.  You ran
```
 terraform plan -var-file="configs/prod/m07-s03-e01-prod.tfvars" -var-file="providers.tfvars" -out prodplan     

```
25. You ran ...

```
terraform apply prodplan
```

26. ... which output

```
Outputs:

frontend_module = {
  "terraformLabResourceGroup_output" = {
    "id" = "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXXX/resourceGroups/prod-frontendTerraformLab"
    "location" = "westus"
    "name" = "prod-frontendTerraformLab"
    "tags" = {
      "environment" = "prod"
    }
  }
}
```

27.  You patted yourself on the back! Great job!


## Conclusion

During this lab you:
1. Created your own custom module.
2. Managed using "separate" backend state mechanisms for different stages. This is meant to prepare you for deploying through a CI/CD pipeline. 
3. Learned about Terraform functions like trimspace.
4. Learned how to output module objects.
 
Note: This lab exercise could have flowed more flawlessly if one were to use [terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) or [terraform env](https://www.terraform.io/docs/commands/env.html) which is deprecated. However, the current issue with using *terraform workspaces* is that *workspaces* are purposed to use one backend. As the documentation states 

"Certain backends support multiple named workspaces, allowing multiple states to be associated with a single configuration. The configuration still has only one backend, but multiple distinct instances of that configuration to be deployed without configuring a new backend or changing authentication credentials."

In other words, one Storage Account with one access key would be used against the dev stage AND prod stage in our scenario. For the sake of this exercise, we could have simply ran:
1. terraform workspace new dev (This would have created a state file in the Storage Account container and appended ":dev" to the name)
2. terraform workspace new prod (This would have created a state file in the Storage Account container and appended ":prod" to the name)

Ultimately, you would end up with a default state file, a dev, and a prod one. However, with security in mind, you may want to consider making the access mechanisms specific to each environment.

<!--
title: Deploying Resources
description: Deploying Resources. You will learn how to use the dependson, data, provisioner terraform mechanics while securing your secret with Key Vault.
services: terraform
-->

# Lab 4 - Deploying Resources
In this lab, we will learn how to deploy Azure Resources using basic Terraform mechanics. We will learn how to use Terraform's [depends_on](https://www.terraform.io/docs/configuration/resources.html#depends_on-explicit-resource-dependencies) meta-argument, [provisioner](https://www.terraform.io/docs/provisioners/index.html) types, [data](https://www.terraform.io/docs/configuration/data-sources.html) sources all while securing our secrets in Key Vault.

## Prerequisites

1. [Open the project folder](#open-a-folder-in-vs-code)

2. [Open a terminal in Vs Code](#open-a-terminal-in-vs-code)

3.  Navigate to the `terraform_lab_dir` where you will be writing code for your lab.
```console
cd C:\Lab_Files\M07\terraform_lab_dir
```
4.  We will create this environment in our *dev* environment. Run
```
terraform init -backend-config="configs/dev/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY"
```
5. If you haven't run this from the last lab already, run `terraform destroy -var-file="providers.tfvars"` to destroy your target infrastructure generated from the last lab.

## Lab Continued (A)
We will be writing this code at the main.tf root level. This code can definitely be placed in its own module later on - as you have learned from lab 3. For the purpose of this lab, please develop under the root directory module. If you get lost at any point, please retrace your steps or you may review *./m07-s04-final-solution.tf* which is the full and final code solution containing outputs.tf, variables.tf, and main.tf code.


1. Open *./main.tf*
2. Delete everything except

```
terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  version         = "1.29.0"
  subscription_id = var.azurerm_provider_subscription_id
  client_id       = var.azurerm_provider_client_id
  client_secret   = var.azurerm_provider_client_secret
  tenant_id       = var.azurerm_provider_tenant_id
}
```
3. Open *./outputs.tf*
4. Delete everything. We will output different resources during this lab.
5. Save all / CTRL^S

## Lab Continued (B)
1. Open *./variables.tf*
2. Ensure the below code exists
```
###################################################
#   Azure RM Providers Variables 
#   for providers.tf 
###################################################
variable "azurerm_provider_subscription_id" {
  type        = string
  description = "The subscription id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_id" {
  type        = string
  description = "The application id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_secret" {
  type        = string
  description = "The client secret of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_tenant_id" {
  type        = string
  description = "The tenant id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

###################################################
# Environment Specs
###################################################
variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}

```

## Lab Continued (C)
In this lab, we will need to reference our key vault created in lab 2. This Key Vault was not created by our Terraform code, rather the script found under *./helper_scripts/set_remote_backend.ps1*. We will learn how to interact with unmanaged Terraform resources during this lab like our Key Vault.

1. Navigate to *./configs/dev/keyvault.tfvars* and insert the values shown in *./lab_output_logs/remote_backend.log*
2. Append to *./variables.tf*
```
###################################################
# Key Vault Components
###################################################

variable "key_vault_name" {
  type        = string
  description = "the name of the main key vault"
  default     = "mykeyvault"
}
variable "key_vault_resource_id" {
  type        = string
  description = "the resource id of the main key vault"
  default     = "XXXXX"
}
variable "admin_pw_name" {
  type        = string
  description = "the admin password of the vm"
  default     = "admin-pw"
}
```
## Lab Continued (D)
In this lab we will create a simple Azure Ubuntu vm. The vm will have a NIC with a public ip. The vm will sit inside a subnet within a vnet. The subnet will have a network security group with one security rule allowing port 22 for ssh.
1. Navigate to *./main.tf*
2. Place the code we created in the last lab in our root main.tf
```
locals {
  environment = trimspace(var.environment)
}
```
3. Create a resource group like so:
```
resource "azurerm_resource_group" "main" {
  name     = "${local.environment}-resources"
  location = var.location
}
```
4. Create your network security group which will allow for port 22.
```
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "AllowSSHIn"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_resource_group.main]
}
```
> Notice the depends_on meta-argument. The depends_on statement explicitly specifies a dependency. This is only necessary when a resource relies on some other resource's behavior, but does not access any of that resource's data in its arguments. Notice how this is not actually necessary as we are already accessing azurerm_resource_group.main arguments via *location* and *resource_group_name*. Nonetheless, it does not hurt to be explicit.
5. Before we create a vm, we need to create the vnet that supports it. Paste the below vnet configuration. We will place the vm in subnet1. (For the purpose of the lab, we are hardcoding a couple values like the address_prefix. These values can be placed in variables later on)
```
resource "azurerm_virtual_network" "main" {
  name                = "${local.environment}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"


  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
    security_group = "${azurerm_network_security_group.nsg.id}"
  }

  depends_on = [azurerm_resource_group.main, azurerm_network_security_group.nsg]

}
```
6. We need to create the NIC. Notice in the [documentation](https://www.terraform.io/docs/providers/azurerm/r/network_interface.html) that we need to obtain the subnet id as part of the ip configuration of the NIC. The subnet1 resource is contained within the *azurerm_virtual_network.main* resource. azurerm_virtual_network.main.subnet will print out as an array of map. Rather than having to extrapolate the subnet id from azurerm_virtual_network.main.subnet, we can simply use the [data](https://www.terraform.io/docs/configuration/data-sources.html) source for [subnet](https://www.terraform.io/docs/providers/azurerm/r/subnet.html). We can do this by specifying the name, vnet name, and resource group name like so:
```
data "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  virtual_network_name = "${local.environment}-network"
  resource_group_name  = "${azurerm_resource_group.main.name}"
}
```
7. Now, we can create our NIC and attach it to subnet1 like so:
```
resource "azurerm_network_interface" "vm" {
  name                = "${local.environment}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vm.id}"
  }

  depends_on = [azurerm_resource_group.main, azurerm_virtual_network.main, azurerm_public_ip.vm]
}
```
8. Create the Public IP
```
resource "azurerm_public_ip" "vm" {
  name                = "mypip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.main]
}
```
9. The ubuntu machine that we will be creating will use a simple password and username to logon to the machine. First we need to retrieve the existing Key Vault secret that was generated in lab 2 by the *./helper_scripts/set_remote_backend.ps1* script. Add the below to your main.tf file:
```
data "azurerm_key_vault_secret" "main" {
  name         = var.admin_pw_name
  key_vault_id = var.key_vault_resource_id
}
```
10. Lets create a locals argument for the vm configuration
```
locals {
  vm = {
    computer_name = "vm1"
    user_name     = "admin1234"
  }
}
```
11. Create the ubuntu machine
resource "azurerm_virtual_machine" "vm" {

  name                  = "${local.environment}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.vm.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = local.vm.computer_name
    admin_username = local.vm.user_name
    admin_password = data.azurerm_key_vault_secret.main.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_resource_group.main, azurerm_virtual_network.main]

}
## Lab Continued (E)
1. Navigate to *./outputs.tf* and let's include our vm endpoint info
```
output "vmEndpoint" {
  value = azurerm_public_ip.vm.ip_address
}
output "username" {
  value = local.vm.user_name
}
output "password" {
  value = data.azurerm_key_vault_secret.main.value
}

```
## Lab Continued (F)
1. CTRL^S to save
2. Run `terraform fmt`. [This](https://www.terraform.io/docs/commands/fmt.html) will format the spacing of your code.

## Checkpoint 1
At this point you should have the following code
1. *./configs/dev/keyvaults.tfvars* complete
2. *variables.tf* like so:
```
###################################################
#   Azure RM Providers Variables 
#   for providers.tf 
###################################################
variable "azurerm_provider_subscription_id" {
  type        = string
  description = "The subscription id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_id" {
  type        = string
  description = "The application id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_client_secret" {
  type        = string
  description = "The client secret of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

variable "azurerm_provider_tenant_id" {
  type        = string
  description = "The tenant id of the azure Service Principal"
  default     = "0000-00000000-0000000-00000"
}

###################################################
# Environment Specs
###################################################
variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}

###################################################
# Key Vault Components
###################################################

variable "key_vault_name" {
  type        = string
  description = "the name of the main key vault"
  default     = "mykeyvault"
}
variable "key_vault_resource_id" {
  type        = string
  description = "the resource id of the main key vault"
  default     = "XXXXX"
}
variable "admin_pw_name" {
  type        = string
  description = "the admin password of the vm"
  default     = "admin-pw"
}
```
3. *./main.tf* like so:
```
terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  version         = "1.29.0"
  subscription_id = var.azurerm_provider_subscription_id
  client_id       = var.azurerm_provider_client_id
  client_secret   = var.azurerm_provider_client_secret
  tenant_id       = var.azurerm_provider_tenant_id
}


locals {
  environment = trimspace(var.environment)
}
locals {
  vm = {
    computer_name = "vm1"
    user_name     = "admin1234"
  }
}


data "azurerm_key_vault_secret" "main" {
  name         = var.admin_pw_name
  key_vault_id = var.key_vault_resource_id
}


resource "azurerm_resource_group" "main" {
  name     = "${local.environment}-resources"
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "AllowSSHIn"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_resource_group.main]
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.environment}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"


  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
    security_group = "${azurerm_network_security_group.nsg.id}"
  }

  depends_on = [azurerm_resource_group.main, azurerm_network_security_group.nsg]

}

data "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  virtual_network_name = "${local.environment}-network"
  resource_group_name  = "${azurerm_resource_group.main.name}"
}

resource "azurerm_public_ip" "vm" {
  name                = "mypip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.main]
}

resource "azurerm_network_interface" "vm" {
  name                = "${local.environment}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vm.id}"
  }

  depends_on = [azurerm_resource_group.main, azurerm_virtual_network.main, azurerm_public_ip.vm]
}

resource "azurerm_virtual_machine" "vm" {

  name                  = "${local.environment}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.vm.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = local.vm.computer_name
    admin_username = local.vm.user_name
    admin_password = data.azurerm_key_vault_secret.main.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_resource_group.main, azurerm_virtual_network.main]

}
```
4. *./outputs.tf* like so:
```
output "vmEndpoint" {
  value = azurerm_public_ip.vm.ip_address
}
output "username" {
  value = local.vm.user_name
}
output "password" {
  value = data.azurerm_key_vault_secret.main.value
}
```
## Lab Continued (G)
Let's run it
1. `terraform init -backend-config="configs/dev/backend.tfvars"  -backend-config="access_key=$env:ARM_ACCESS_KEY" `
2. `terraform plan -var-file="providers.tfvars" -var-file="configs/dev/keyvault.tfvars" -out myplan`
3. `terraform apply myplan`
4. Open a new powershell session by navigating to the terminal and clicking on the "+" icon.
!IMAGE[newterminal.png](newterminal.png)
5. After you apply, you should see credentials for logging on. Run `ssh <username value>@<vmEndpoint value>`
6. When prompted, enter `yes`
7. Enter the password value

## Checkpoint 2
At this point, we have created an azure vm. Let's run a quick demo on terraform [provisioner](https://www.terraform.io/docs/provisioners/index.html). Provisioners are used to execute scripts on a local or remote machine as part of resource creation or destruction. Provisioners can be used to bootstrap a resource, cleanup before destroy, run configuration management, etc.
Let's run a script on our machine.

## Lab
Within */terraform_lab_dir/*, there is a file named *test.sh*. We will copy this file to the machine by using using [file provisioner](https://www.terraform.io/docs/provisioners/file.html) and execute it via [azurerm_virtual_machine_extension](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html). The operations we want to execute on the machine are like so:

1. `chmod +x ./test.sh` to make the script executable
2. `bash test.sh >> ./helloworld.log` to execute the script and append the output to helloworld.log

The script will:
1. print the date
2. print "Hello World"

## Lab Continued (A)
To copy a file to a machine and run it, we can do the following:
1. Open *./main.tf*
2. Use [null_resource](https://www.terraform.io/docs/providers/null/resource.html) which implements the standard resource lifecycle but takes no further action. It is basically a mechanism for running operations to supplement IaC without creating your standard resources like vms, vnets, vpcs.
```
resource "null_resource" remoteExecProvisioner {

}
```
3. Let's create a local variable for the directory of the script. Add the below code:
```
locals {
  scriptWorkingDir = "/home/${local.vm.user_name}/"
}
```
4. To copy the file, let's use the [file provisioner](https://www.terraform.io/docs/provisioners/file.html). Within *file provisioner*, you provide a source, where your file exists, and destination, where to place the file on the remote machine once copied. Place this code inside the *null_resource.remoteExecProvisioner* brackets.
```
  provisioner "file" {
    source      = "./test.sh"
    destination = "${local.scriptWorkingDir}/test.sh"
  }
```
5. We also need to access the remote resource. We can simply ssh with the username and password by using the [connection provisioner](https://www.terraform.io/docs/provisioners/connection.html) like below. Place this code inside the *null_resource.remoteExecProvisioner* brackets.
```
  connection {
    host     = azurerm_public_ip.vm.ip_address
    type     = "ssh"
    user     = local.vm.user_name
    password = data.azurerm_key_vault_secret.main.value
    agent    = "false"
  }
```
6. We need to ensure the vm and the ssh port are set before attempting to copy the file. If we *plan* and *apply* at this point, you will most likely receive an error without the below code existing inside the *null_resource.remoteExecProvisioner* brackets.:
```
  depends_on = [azurerm_virtual_machine.vm, azurerm_network_security_group.nsg]
```


At the end of Lab Continued (A) you should have added the below code to main.tf:
```
locals {
  scriptWorkingDir = "/home/${local.vm.user_name}/"
}
resource "null_resource" remoteExecProvisioner {


  provisioner "file" {
    source      = "./test.sh"
    destination = "${local.scriptWorkingDir}/test.sh"
  }

  connection {
    host     = azurerm_public_ip.vm.ip_address
    type     = "ssh"
    user     = local.vm.user_name
    password = data.azurerm_key_vault_secret.main.value
    agent    = "false"
  }
  depends_on = [azurerm_virtual_machine.vm, azurerm_network_security_group.nsg]
}
```

## Lab Continued (B)
Let's create the [custom script extension](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html) that will execute our bash script. Ensure *null_resource.remoteExecProvisioner* is referenced in the depends_on object.
1. Open *./main.tf*
2. Append the below code:
```
resource "azurerm_virtual_machine_extension" "main" {
  name                 = "hostname"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "commandToExecute": "chmod +x ${local.scriptWorkingDir}/test.sh; sudo apt-get install dos2unix; dos2unix ${local.scriptWorkingDir}/test.sh; /bin/bash ${local.scriptWorkingDir}/test.sh >> ${local.scriptWorkingDir}/helloworld.log"
  }
  SETTINGS

  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_virtual_machine.vm, azurerm_network_security_group.nsg, null_resource.remoteExecProvisioner]
}
```
The values placed in the commandToExecute object above are unix commands that will:
1. Make the test.sh file executable
2. Install [dos2unix](https://linux.die.net/man/1/dos2unix) command line tool to convert test.sh to a UNIX format.
3. Convert the test.sh to UNIX format
4. Run the script and append it to helloworld.log


## Lab Continued (C)
At this point, you can:
1. Save the changes (Go to File and click Save All) 
2. Return to the original terminal session by clicking on the carrot and selecting the 1st session.
!IMAGE[openotherterminal.png](openotherterminal.png)
4. `terraform init -backend-config="configs/dev/backend.tfvars"  -backend-config="access_key=$env:ARM_ACCESS_KEY" `
5. `terraform plan -var-file="providers.tfvars" -var-file="configs/dev/keyvault.tfvars" -out myplan`
6. `terraform apply myplan`
7. Go back to the the remote session. Run `ssh <username value>@<vmEndpoint value>` and password if needed
8. Run `ls`
9. You will see the files `helloworld.log`  `test.sh`
10. Run `cat helloworld.log`
11. You will see as output:
```
Hello World

--------------------------------
```

## Checkpoint 3
At this point we copied a file and ran it through a custom script extension. If we were to make incremental changes to our *./test.sh* script, our terraform code would actually not acknowledge that the file has changed. Terraform will see that test.sh is still the file to execute and will not see a difference. 

## Lab Continued (A)
Let's test this:
1. Navigate to *./test.sh*
2. Uncomment the below code
```
echo -e $(date)
```
3. Save your work (Go to File and click Save All)
4. Return to the original terminal session by clicking on the carrot and selecting the 1st session.
!IMAGE[openotherterminal.png](openotherterminal.png)
5. `terraform init -backend-config="configs/dev/backend.tfvars"  -backend-config="access_key=$env:ARM_ACCESS_KEY" `
6. `terraform plan -var-file="providers.tfvars" -var-file="configs/dev/keyvault.tfvars" -out myplan`
7. `terraform apply myplan`
8. Go back to the the remote session. Run `ssh <username value>@<vmEndpoint value>` and password if needed
9. Run `ls`
10. You will see the files `helloworld.log`  `test.sh`
11. Run `cat helloworld.log` and you will not see a date (you will see the same as before)
12. Run `cat test.sh` and you will not see the uncommented code 

## Lab Continued (B)
Let's fix this. The way we can plan and apply incremental script changes is by the [triggers](https://www.terraform.io/docs/providers/null/resource.html#triggers) argument.

For Terraform to see that there is a difference in the file, we can do the below steps:
1. Open *./main.tf*
2. Let's generate and [archive](https://www.terraform.io/docs/providers/archive/d/archive_file.html) a zip file of test.sh so that later, we can take a hash of the zip file. Everytime the zip file hash changes, Terraform will know to trigger the script again.
```
data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/test.sh"
  output_path = "${path.module}/test.zip"
}
```
>Note: path.module is a built in terraform variable for finding the current working directory of your terraform root module.
3. Within *null_resource.remoteExecProvisioner* brackets, place the below code which will grab the hash from data.archive_file.init:
```
  triggers = {
    src_hash = "${data.archive_file.init.output_sha}"
  }
```
4. Go to *./test.sh*
5. Uncomment `args=("$@")` and `echo -e "\nhash -> "  ${args[0]}`
6. Save the changes
7. Navigate to *./main.tf*
8. Under azurerm_virtual_machine_extension.main.settings, replace the "commandToExecute" value to include the argument like so:
```
"commandToExecute": "chmod +x ${local.scriptWorkingDir}/test.sh; sudo apt-get install dos2unix; dos2unix ${local.scriptWorkingDir}/test.sh; /bin/bash ${local.scriptWorkingDir}/test.sh ${data.archive_file.init.output_sha} >> ${local.scriptWorkingDir}/helloworld.log"
```
9.  Return to the original terminal session by clicking on the carrot and selecting the 1st session.
!IMAGE[openotherterminal.png](openotherterminal.png)
10. `terraform init -backend-config="configs/dev/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY" ` to intialize the archive_file provisioner
11. `terraform plan -var-file="providers.tfvars" -var-file="configs/dev/keyvault.tfvars" -out myplan`
12. `terraform apply myplan`
13. Go back to the the remote session. Run `ssh <username value>@<vmEndpoint value>` and password if needed
14. Run `ls`
15. You will see the files `helloworld.log`  `test.sh`
16. Run `cat helloworld.log` and you should see that this time it was successful in appending the output of test.sh with something similar to the below output:
```
Hello World

--------------------------------

hash ->  65d6812a83744bac8b16e09af2cf945b3c8539c8
Fri Sep 6 20:14:57 UTC 2019

Hello World

--------------------------------
```
## Lab Continued (C)
Terraform was able to see the difference because you ultimately changed the commandToExecute value. This is why we see the above output. Let's actually put this incremental change code to the test now.
1. Navigate to *./test.sh*
2. Uncomment `echo -e "whoami -> $(whoami)"`
3. Save the work
4. Return to the original terminal session by clicking on the carrot and selecting the 1st session.
!IMAGE[openotherterminal.png](openotherterminal.png)
5. `terraform init -backend-config="configs/dev/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY" ` to intialize the archive_file provisioner
6. `terraform plan -var-file="providers.tfvars" -var-file="configs/dev/keyvault.tfvars" -out myplan`
7. `terraform apply myplan`
8. Go back to the the remote session. Run `ssh <username value>@<vmEndpoint value>` and password if needed
9. Run `ls`
10. You will see the files `helloworld.log`  `test.sh`
11. Run `cat helloworld.log` and you should see output of the whoami command

> Note: You can run Powershell DSC through the custom script extension.

# Conclusion
During this lab, you learned 
1. How to deploy multiple resources that depend on each other. 
2. How to manage resources that are not managed by Terraform
3. How to provision a machine with incremental changes


<!--
Navigation Guide
-->

# Navigation Guide

This document will be referenced throughout the labs as each section may be referenced multiple times.

## Open a folder in VS code
1. Click the Windows button
2. Enter `code "C:\Lab_Files\M07\terraform_lab_dir"`
3. Click *Run command*

!IMAGE[g7guie5y.jpg](g7guie5y.jpg)

## Open a terminal in VS code
1. Navigate to VS Code
2. Use the Ctrl+` keyboard shortcut with the backtick character (this will open the terminal at the bottom of the IDE)
!IMAGE[terminal.png](terminal.png)
3. Start typing your cmdlts

## Install Azure CLI
1. Navigate [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) for installation instructions.

## Login to azure Powershell Az
Prerequisites:
1. You have a terminal open. If not, perform this step: [Open a terminal in VS code](#open-a-terminal-in-vs-code)

Steps:
1. Enter `Connect-AzAccount -Subscription <insert desired subscription id>`
2. You will be prompted for credentials. Input your credentials

## Login to azure Azure CLI
Prerequisites:
1. You have a terminal open. If not, perform this step: [Open a terminal in VS code](#open-a-terminal-in-vs-code)
2. You have Azure CLI installed. If not, perform this step: [Install Azure CLI](#install-azure-cli)

Steps:
1. Enter `az login`
2. Your default browser will pop up and prompt you for credentials. Input your credentials
3. Once logged in, you will see a page like this. At this point you may navigate back to your already authenticated powershell session
<br>
!IMAGE[az_cli_login_confirmation.PNG](az_cli_login_confirmation.PNG)

4. Once logged in - it's possible to list the Subscriptions associated with the account via:

```shell
$ az account list
```

The output (similar to below) will display one or more Subscriptions - with the `id` field being the `subscription_id` field referenced above.

```json
[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "name": "PAYG Subscription",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
```
5. Copy the subscription ID you will be using throughout this course.
6. Enter `az account set --subscription <insert desired subscription id>`
7. Congrats! You have successfully authenticated and set your subscription.