---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo 1 - Advanced Template Architecting
description: 115-145 characters including spaces. This abstract displays in the search result.
author: MPASCO-MSFT
ms.author: MPASCO # Microsoft employees only
ms.date: 5/16/2019
ms.topic: article-type-from-white-list
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Demo 1 - Advanced Template Architecting

## Objective - Instructor: Show how a template can be made more dynamic by using parameters as objects vs. strings

### Review and Deploy Unoptimized Template
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.unoptimized.template.json' in Visual Studio Code
1. Examine how the template can be used to create a VNet with two DNS servers and two subnets
1. Note how all of the parameters are string values and that the VNet name must be supplied.
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.unoptimized.parameters.json' in Visual Studio Code
1. Note how all of the values supplied here are strings, matching the parameter definition in the template.
1. Deploy the unoptimized template

    ```PowerShell
    New-AzResourceGroupDeployment -Name "UnoptimizedVNet" `
        -ResourceGroupName "YOUR_RG_HERE" `
        -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.unoptimized.template.json' " `
        -TemplateParameterFile "FILE PATH TO 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.unoptimized.parameters.json' " `
        -Mode Incremental
    ```

1. Open the Azure Portal
1. Navigate to the resource group
1. Examine the newly created VNet
1. Ask the class how would they add another DNS server or subnet using the unoptimized template. Explain that it is not possible to do so without modifying the template.

### Review and Deploy Optimized Template
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.optimized.template.json' in Visual Studio Code
1. Examine the differences from the unoptimized template
   1. VNet name is dynamically generated based on the project and environment values
   1. DNS servers are pulled from an array in a single object which doesn't limit the total number
   1. Subnets are created via a property iteration copy loop which doesn't limit the total number
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.optimized.parameters.json' in Visual Studio Code
1. Review how vnetObject is one large object with many sub properties
   1. dnsServers and Subnets are both arrays allowing for more or less values than initially defined
1. Deploy the optimized template

    ```PowerShell
    New-AzResourceGroupDeployment -Name "OptimizedVNet" `
        -ResourceGroupName "YOUR_RG_HERE" `
        -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.optimized.template.json' " `
        -TemplateParameterFile "FILE PATH TO 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo1.optimized.parameters.json' " `
        -Mode Incremental
    ```
1. Open the Azure Portal
1. Navigate to the resource group
1. Examine the newly created VNet
1. Modify demo1.optimized.parameters.json to change the number of DNS servers and subnets
1. Redeploy the optimized template
1. Examine the updated VNet to review the changes
1. Explain to the class how using objects and arrays do not force you to a set number of resources like the string method did in the unoptimized template