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

During this exercise, we will place the public ip code that we have been creating throughout section 1 and 2 in a module called *my-frontend-module* (Please note: Simply placing a public ip in a module is not a good use case. These steps are built to simply walk through the standard module structure).

### Prerequisites
1. [Open the project folder](../navigation_guide.md/#open-a-folder-in-vs-code)
2. [Login to azure with Azure CLI](../navigation_guide.md/#login-to-azure-azure-cli)


### DIY (Do it Yourself) Challenge (Estimated time of completion 1 hr)
In this exercise, you will create your own module named *my-frontend-module* by referencing the [Standard Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure). If you get stuck, feel free to peek through the VS Code *Explorer* pane at *C:\Lab_Files\M07_Terraform\terraform_lab_dir\m07-s03-e01-frontend-module*. You will see that the *m07-s03-e01-frontend-module* directory, has a *main.tf* file that simply mocks the *azurerm_public_ip* type of what is currently in the root main.tf found at *C:\Lab_Files\M07_Terraform\terraform_lab_dir\main.tf*. Similarly, outputs.tf has a copy of the *output* type and variables.tf has the variables to inject to the *azurerm_public_ip* object.

#### Please follow the below requirements:
1. You must deploy 2 azurerm_public_ip's (PIPs). First PIP should be named "dev-pip" with a tag "environment: dev". Second PIP should be named "prod-pip" with a tag "environment: prod". Both PIP names should NOT have WHITESPACE.
2. You must use the *./configs/dev/m07-s03-e01-dev.tfvars* and *./configs/prod/m07-s03-e01-prod.tfvars* files WITHOUT editing the files. (Notice the whitespace on the environment variable)
3. You must output the azurerm_public_ip object through the command line with the output variable name "frontend_module". Example output like so:

```
Outputs:

frontend_module = {
  "vmEndpoint" = {
    "allocation_method" = "Static"
    "id" = "/subscriptions/XXXXX/resourceGroups/YYYY/providers/Microsoft.Network/publicIPAddresses/prod-pip"
    "idle_timeout_in_minutes" = 4
    "ip_address" = "X.X.X.X"
    "ip_version" = "IPv4"
    "location" = "westus/eastus"
    "name" = "prod/dev-pip"
    "public_ip_address_allocation" = "Static"
    "resource_group_name" = "YYYY"
    "sku" = "Basic"
    "tags" = {
      "environment" = "prod/dev"
    }
    "zones" = []
  }
}
```

4. Both PIPs must exist at the same time
5. Use *./configs/prod/backend-prod.tfvars* when deploying *./configs/prod/m07-s03-e01-prod.tfvars* and *./configs/dev/backend-dev.tfvars* when deploying *./configs/dev/m07-s03-e01-dev.tfvars*. Please note, it is recommended practice to separate access from state files in lower environments from state files in higher environments like production. It is especially important since state files contain plain text (i.e. passwords) of the state of your target environment.

By the end of the challenge you should have the following target components:

1. Two state files in your Azure Storage Account like so:  
<br/>
![](../media/sdlkfsdlkPNG.PNG)
2. Two resource groups in your Subscription like so:
<br/>
![](../media/kjdskss.PNG)
<br/>
![](../media/lsla.png)

> Note: If you need hints throughout this DIY challenge, feel free to check out the section below. Feel free to collaborate with your peers and ask your instructor for guidance throughout this challenge. You will probably stumble upon at least one road block along the way, but that's okay! We are all here to learn ;D

#### Extra Guidance and hints (if needed)

Hints: 
1. Terraform has built-in [functions](https://www.terraform.io/docs/configuration/functions.html) that include string manipulation.
2. You are creating a new module (rinse and repeat!). Don't forget what you learned in Lab 2! The backend state needs to be initialized when creating new modules.
3. Remember where your configuration values for the azurerm provider exist. Don't forget what you learned in Lab 1 when running *terraform plan* and *terraform apply*
4. For requirement 3, checkout [this](https://www.terraform.io/docs/configuration/outputs.html#accessing-child-module-outputs)
5. During this session, Terraform will eventually ask you, "Do you want to copy existing state to the new backend?" Do you...? In other words, do you want to copy your dev state into your prod state? What would happen to the first public ip you created if you were to say "yes" and apply that change? 
6. Feel free to peek at *./m07-s03-e01-frontend-module* or the full solution flow section below if you get stuck


### Full Solution Flow (for a recap or extra guidance):
You may have followed these steps (maybe in a different order):
1. Created a folder *C:\Lab_Files\M07_Terraform\terraform_lab_dir\my-frontend-module*
2. Created a file README.md with your choice of text
3. Created a *main.tf* file and copied the root *main.tf* file's *azurerm_public_ip* resource object

```
resource "azurerm_public_ip" "vm" {
  name                = "mypip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  depends_on          = [data.azurerm_resource_group.main]

  tags = {
    environment = "dev"
  }
}
```
4. Realized the first requirement and edited this code to be more dynamic and look something like:
```
resource "azurerm_public_ip" "vm" {
  name                = "${var.environment}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
}
```
5. Looked at the *./configs/dev/m07-s03-e01-dev.tfvars* and *./configs/prod/m07-s03-e01-prod.tfvars* files and saw all the whitespace in the environment variable. You then realized the 2nd requirement. You took a look at the Terraform functions documentation and found this little gem, the [trimspace](https://www.terraform.io/docs/configuration/functions/trimspace.html) function. You then wrote something like this:

```
resource "azurerm_public_ip" "vm" {
  name                = "${trimspace(var.environment)}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"

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


resource "azurerm_public_ip" "vm" {
  name                = "${local.environment}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"

  tags = {
    environment = local.environment
  }
}
```

7. Because you just created the variables *environment*, *location*, *rg_name* and did not instantiate them anywhere, you created *./my-frontend-module/variables.tf* file with code like so:
```
variable "location" {
    type = "string"
    description = "The location of the public ip"
    default = "eastus"
}

variable "environment" {
    type = "string"
    description = "The release stage of the environment"
    default = "dev"
}
variable "rg_name" {
    type = "string"
    description = "The name of the resource group"
    default = "XXXXX"
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
}

# resource "azurerm_public_ip" "vm" {
#   name                = "mypip"
#   location            = data.azurerm_resource_group.main.location
#   resource_group_name = data.azurerm_resource_group.main.name
#   allocation_method   = "Static"
#   depends_on          = [data.azurerm_resource_group.main]

#   tags = {
#     environment = "dev"
#   }
# }

module "my-frontend-module" {
  source = "./my-frontend-module"

  location    = var.location
  environment = var.environment
  rg_name     = data.azurerm_resource_group.main.name
}


```
9. Realized that var.location and var.environment do not exist at the root level and added it to the existing root *./variables.tf* file like so:

```
variable "rg_name" {
    type = "string"
    description = "The name of the resource group"
    default = "XXXXX"
}

variable "location" {
  type        = string
  description = "The location of the public ip"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}


```

1.   Saw the 3rd requirement and realized that we already did something similar to that in the root folder's *outputs.tf*. Realized that the public ip object is now coded in a module. Said to yourself, "We first need to output the azurerm_public_ip object from the module. Then, output it from the root."
2.  You then created a *.\terraform_lab_dir\my-frontend-module\outputs.tf* file in the module that looks exactly how the original root outputs.tf file looks like

```
output "vmEndpoint" {
  value = azurerm_public_ip.vm
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

![](../media/lkfjsdldkfj.PNG)


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

Outputs:

frontend_module = {
  "vmEndpoint" = {
    "allocation_method" = "Static"
    "id" = "/subscriptions/XXXXX/resourceGroups/YYYY/providers/Microsoft.Network/publicIPAddresses/prod-pip"
    "idle_timeout_in_minutes" = 4
    "ip_address" = "X.X.X.X"
    "ip_version" = "IPv4"
    "location" = "eastus"
    "name" = "dev-pip"
    "public_ip_address_allocation" = "Static"
    "resource_group_name" = "YYYY"
    "sku" = "Basic"
    "tags" = {
      "environment" = "dev"
    }
    "zones" = []
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

Outputs:

frontend_module = {
  "vmEndpoint" = {
    "allocation_method" = "Static"
    "id" = "/subscriptions/XXXXX/resourceGroups/YYYY/providers/Microsoft.Network/publicIPAddresses/prod-pip"
    "idle_timeout_in_minutes" = 4
    "ip_address" = "X.X.X.X"
    "ip_version" = "IPv4"
    "location" = "westus"
    "name" = "prod-pip"
    "public_ip_address_allocation" = "Static"
    "resource_group_name" = "YYYY"
    "sku" = "Basic"
    "tags" = {
      "environment" = "prod"
    }
    "zones" = []
  }
}
```

27.  You patted yourself on the back! Great job!


#### Clean up
1. Run
```
terraform init -backend-config="configs/prod/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY"
```
2. Run `terraform destroy -var-file="providers.tfvars"` to destroy your current target architecture
1. Run
```
terraform init -backend-config="configs/dev/backend.tfvars" -backend-config="access_key=$env:ARM_ACCESS_KEY"
```
2. Run `terraform destroy -var-file="providers.tfvars"` to destroy your current target architecture

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