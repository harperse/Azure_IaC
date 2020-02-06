---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo - Overview of Azure Templates
description: 115-145 characters including spaces. This abstract displays in the search result.
author: CHDAFNI-MSFT
ms.author: CHDAFNI # Microsoft employees only
ms.date: 3/6/2019
ms.topic: article-type-from-white-list
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Demo - Overview of Azure Templates

## Objective - Instructor: Deploy the slide deck presented VNet template through Azure Portal and Portal

## Objective - Student: See a method of pushing a Template to the Azure ARM fabric

### Prerequisites - Install Azure "Az" PowerShell modules

 ```PowerShell
(run PowerShell in elevated mode)
Install-Module -Name Az -Force
```

### Deploy template via Portal

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. (+) Create a resource -> search for "Template Deployment" - Create
1. Click "Build your own template in the editor"
    1. Be sure to point out and explain the Github quickstart repository and how those same templates can be pulled in from the dropdown menu or you can load your own template
1. Either copy and paste the contents of the file "M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.json" or click "load file". Show students both methods load the file
1. Point out the visual representation of the JSON via the JSON outline on the left hand side (which shows the parameters, variables, and resources). Click "Save" since no changes need to be made
1. Create a new (or select existing) resource group "Sandbox-RG"
1. Type in values for the 2 parameters. Examples:
    1. Department: HumanResources
    1. Vnet Address Prefix: 10.11.12.0/24
1. Click the "Edit Parameters" button
    1. Explain how parameter values can be filled in multiple ways. The portal "fill in the blank" is 1 method. A parameter file (Which is what you currently have open) is another method. You'll notice the Azure Portal has also created the parameter file with your previously entered values so you can re-use it. Click Save.
1. Agree to the terms and conditions and click Purchase
    1. Explain that the "Purchase" button is generic since anything the template deploys is a chargeable item (even if you're deploying free resources such as VNets)
1. Navigate to the resource group "Sandbox-RG".
    1. Show the VNet that was just deployed including inspecting the AddressSpace attribute
1. Click "Deployments" under the "Settings" section
1. Select your deployment (likely named "Microsoft.Template")
    1. Explain that the deployment progress is shown which explains what is in progress, what's failed, and what's successfully deployed.
    1. The "history" of what template was pushed is kept and stored within the confines of the resource group
        1. Click "Template" to show that Azure kept a copy of the template that was pushed

### Deploy template via PowerShell
#### This method will be shown again in a later module but in more detail

```PowerShell
Add-AzAccount

# Optionally select the correct subscription
# Get-AzSubscription | Out-GridView -OutputMode Single | Set-AzContext

## Show that the parameters could be filled in via PowerShell flags OR a file path to the parameter file (or even URL)


#Method 1 - parameter values provided at time of deployment
New-AzResourceGroupDeployment -Name "VNet_Department" -ResourceGroupName "FILL ME IN" `
-TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.json' " `
-Department PayRoll -VnetAddressPrefix "10.11.13.0/24" -Verbose

#Method 2 - parameter values provided from file
New-AzResourceGroupDeployment -Name "VNet_Department" -ResourceGroupName "FILL ME IN" `
-TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.json' " `
-TemplateParameterFile "FILE PATH TO 'M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.parameters.json' " -Verbose



# Examples:
# New-AzResourceGroupDeployment -Name "VNet_Department" -ResourceGroupName "Sandbox-RG" `
# -TemplateFile "C:\labs\M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.json" `
# -Department PayRoll -VnetAddressPrefix "10.11.13.0/24" -Verbose
#
# New-AzResourceGroupDeployment -Name "VNet_Department" -ResourceGroupName "Sandbox-RG" `
# -TemplateFile "C:\labs\M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.json" `
# -TemplateParameterFile "C:\labs\M04_ARMTemplates\Lesson1_Overview_of_Azure_Templates\demo.parameters.json" -Verbose

```

1. Navigate to the resource group "Sandbox-RG".
    1. Show the VNet that was just deployed including inspecting the AddressSpace attribute
1. Click "Deployments" under the "Settings" section
1. Select your deployment (likely named "VNet_Department")
    1. Explain that the deployment progress is shown which explains what is in progress, what's failed, and what's successfully deployed.
    1. The "history" of what template was pushed is kept and stored within the confines of the resource group
        1. Click "Template" to show that Azure kept a copy of the template that was pushed
