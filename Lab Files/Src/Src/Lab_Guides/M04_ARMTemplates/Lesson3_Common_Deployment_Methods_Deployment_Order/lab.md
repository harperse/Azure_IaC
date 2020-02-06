---
# This basic template provides core metadata fields for Markdown articles on docs.microsoft.com.

# Mandatory fields.
title: Lab - ARM Templates - Common Deployment Methods & Deployment Order
description: 115-145 characters including spaces. This abstract displays in the search result.
author: MPASCO
ms.author: MPASCO # Microsoft employees only
ms.date: 5/8/2019
ms.topic: AzureTemplate-Lab
# Use ms.service for services or ms.prod for on-prem products. Remove the # before the relevant field.
# ms.service: service-name-from-white-list
# ms.prod: product-name-from-white-list

# Optional fields. Don't forget to remove # if you need a field.
# ms.custom: can-be-multiple-comma-separated
# ms.reviewer: MSFT-alias-of-reviewer
# manager: MSFT-alias-of-manager-or-PM-counterpart
---
# Lab 1 - ARM Templates - Common Deployment Methods & Deployment Order

## Prerequisites:
   - Install Visual Studio Code
     - [Windows](https://code.visualstudio.com/docs/setup/windows)
     - [macOS](https://code.visualstudio.com/docs/setup/mac)
     - [Linux](https://code.visualstudio.com/docs/setup/linux)
   - Install PowerShell
     - [Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell)
     - [macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos)
     - [Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux)
   - [Install the Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
   - Install Extensions
     - [Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
     - [Azure Resource Manager Snippets](https://marketplace.visualstudio.com/items?itemName=samcogan.arm-snippets)

## Create ARM template
### Create ARM template skeleton
1. Launch Visual Studio Code
1. Create a new file named DeploymentMethods.template.json and edit in Visual Studio Code
1. Type `arm!` and press `Enter` to insert the ARM template skeleton code snippet

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {},
        "variables": {},
        "resources": [],
        "outputs": {}
    }
    ```

### Add parameters and variables
1. Using the `arm-parameter` snippet, add the following parameters to the `"parameters": {},` section with descriptions of your choice
   1. `"environment"`
   1. `"projectName"`
    
    ```json
    "parameters": {
        "environment": {
            "type": "string",
            "metadata": {
                "description": "Environment (Dev/QA/Prod)"
            }
        },
        "projectName": {
            "type": "string",
            "metadata": {
                "description": "Project Name"
            }
        }
    },
    ```

1. Add the following variables and values to the `"variables": {},` section
   1. `"storageName": "[uniqueString(subscription().subscriptionId)]"`
   1. `"vnetName": "[concat('VNet-', parameters('projectName'), '-', parameters('environment'))]"`

    ```json
    "variables": {
        "storageName": "[uniqueString(subscription().subscriptionId)]",
        "vnetName": "[concat('VNet-', parameters('projectName'), '-', parameters('environment'))]"
    },
    ```

### Add storage account resource
1. Using the `arm-stg` snippet, add a storage account resource to the `"resources": [],` section
1. Change the values of `"name"` and `"displayName"` from `StorageAccount1` to `"[variables('storageName')]"`
   
   ```json
   "resources": [
    {
        "type": "Microsoft.Storage/storageAccounts",
        "apiVersion": "2018-07-01",
        "name": "[variables('storageName')]",
        "location": "[resourceGroup().location]",
        "tags": {
            "displayName": "[variables('storageName')]"
        },
        "sku": {
            "name": "Standard_LRS"
        },
        "kind": "StorageV2"
    }
   ],
   ```

1. Add a blob container child resource to the storage account resource after the `"kind": "StorageV2"`. There is not an ARM snippet for this child resource so use the following code block:
   
   ```json
    {
        "type": "Microsoft.Storage/storageAccounts",
        "apiVersion": "2018-07-01",
        "name": "[variables('storageName')]",
        "location": "[resourceGroup().location]",
        "tags": {
            "displayName": "[variables('storageName')]"
        },
        "sku": {
            "name": "Standard_LRS"
        },
        "kind": "StorageV2"
    }
   ```

1. The full storage account resource should look as follows:
   
   ```json
    {
        "type": "Microsoft.Storage/storageAccounts",
        "apiVersion": "2018-07-01",
        "name": "[variables('storageName')]",
        "location": "[resourceGroup().location]",
        "tags": {
            "displayName": "[variables('storageName')]"
        },
        "sku": {
            "name": "Standard_LRS"
        },
        "kind": "StorageV2",
        "resources": [
            {
                "name": "default/templates",
                "type": "blobServices/containers",
                "apiVersion": "2018-07-01",
                "dependsOn": [
                    "[variables('storageName')]"
                ],
                "properties": {
                    "publicAccess": "Blob"
                }
            }
        ]
    }
   ```

### Add virtual network resource
1. Using the `arm-vn` snippet, add a virtual network resource to the `"resources": [],` section
1. Change the values of `"name"` and `"displayName"` from `"VirtualNetwork1"` to `"[variables('vNetName')]"`
   
   ```json
   {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2018-08-01",
      "name": "[variables('vnetName')]",
      "location": "[resourceGroup().location]",
      "tags": {
          "displayName": "[variables('vnetName')]"
      },
      "properties": {
          "addressSpace": {
              "addressPrefixes": [
                  "10.0.0.0/16"
              ]
          },
          "subnets": [
              {
                  "name": "Subnet-1",
                  "properties": {
                      "addressPrefix": "10.0.0.0/24"
                  }
              },
              {
                  "name": "Subnet-2",
                  "properties": {
                      "addressPrefix": "10.0.1.0/24"
                  }
              }
          ]
      }
   }
   ```


### Review completed ARM template
The completed ARM template should look as follows:
   
   ```json
   {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "environment": {
            "type": "string",
            "metadata": {
                "description": "Environment (Dev/QA/Prod)"
            }
        },
        "projectName": {
            "type": "string",
            "metadata": {
                "description": "Project Name"
            }
        }
    },
    "variables": {
        "storageName": "[uniqueString(subscription().subscriptionId)]",
        "vnetName": "[concat('VNet-', parameters('projectName'), '-', parameters('environment'))]"
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2018-07-01",
            "name": "[variables('storageName')]",
            "location": "[resourceGroup().location]",
            "tags": {
                "displayName": "[variables('storageName')]"
            },
            "sku": {
                "name": "Standard_LRS"
            },
            "kind": "StorageV2",
            "resources": [
                {
                    "name": "default/templates",
                    "type": "blobServices/containers",
                    "apiVersion": "2018-07-01",
                    "dependsOn": [
                        "[variables('storageName')]"
                    ],
                    "properties": {
                        "publicAccess": "Blob"
                    }
                }
            ]
        },
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2018-08-01",
            "name": "[variables('vnetName')]",
            "location": "[resourceGroup().location]",
            "tags": {
                "displayName": "[variables('vnetName')]"
            },
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "10.0.0.0/16"
                    ]
                },
                "subnets": [
                    {
                        "name": "Subnet-1",
                        "properties": {
                            "addressPrefix": "10.0.0.0/24"
                        }
                    },
                    {
                        "name": "Subnet-2",
                        "properties": {
                            "addressPrefix": "10.0.1.0/24"
                        }
                    }
                ]
            }
        }
    ],
    "outputs": {}
   }
   ```

## Deploy ARM template via Portal
1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. (+) Create a resource -> search for "Template Deployment" - Create
1. Click "Build your own template in the editor"
1. Copy and paste the contents of the newly created DeploymentMethods.template.json file
1. Select your existing resource group
1. Enter a value for `environment`
1. Set the value of `projectName` to `DeploymentMethod1`
1. Agree to the terms and conditions and click Purchase
1. Navigate to the resource group to see the newly created resources

## Deploy template file & parameter file via PowerShell
### Create parameter file
1. Create a new file named DeploymentMethod2.parameters.json and edit in Visual Studio Code
1. Type `armp!` and press `Enter` to insert the ARM parameters skeleton code snippet
1. Using the `arm-paramvalue` snippet, add the following parameters to the `"parameters": {},` section
   1. `"environment"`
      1. Use a value of your choice
   1. `"projectName"`
      1. Use a value of `"DeploymentMethod2"`
1. The completed ARM parameter file should look as follows:
   ```json
   {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "environment": {
            "value": "dev"
        },
        "projectName": {
            "value": "DeploymentMethod2"
        }
    }
   }
   ```

### Deploy with PowerShell
1. Open PowerShell
1. Change directories to the folder containing the ARM template and parameters files
1. Run the following PowerShell commands to deploy the template

   ```PowerShell
   Import-Module Az
   Add-AzAccount
   New-AzResourceGroupDeployment -Name 'DeploymentMethod2' -ResourceGroupName 'YOUR_RG_HERE'  -TemplateFile '.\DeploymentMethods.template.json' -TemplateParameterFile  '.\DeploymentMethod2.parameters.json' -Mode Incremental
   ```

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group to see the newly created resources

## Deploy template file via PowerShell with parameters in-line
1. Run the following PowerShell commands to deploy the template with parameters in-line
   ```PowerShell
   New-AzResourceGroupDeployment -Name 'DeploymentMethod3' -ResourceGroupName 'YOUR_RG_HERE' -TemplateFile '.\DeploymentMethods.template.json' -Mode Incremental -environment 'YOUR_VALUE_HERE' -projectName 'DeploymentMethod3'
   ```

1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group to see the newly created resources

## Deploy template & parameters from URI via PowerShell
### Create DeploymentMethod4.parameters.json
1. Edit DeploymentMethod2.parameters.json in Visual Studio Code
1. Update `"projectName"` with a value of `"DeploymentMethod4"`
1. Save the file as DeploymentMethod4.parameters.json

### Upload files to blob storage
In order to deploy the template & parameters from URI, they first must be made available at a public accessible URL. We will use the blob container child resource created with Azure Storage account from the last deployment to host these files.
1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group
1. Open the storage account
1. Click Storage Explorer
1. Expand Blob Containers and select templates
1. Upload the following files:
    1. DeploymentMethods.template.json
    1. DeploymentMethod4.parameters.json
1. Select each file and use the Copy URL. Use these values in the PowerShell step below

### Deploy with PowerShell
```PowerShell
New-AzResourceGroupDeployment -Name 'DeploymentMethod4' -ResourceGroupName 'YOUR_RG_HERE' -TemplateUri "DeploymentMethods.template.json_URL_HERE" -TemplateParameterUri "DeploymentMethod4.parameters.json_URL_HERE" -Mode Incremental
```

# Lab 2 - ARM Templates - Common Deployment Methods & Deployment Order - Linked / Nested Templates
## Create ARM template
### Create ARM template skeleton
1. Launch Visual Studio Code
1. Create a new file named DeploymentMethods.LinkedNested.template.json and edit in Visual Studio Code
1. Type `arm!` and press `Enter` to insert the ARM template skeleton code snippet

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {},
        "variables": {},
        "resources": [],
        "outputs": {}
    }
    ```

### Add parameters and variables
1. Using the `arm-parameter` snippet, add the following parameters to the `"parameters": {},` section with descriptions of your choice
   1. `"environment"`
   1. `"projectName"`
    
    ```json
    "parameters": {
        "environment": {
            "type": "string",
            "metadata": {
                "description": "Environment (Dev/QA/Prod)"
            }
        },
        "projectName": {
            "type": "string",
            "metadata": {
                "description": "Project Name"
            }
        }
    },
    ```
1. Add the following variables and values to the `"variables": {},` section
   1. `"availSetName": "[concat('AvailSet-', parameters('projectName'), '-', parameters('environment'))]"`
   1. `"linkedTemplateURI": "DeploymentMethods.template.json_URL_HERE"`
      1. Use the blob storage URL of DeploymentMethods.template.json from the previous lab

    ```json
    "variables": {
        "availSetName": "[concat('AvailSet-', parameters('projectName'), '-', parameters('environment'))]",
        "linkedTemplateURI": "DeploymentMethods.template.json_URL_HERE"
    },
    ```

### Add linked template resource
1. Using the `arm-nest` snippet, add a linked template resource to the `"resources": [],` section
1. Change the value of `"name"` and from `NestedDeployment1` to `"LinkedTemplate"`
1. Remove the `"tags": {}` section
2. Update the value of `"uri"` from `"[concat(parameters('_artifactsLocation'), '/NestedTemplates/${NestedTemplate.json}', parameters('_artifactsLocationSasToken'))]"` to `"[variables('linkedTemplateURI')]"`
3. Using the `arm-paramvalue` snippet, add the following parameters to the `"parameters": {},` section of the **linked template resource**,
   1. `"environment"`
      1. `"value": "[parameters('environment')]"`
   2. `"projectName"`
      1. `"value": "[parameters('projectName')]"`
   
   ```json
   "resources": [
        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2018-05-01",
            "name": "LinkedTemplate",
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('linkedTemplateURI')]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "environment": {
                        "value": "[parameters('environment')]"
                    },
                    "projectName": {
                        "value": "[parameters('projectName')]"
                    }
                }
            }
        }
    ],
    ```

### Add nested resource
1. Using the `arm-nest` snippet, add a nested resource to the `"resources": [],` section
1. Change the value of `"name"` and from `NestedDeployment1` to `"NestedDeployment"`
1. Remove the `"tags": {}` section
1. Remove the `"templateLink": {}` and `"parameters": {}` sections from the nested resource's `"properties": {}` section
1. Add a new `"template": {}` section to the nested resource's `"properties": {}` section
1. Inside the `"template": {}` section, add the following properties
   1. `"$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"`
   1. `"contentVersion": "1.0.0.0"`
1. Inside the `"template": {}` section, add a `"resources": []` array below the two properties above
   
   ```json
   {
       "type": "Microsoft.Resources/deployments",
       "apiVersion": "2018-05-01",
       "name": "NestedDeployment",
       "properties": {
           "mode": "Incremental",
           "template": {
               "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
               "contentVersion": "1.0.0.0",
               "resources": []
           }
       }
   }
   ```

1. Using the `arm-avail` snippet, add an Availability Set resource to the `"resources": [],` section of the **nested resource**
1. Change the values of `"name"` and `"displayName"` from `AvailabilitySet1` to `"[variables('availSetName')]"`

### Review completed ARM template
The completed ARM template should look as follows:
   
   ```json
   {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "environment": {
                "type": "string",
                "metadata": {
                    "description": "Environment (Dev/QA/Prod)"
                }
            },
            "projectName": {
                "type": "string",
                "metadata": {
                    "description": "Project Name"
                }
            }
        },
        "variables": {
            "availSetName": "[concat('AvailSet-', parameters('projectName'), '-', parameters('environment'))]",
            "linkedTemplateURI": "DeploymentMethods.template.json_URL_HERE"
        },
        "resources": [
            {
                "type": "Microsoft.Resources/deployments",
                "apiVersion": "2018-05-01",
                "name": "LinkedTemplate",
                "properties": {
                    "mode": "Incremental",
                    "templateLink": {
                        "uri": "[variables('linkedTemplateURI')]",
                        "contentVersion": "1.0.0.0"
                    },
                    "parameters": {
                        "environment": {
                            "value": "[parameters('environment')]"
                        },
                        "projectName": {
                            "value": "[parameters('projectName')]"
                        }
                    }
                }
            },
            {
                "type": "Microsoft.Resources/deployments",
                "apiVersion": "2018-05-01",
                "name": "NestedDeployment",
                "properties": {
                    "mode": "Incremental",
                    "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "resources": [
                            {
                                "type": "Microsoft.Compute/availabilitySets",
                                "apiVersion": "2015-06-15",
                                "name": "[variables('availSetName')]",
                                "location": "[resourceGroup().location]",
                                "tags": {
                                    "displayName": "[variables('availSetName')]"
                                },
                                "properties": {}
                            }
                        ]
                    }
                }
            }
        ],
        "outputs": {}
    }
   ```


## Deploy template and review deployments
1. Deploy DeploymentMethods.LinkedNested.template.json with a method of your choice.
   1. `"projectName"` should have a value of `"DeploymentMethod5"`
1. Login to the Azure Portal [https://portal.azure.com](https://portal.azure.com)
1. Navigate to the resource group
1. Click "Deployments" under the "Settings" section
1. Review the three deployments created by this deployment operation:
   1. Master deployment used for deploying DeploymentMethods.LinkedNested.template.json
   1. LinkedTemplate deployment
   1. NestedDeployment deployment