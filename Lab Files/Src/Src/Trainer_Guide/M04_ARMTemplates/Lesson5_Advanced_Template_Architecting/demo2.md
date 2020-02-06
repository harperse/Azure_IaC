---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo 2 - Advanced Template Architecting
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
# Demo 2 - Advanced Template Architecting

## Objective - Instructor: Show how a template can reference a secret secured in an Azure Key Vault

### Review Template and Unsecured Parameters File
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo2.template.json' in Visual Studio Code
1. Examine how the `adminPassword` parameter has a type of `SecureString`
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo2.unsecured.parameters.json' in Visual Studio Code
1. Note how the value of `adminPassword` is shown in plain text. Explain that secrets should not be stored in code but that they must be stored somewhere for automated deployments.

### Deploy Key Vault
1. Use PowerShell to deploy a new Key Vault and add a secret

    ```PowerShell
    $keyVaultName = "kv-$(Get-Random)"
    $rgName = "YOUR_RG_HERE"
    $secretName = "SQLAdminPassword"
    $secret = "mySuperSecretPassword@123"

    $rg = Get-AzResourceGroup -Name $rgName
    $keyVault = New-AzKeyVault `
        -Name $keyVaultName `
        -ResourceGroupName $rg.ResourceGroupName `
        -Location $rg.Location `
        -EnabledForTemplateDeployment
    $secureSecret = ConvertTo-SecureString -String $secret -AsPlainText -Force
    $kvSecret = Set-AzKeyVaultSecret `
        -VaultName $keyVault.VaultName `
        -SecretName $secretName `
        -SecretValue $secureSecret
    Write-Output $keyVault.ResourceId
    ```

1. Note that the Key Vault must be deployed with `EnabledForTemplateDeployment` in order for it to be referenced by an ARM template deployment
1. Record the Resource ID for the Key Vault output at the end of the script

### Update Secured Parameters File and Deploy Template
1. Open 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo2.secured.parameters.json' in Visual Studio Code
1. Update the `id` value under the `keyVault` reference with the Resource ID output from the script in the last section
1. Ensure the `secretName` matches what was used in the script in the last section
1. Deploy the template with the secured parameter file

    ```PowerShell
    New-AzResourceGroupDeployment -Name "SecuredDeployment" `
        -ResourceGroupName "YOUR_RG_HERE" `
        -TemplateFile "FILE PATH TO 'M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo2.template.json' " `
        -TemplateParameterFile "M04_ARMTemplates\Lesson5_Advanced_Template_Architecting\demo2.secured.parameters.json' " `
        -Mode Incremental
    ```
1. Open the Azure Portal
1. Navigate to the resource group
1. Open the deployment and note how the input value for `adminPassword` is still null. Explain that using a secret stored in a Key Vault allows for automated deployments while keeping secrets out of code.
