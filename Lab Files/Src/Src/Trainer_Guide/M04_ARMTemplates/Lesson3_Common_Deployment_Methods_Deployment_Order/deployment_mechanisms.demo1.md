---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo 1 - Deployment Mechanisms
description: 115-145 characters including spaces. This abstract displays in the search result.
author: CHDAFNI-MSFT
ms.author: CHDAFNI # Microsoft employees only
ms.date: 3/25/2019
ms.topic: article-type-from-white-list
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Demo 1 - Deployment Mechanisms

## Objective - Instructor: Show how the same template can be deployed multiple ways. Show flexibility of template reuse by changing parameters with each deployment

## Objective - Student: See diffferent methods of pushing a Template & Parameters to the Azure ARM fabric

### Prerequisites - Install Azure "Az" PowerShell modules

 ```PowerShell
(run PowerShell in elevated mode)
Install-Module -Name Az -Force
```

### Deploy template via Portal

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. (+) Create a resource -> search for "Template Deployment" - Create
1. Click "Build your own template in the editor"
1. Copy and paste the contents of the file "M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.json"
1. Create a new (or select existing) resource group "DeploymentMechanisms-RG"
1. Type in a value for department, example HumanResources
1. Select a value for netFrameworkVersion.
1. Agree to the terms and conditions and click Purchase
1. Navigate to the resource group "DeploymentMechanisms-RG" to see the newly created resources

### Deploy template file & parameter file via PowerShell

1. Open PowerShell
1. Deploy the coordinating template and parameter files. Note that the parameter values are:
    1. department: HumanResources
    1. netFrameworkVersion: v4.0

```PowerShell
Import-Module -Name Az
Add-AzAccount

# Optionally select the correct subscription
# Get-AzSubscription | Out-GridView -OutputMode Single | Set-AzContext

New-AzResourceGroupDeployment -Name "PowerShell_1" `
    -ResourceGroupName "DeploymentMechanisms-RG" `
    -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.json' " `
    -TemplateParameterFile "FILE PATH TO 'M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.parameters.json' "
```

### Deploy template file via PowerShell with parameters in-line
```PowerShell
New-AzResourceGroupDeployment -Name "PowerShell_2" `
    -ResourceGroupName "DeploymentMechanisms-RG" `
    -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.json' " `
    -department "HumanResources" `
    -netFrameworkVersion "v4.0"
```

### Deploy template & parameters from URI via PowerShell

1. Navigate to the resource group "DeploymentMechanisms-RG"
1. Open the storage account
1. Click Storage Explorer
1. Expand Blob Containers and select templates
1. Upload the following files:
    1. M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.json
    1. M04_ARMTemplates\Lesson3_Common_Deployment_Methods_Deployment_Order\deployment_mechanisms.demo1.parameters.json
1. Select each file and use the Copy URL action to get the URI. Replace the values below and deploy.

```PowerShell
New-AzResourceGroupDeployment -Name "PowerShell_3" `
    -ResourceGroupName "DeploymentMechanisms-RG" `
    -TemplateUri "Replace with deployment_mechanisms.demo1.json URI" `
    -TemplateParameterUri "Replace with deployment_mechanisms.demo1.parameters.json URI"
```