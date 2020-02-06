---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo - Deployment Order
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
# Demo - Deployment Order

## Objective - Instructor: Show how deployment order can be set as part of code… in any order in the template file.

## Objective - Student: See how the deployment order is affected by dependencies

### Prerequisites - Install Azure "Az" PowerShell modules

 ```PowerShell
(run PowerShell in elevated mode)
Install-Module -Name Az -Force
```

### Review template structure

1. Open "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_order.demo.json"
1. Show the order of the resources in the template
    1. NSG
    1. VNet
    1. NIC
1. Explain that this is the order that resources will need to be deployed to succeed

### Deploy template file via PowerShell

```PowerShell
Import-Module -Name Az
Add-AzAccount

# Optionally select the correct subscription
# Get-AzSubscription | Out-GridView -OutputMode Single | Set-AzContext

#Create supporting resource group
New-AzResourceGroup -Name "DeploymentOrder" -Location "East US"

New-AzResourceGroupDeployment `
    -Name "DeploymentOrder" `
    -ResourceGroupName "DeploymentOrder" `
    -TemplateFile "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_order.demo.json' " `
    -Mode Incremental `
    -Verbose:$true
```

### Review errors and update template
1. The deployment should fail because the VNet attempts to provision before the NSG is ready and the NIC will attempt to deploy before the VNet/Subnet is ready
1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group "DeploymentOrder".
    1. Notice the failed Deployment and missing resources
1. Open "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_order.demo.json"
1. Inside of the `"Microsoft.Network/virtualNetworks"` resource, make a new line between `"location": "[resourceGroup().location]",` and `"properties": {`
    1. Add a dependency on the NSG by adding the following: `"dependsOn": ["[resourceId('Microsoft.Network/networkSecurityGroups', 'networkSecurityGroup1')]"],`
1. Inside of the `Microsoft.Network/networkInterfaces` resource, make a new line between `"location": "[resourceGroup().location]",` and `"properties": {`
    1. Add a dependency on the VNet by adding the following: `"dependsOn": ["[resourceId('Microsoft.Network/virtualNetworks', 'VirtualNetwork1')]"],`
1. Save the json file

### Deploy updated template file via PowerShell
```PowerShell
#Create supporting resource group
New-AzResourceGroup -Name "DeploymentOrder2" -Location "East US"

New-AzResourceGroupDeployment `
    -Name "DeploymentOrder2" `
    -ResourceGroupName "DeploymentOrder2" `
    -TemplateFile "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_order.demo.json' " `
    -Mode Incremental `
    -Verbose:$true
```