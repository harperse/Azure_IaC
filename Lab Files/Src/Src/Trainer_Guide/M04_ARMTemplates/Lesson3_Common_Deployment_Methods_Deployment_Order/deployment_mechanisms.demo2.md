---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo 2 - Deployment Mechanisms
description: 115-145 characters including spaces. This abstract displays in the search result.
author: MPASCO-MSFT
ms.author: MPASCO # Microsoft employees only
ms.date: 5/8/2019
ms.topic: article-type-from-white-list
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Demo 2 - Deployment Mechanisms

## Objective - Instructor: Show how to use nested and linked templates

## Objective - Student: See the benefits of nested and linked templates and how to deploy them

### Prerequisites - Install Azure "Az" PowerShell modules

 ```PowerShell
(run PowerShell in elevated mode)
Install-Module -Name Az -Force
```

### Review Template structure
1. Open "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo2.json"
1. Show the first resource which is a nested template for deploying a Log Analytics workspace.
    1. Point out the resourceGroup property that will affect where the resource is deployed.
1. Show the second resource which is a linked template for deploying network resources.
    1. The templateLink URI property should point to a variable which resolves to an Azure Quick Start at [https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-nic-publicip-dns-vnet/azuredeploy.json](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-nic-publicip-dns-vnet/azuredeploy.json). Open the link to show the template that will be deployed.
    1. Point out the inline parameters which will be passed to the linked template


### Deploy template file via PowerShell with parameters in-line

```PowerShell
Import-Module -Name Az
Add-AzAccount

# Optionally select the correct subscription
# Get-AzSubscription | Out-GridView -OutputMode Single | Set-AzContext

#Create supporting resource groups
New-AzResourceGroup -Name "RG-A" -Location "East US"
New-AzResourceGroup -Name "RG-B" -Location "East US"
New-AzResourceGroup -Name "RG-C" -Location "East US"

#Deploy template
New-AzResourceGroupDeployment `
    -Name "LinkedTemplate" `
    -ResourceGroupName "RG-A" `
    -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo2.json' " `
    -department "HumanResources" `
    -logAnalyticsRGName "RG-C" `
    -vnetRGName "RG-B" `
    -vnetAddressPrefix "10.0.0.0/16" `
    -subnetPrefix "10.0.0.0/24"
```

### Review created resources

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group "RG-A".
    1. Notice how there are no resources deployed here
    1. Click "Deployments" under the "Settings" section
    1. Open the "LinkedTemplate" deployment and show the two children resources which are the nested and linked template deployments
1. Navigate to the resource group "RG-B".
    1. Review the network resources deployed here
    1. Click "Deployments" under the "Settings" section
    1. Open the "VNetDeployment" deployment and show the Inputs and Template section
1. Navigate to the resource group "RG-C".
    1. Review the Log Analytics resource deployed here
    1. Click "Deployments" under the "Settings" section
    1. Open the "LogAnalyticsDeployment" deployment and show the Inputs and Template section. Notice there are no Inputs and that the dynamic values were injected into the template itself