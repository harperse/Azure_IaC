---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Demo - Copy element and copyIndex( ) function
description: 115-145 characters including spaces. This abstract displays in the search result.
author: MPASCO-MSFT
ms.author: MPASCO # Microsoft employees only
ms.date: 3/22/2019
ms.topic: article-type-from-white-list
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Demo - Copy element and copyIndex( ) function

## Objective
- Use a copy element with
  - Resource iteration
  - Property iteration
  - Variable iteration
- Reference a copy loop as a dependency

### Prerequisites
- Install Visual Studio Code from https://code.visualstudio.com/
- Install Azure "Az" PowerShell module
- The `Azure Resource Manager Tools` and `Azure Resource Manager Snippets` extensions should be installed
- Have Azure subscription and authentication details ready

## Create ARM template file
### Create ARM template skeleton
1. Create a new file named template.json and edit in Visual Studio Code
1. Type `arm!` and press `Enter` to insert the ARM template skeleton code snippet

### Add parameters to the ARM template
1. Add the following parameters to the template's `"parameters": {},` section
   1. `projectName`
      1. `"type": "string"`

### Add variables to the ARM template
1. Add the following variables to the template's `"variables": {},` section
   1. `"vnetAddressPrefixes": ["10.0.0.0/16"]`
   1. `"subnetAddressPrefixes": ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]`
   
   ```json
   "variables": {
       "vnetAddressPrefixes": [
           "10.0.0.0/16"
       ],
       "subnetAddressPrefixes": [
           "10.0.0.0/24",
           "10.0.1.0/24",
           "10.0.2.0/24"
       ]
   }
   ```

### Add a Virtual Network resource to the ARM template
1. Move your cursor in between the `[]` brackets on the line containing `"resources": [],` and press `Enter` to create a new line
1. Type `arm-vn` and press `Enter` to insert a new Virtual Network resource snippet
1. Change the value of `"name`" from `"VirtualNetwork1"` to `"[concat('Vnet-', parameters('projectName'))]"`
1. Delete the `"tags": {}` object block
1. Change the value of `addressPrefixes` within `addressSpace` from `["10.0.0.0/16"]` to `"[variables('vnetAddressPrefixes')]"`
   1. **Note** because you are adding a variable that is an array that you must remove the array `[]` from the `addressPrefixes`.
   
      ```json
      "addressSpace": {
          "addressPrefixes": "[variables('vnetAddressPrefixes')]"
      }
      ```

1. Delete the `"subnets": []` array block
1. In place of the `"subnets": []` array block, add the following property iteration `"copy": []` array block
   
   ```json
   "copy": [
       {
           "name": "subnets",
           "count": "[length(variables('subnetAddressPrefixes'))]",
           "input": {
               "name": "[concat('Subnet-', parameters('projectName'), '-', copyIndex('subnets'))]",
               "properties": {
                   "addressPrefix": "[variables('subnetAddressPrefixes')[copyIndex('subnets')]]"
               }
           }
       }
   ]
   ```

1. At this point, the ARM template should look as follows:
   
   ```json
   {
       "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
       "contentVersion": "1.0.0.0",
       "parameters": {
           "projectName": {
               "type": "string"
           }
       },
       "variables": {
           "vnetAddressPrefixes": [
               "10.0.0.0/16"
           ],
           "subnetAddressPrefixes": [
               "10.0.0.0/24",
               "10.0.1.0/24",
               "10.0.2.0/24"
           ]
       },
       "resources": [
           {
               "type": "Microsoft.Network/virtualNetworks",
               "apiVersion": "2018-08-01",
               "name": "[concat('Vnet-', parameters('projectName'))]",
               "location": "[resourceGroup().location]",
               "properties": {
                   "addressSpace": {
                       "addressPrefixes": "[variables('vnetAddressPrefixes')]"
                   },
                   "copy": [
                       {
                           "name": "subnets",
                           "count": "[length(variables('subnetAddressPrefixes'))]",
                           "input": {
                               "name": "[concat('Subnet-', parameters('projectName'), '-', copyIndex('subnets'))]",
                               "properties": {
                                   "addressPrefix": "[variables('subnetAddressPrefixes')[copyIndex('subnets')]]"
                               }
                           }
                       }
                   ]
               }
           }
       ],
       "outputs": {}
   }
   ```

### Add a Network Interface resource to the ARM template
1. Type `arm-nic` and press `Enter` to insert a new Network Interface resource snippet
1. Change the value of `"name`" from `"NetworkInterface1"` to `"[concat('NIC-', parameters('projectName'), '-', copyIndex())]"`
1. Delete the `"tags": {}` object block
1. Change `"dependsOn"` from `"Microsoft.Network/virtualNetworks/VirtualNetwork1"` to `"[concat('Microsoft.Network/virtualNetworks/Vnet-', parameters('projectName'))]"`
1. Below the `"dependsOn"` array block, add the following resource iteration `"copy": {}` block
   
   ```json
   "copy": {
       "name": "nicLoop",
       "count": "[length(variables('subnetAddressPrefixes'))]"
   }
   ```

1. Change the value of `id` within `subnet` to `"[concat(resourceId('Microsoft.Network/virtualNetworks', concat('Vnet-', parameters('projectName'))), '/subnets/Subnet-', parameters('projectName'), '-', copyIndex())]"`

### Review completed ARM template
The completed ARM template should look as follows:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "projectName": {
            "type": "string"
        }
    },
    "variables": {
        "vnetAddressPrefixes": [
            "10.0.0.0/16"
        ],
        "subnetAddressPrefixes": [
            "10.0.0.0/24",
            "10.0.1.0/24",
            "10.0.2.0/24"
        ]
    },
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2018-08-01",
            "name": "[concat('Vnet-', parameters('projectName'))]",
            "location": "[resourceGroup().location]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": "[variables('vnetAddressPrefixes')]"
                },
                "copy": [
                    {
                        "name": "subnets",
                        "count": "[length(variables('subnetAddressPrefixes'))]",
                        "input": {
                            "name": "[concat('Subnet-', parameters('projectName'), '-', copyIndex('subnets'))]",
                            "properties": {
                                "addressPrefix": "[variables('subnetAddressPrefixes')[copyIndex('subnets')]]"
                            }
                        }
                    }
                ]
            }
        },
        {
            "type": "Microsoft.Network/networkInterfaces",
            "apiVersion": "2018-08-01",
            "name": "[concat('NIC-', parameters('projectName'), '-', copyIndex())]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[concat('Microsoft.Network/virtualNetworks/Vnet-', parameters('projectName'))]"
            ],
            "copy": {
                "name": "nicLoop",
                "count": "[length(variables('subnetAddressPrefixes'))]"
            },
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "privateIPAllocationMethod": "Dynamic",
                            "subnet": {
                                "id": "[concat(resourceId('Microsoft.Network/virtualNetworks', concat('Vnet-', parameters('projectName'))), '/subnets/Subnet-', parameters('projectName'), '-', copyIndex())]"
                            }
                        }
                    }
                ]
            }
        }
    ],
    "outputs": {}
}
```

### Deploy with PowerShell
1. Open PowerShell
1. Change directories to the folder containing the ARM template and parameters files
1. Run the following PowerShell commands to deploy the template

   ```PowerShell
   Import-Module Az
   Add-AzAccount
   New-AzResourceGroupDeployment -Name 'M04Lesson4' -ResourceGroupName 'YOUR_RG_HERE' -TemplateFile '.\template.json' -projectName 'M04Lesson4' -Mode Incremental
   ```

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group to see the newly created resources
1. Review the Virtual Network, Subnets and Network Interfaces created by the template. You should now have:
   1. A single Vnet named `Vnet-M04Lesson4` with an address space of `10.0.0.0/16`
   1. Three subnets
      1. `Subnet-M04Lesson4-0` with an address space of `10.0.0.0/24`
      1. `Subnet-M04Lesson4-1` with an address space of `10.0.1.0/24`
      1. `Subnet-M04Lesson4-2` with an address space of `10.0.2.0/24`
   1. Three network interfaces
      1. `NIC-M04Lesson4-0` joined to `Subnet-M04Lesson4-0`
      1. `NIC-M04Lesson4-1` joined to `Subnet-M04Lesson4-1`
      1. `NIC-M04Lesson4-2` joined to `Subnet-M04Lesson4-2`