# Ansible and Azure

!IMAGE[full_msft_ansible.png](full_msft_ansible.png)

# Overview

Welcome to the *Ansible and Azure Infrastructure as Code* workshop.  This workshop is designed to get you familiar with how Ansible integrates with Azure to deploy and configure infrastucture.  While we will touch on some core Ansible topics as needed, the main focus is to show how to get the most of your automation and configuration management needs when deploying infrastructure into Azure.

# Labs

## Lab 1 - Installing and Configuring an Ansible Development Environment

> Please select **one** of the sub-labs below based on your development platform.

- [Windows](#lab-1a-windows-sub-lab)
- [Linux](#lab-1b-linux-sub-lab)
- [macOS](#lab-1c-macos-sub-lab)
- [Cloud Shell](#lab-1d-cloud-shell-sub-lab)

## [Lab 2 - Creating Azure Resources](#lab-02---creating-azure-resources-with-ansible)

## [Lab 3 - Dynamic Inventory with Azure](#lab-03---ansible-dynamic-inventory-azure)

## [Lab 4 - Ansible Vault and Azure KeyVault](#lab-04---securing-vault-password-with-keyvault)

# Lab 01: Installing and Configuring an Ansible Development Environment

## Lab 1A: Windows Sub-Lab

### Install Visual Studio Code for Windows  

1. Launch Microsoft Edge and browse to the [Visual Studio Code for Windows](https://aka.ms/win32-x64-user-stable) (https://aka.ms/win32-x64-user-stable) page.

    !IMAGE[windows_vscode_01.png](windows_vscode_01.png)

2. Click Run

    !IMAGE[windows_vscode_02.png](windows_vscode_02.png)

3. Click Next to start the VSCode Setup Wizard

      !IMAGE[windows_vscode_03.png](windows_vscode_03.png)

4. Accept the license agreement and click Next

      !IMAGE[windows_vscode_04.png](windows_vscode_04.png)

5. Verify/Change the installation folder and click Next

      !IMAGE[windows_vscode_05.png](windows_vscode_05.png)

6. Verify/Change the Start Menu folder and click Next

      !IMAGE[windows_vscode_06.png](windows_vscode_06.png)

7. Select Additional Tasks and then click Next

      !IMAGE[windows_vscode_07.png](windows_vscode_07.png)

8. Click Next on the Ready to Install screen

      !IMAGE[windows_vscode_08.png](windows_vscode_08.png)

9. Allow the installation of VSCode to complete

      !IMAGE[windows_vscode_00.png](windows_vscode_09.png)

10. Click Finish to exit the VSCode Setup Wizard

    !IMAGE[windows_vscode_10.png](windows_vscode_10.png)

### Install Node.js on Windows

1. Launch Microsoft Edge and browse to the [Node.js](https://nodejs.org) page.

    !IMAGE[windows_nodejs_01.png](windows_nodejs_01.png)

1. Click the "Recommended for Most Users" version.  The version may differ from what is shown in the screenshot below.

    !IMAGE[windows_nodejs_02.png](windows_nodejs_02.png)

1. Click Run

    !IMAGE[windows_nodejs_03.png](windows_nodejs_03.png)
  
1. Click Next to begin the Node.js Setup Wizard

    !IMAGE[windows_nodejs_04.png](windows_nodejs_04.png)
  
1. Accept the license agreement and click Next

    !IMAGE[windows_nodejs_05.png](windows_nodejs_05.png)

1. Click next on the Destination Folder screen

    !IMAGE[windows_nodejs_06.png](windows_nodejs_06.png))
  
1. Click Next on the Custom Setup screen

    !IMAGE[windows_nodejs_07.png](windows_nodejs_07.png)
  
1. Click Install on the Node.js Setup screen

    !IMAGE[windows_nodejs_08.png](windows_nodejs_08.png)
  
1. Click Yes on the User Account Control screen

    !IMAGE[windows_nodejs_09.png](windows_nodejs_09.png)
  
1. Click Finish to exit the Setup Wizard

    !IMAGE[windows_nodejs_10.png](windows_nodejs_10.png)

### Install VSCode Extensions on Windows

#### Install the [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) Extension  

> [!NOTE]
> On Windows, the Azure Account Extension requires that Node.js v6 or later be installed.
  
1. Launch VSCode and select extensions from the left side menu.
2. Type `Azure Account` in the search box
3. Click Install

    !IMAGE[windows_extension_azure_account_01.png](windows_extension_azure_account_01.png)  

#### Install the [Ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible) Extension

> [!NOTE]
> This takes considerably longer to install than the Azure Account extension so be patient!

1. Launch VSCode and select extensions from the left side menu.
2. Type `Ansible` in the search box
3. Click Install

    
!IMAGE[windows_extension_ansible_01.png](windows_extension_ansible_01.png)

### Install the Windows Subsystem for Linux

> [!NOTE]
> These instructions will cover an apt based distro such as Ubuntu

1. Enable the Windows Subsystem for Linux optional feature

    1. Launch PowerShell as Administrator and run the following command

    ```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    ```

    1. Restart your computer when prompted.

1. Download the Ubuntu distro

    1. Launch PowerShell as Administrator and run the following commands

    ```
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.zip -UseBasicParsing
    ```

1. Extract the Ubuntu distro

     ```
    Expand-Archive ~/Ubuntu.zip ~/Ubuntu
    ```

1. Launch the Ubuntu distro

    ```
    ~/Ubuntu/ubuntu1804.exe
    ```

    > [!NOTE]
    > The initial launch will take several minutes!

1. Initialize the Ubuntu Distro

    > Take note of the username and password you choose as it will be needed during the labs.

    1. You will be prompted for a new UNIX username
    1. You will then be prompted for a new UNIX password
    1. Retype the new UNIX password
    1. You should see a conformation that the password was updated successfully and be presented with a bash prompt

1. Upgrade the list of packages for the Ubuntu Distro

    ```
    sudo apt-get update
    ```

1. Install upgraded packages for the Ubuntu Distro

    ```
    sudo apt-get upgrade -y
    ```

1. Install pip

    ```
    sudo apt-get -y install python-pip python-dev libffi-dev libssl-dev
    ```

1. Install Ansible

    ```
    pip install ansible[azure] --user
    ```

1. Add the Ansible install location to PATH

    ```
    echo 'PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    ```

1. Update PATH to include Ansible

    ```
    source .bashrc
    ```

1. Verify Ansible is installed correctly

    ```
    ansible --version
    ```

1. Configure VSCode to use WSL as an integrated Shell  

    1. Launch VSCode and click **View** in the menu bar and then click **Command Pallete...**

    2. Type `Terminal:Select Default Shell` and press enter
  
          !IMAGE[windows_wsl_vscode_default_terminal_01.png](windows_wsl_vscode_default_terminal_01.png)

    3. Select **WSL Bash C:\Windows\System32\wsl.exe**
  
          !IMAGE[windows_wsl_vscode_default_terminal_02.png](windows_wsl_vscode_default_terminal_02.png)

    4. Click **Terminal** in the menu bar and then select **New Terminal** from the drop down to launch a new WSL terminal within VSCode
  
          !IMAGE[windows_wsl_vscode_default_terminal_03.png](windows_wsl_vscode_default_terminal_03.png)

## Lab 1B: Linux Sub-Lab

### Installing VSCode on Linux

> [!NOTE]
> These instructions will cover an apt based distro such as Ubuntu

1. Launch a terminal window by pressing `Ctrl-Alt-T`

    !IMAGE[linux_vscode_01.png](linux_vscode_01.png)

1. Verify that the Microsoft signing key is not currently installed.

    ```
    apt-key list
    ```

    !IMAGE[linux_vscode_02.png](linux_vscode_02.png)

1. Add the Microsoft signing key to enable auto-updating of VSCode using Ubuntu's package manager.

    ```
    sudo apt-key adv --fetch-keys https://packages.microsoft.com/keys/microsoft.asc
    ```

    !IMAGE[linux_vscode_03.png](linux_vscode_03.png)

1. Verify that the Microsoft signing key is now installed.

    ```
    apt-key list
    ```

    !IMAGE[linux_vscode_04.png](linux_vscode_04.png)

1. Add the Microsoft VSCode repository to the package manager.

    ```
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    ```

    !IMAGE[linux_vscode_05.png](linux_vscode_05.png)

1. Install VSCode.

    ```
    sudo apt-get install code
    ```

    !IMAGE[linux_vscode_06.png](linux_vscode_06.png)

1. Verify VSCode installed properly.

    ```
    code
    ```

### Installing Node.js on Linux

> [!NOTE]
> These instructions will cover an apt based distro such as Ubuntu

1. Launch a terminal window by pressing `Ctrl-Alt-T`

    !IMAGE[linux_nodejs_01.png](linux_nodejs_01.png)

1. Install curl

    ```
    sudo apt-get install -y curl
    ```

    !IMAGE[linux_nodejs_02.png](linux_nodejs_02.png)

1. Add the NodeJs repository

      ```
    curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
    ```

    !IMAGE[linux_nodejs_03.png](linux_nodejs_03.png)

1. Install NodeJs

      ```
    sudo apt-get install -y nodejs
    ```

    !IMAGE[linux_nodejs_04.png](linux_nodejs_04.png)

1. Verify NodeJs was successfully installed

      ```
    node -v
    ```

    !IMAGE[linux_nodejs_05.png](linux_nodejs_05.png)

### Installing the VSCode Extensions on Linux

#### Install the [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) Extension

1. Launch a terminal window by pressing `Ctrl-Alt-T`

    !IMAGE[linux_extension_azure_account_01.png](linux_extension_azure_account_01.png)

1. Install the Azure Account Extension

    ```
    code --install-extension ms-vscode.azure-account
    ```

    !IMAGE[linux_extension_azure_account_02.png](linux_extension_azure_account_02.png)

1. Verify that the Azure Account Extension was installed successfully

    ```
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Azure Account extension is enabled.

        !IMAGE[linux_extension_azure_account_03.png](linux_extension_azure_account_03.png)

    1. Press `F1`, type `Azure: Sign In`, press `Return`

        !IMAGE[linux_extension_azure_account_04.png](linux_extension_azure_account_04.png)

    1. Select the account associated with your Azure Subscription

        !IMAGE[linux_extension_azure_account_05.png](linux_extension_azure_account_05.png)

    1. Close the browser window that displays the successful sign on message

        !IMAGE[linux_extension_azure_account_06.png](linux_extension_azure_account_06.png)

    1. Check the lower left corner of VSCode for Azure: followed by the account you signed in as.

        !IMAGE[linux_extension_azure_account_07.png](linux_extension_azure_account_07.png)

        > [!TIP]
        > Clicking the account name will bring up a list of subscriptions associated with that account

    1. Close VSCode

#### Install the [Ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible) Extension

1. Launch a terminal window by pressing `Ctrl-Alt-T`

    !IMAGE[linux_extension_ansible_01.png](linux_extension_ansible_01.png)

1. Install the Ansible Extension.

    ```
    code --install-extension vscoss.vscode-ansible
    ```

    !IMAGE[linux_extension_ansible_02.png](linux_extension_ansible_02.png)

1. Verify that the Ansible Extension was installed successfully.

    ```
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Ansible extension is enabled.

        !IMAGE[linux_extension_ansible_03.png](linux_extension_ansible_03.png)

## Lab 1C: macOS Sub-Lab

### Installing VSCode on macOS

> [!NOTE]
> These steps will cover the installation via Homebrew. If you do not have Homebrew installed, you can find the installation  instructions [here](https://brew.sh)

1. Launch a terminal window by pressing `⌘-T`

    !IMAGE[macos_vscode_01.png](macos_vscode_01.png)

1. Update brew

    ```
    brew update
    ```

    !IMAGE[macos_vscode_02.png](macos_vscode_02.png)

1. Tap the Caskroom/Cask repository on GitHub using HTTPS

    ```
    brew tap caskroom/cask
    ```

    !IMAGE[macos_vscode_03.png](macos_vscode_03.png)

1. Search all known Casks for VSCode

    ```
    brew search visual-studio-code
    ```

    !IMAGE[macos_vscode_04.png](macos_vscode_04.png)

1. Display information about the VSCode cask

    ```
    brew cask info visual-studio-code
    ```

    !IMAGE[macos_vscode_05.png](macos_vscode_05.png)

1. Install VSCode

    ```
    brew cask install visual-studio-code
    ```

    !IMAGE[macos_vscode_06.png](macos_vscode_06.png)

1. Verify VSCode was installed successfully

    ```
    code
    ```

    !IMAGE[macos_vscode_07.png](macos_vscode_07.png)

### Installing Node.js on macOS

> [!NOTE]
> These steps will cover installation via Homebrew. If you do not have Homebrew installed, you can find the installation instructions [here](https://brew.sh)

1. Launch a terminal window by pressing `⌘-T`

    !IMAGE[macos_nodejs_01.png](macos_nodejs_01.png)

1. Update brew

    ```
    brew update
    ```

    !IMAGE[macos_nodejs_02.png](macos_nodejs_02.png)

1. Install Node.js

    ```
    brew install node
    ```

    !IMAGE[macos_nodejs_03.png](macos_nodejs_03.png)

1. Verify NodeJs was successfully installed

      ```
    node -v
    ```

    !IMAGE[macos_nodejs_04.png](macos_nodejs_04.png)

### Installing the VSCode Extensions on macOS

#### Install the [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) Extension for VSCode

1. Launch a terminal window by pressing `⌘-T`

    !IMAGE[macos_extension_azure_account_01.png](macos_extension_azure_account_01.png)

1. Install the Azure Account Extension

    ```
    code --install-extension ms-vscode.azure-account
    ```

    !IMAGE[macos_extension_azure_account_02.png](macos_extension_azure_account_02.png)

1. Verify that the Azure Account Extension was installed

    ```
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Azure Account extension is enabled.

        !IMAGE[macos_extension_azure_account_03.png](macos_extension_azure_account_03.png)

    1. Press `F1`, type `Azure: Sign In`, press `Return`

        !IMAGE[macos_extension_azure_account_04.png](macos_extension_azure_account_04.png)

    1. Select the account associated with your Azure Subscription

        !IMAGE[macos_extension_azure_account_05.png](macos_extension_azure_account_05.png)

    1. Close the browser window that displays the successful sign on message

        !IMAGE[macos_extension_azure_account_06.png](macos_extension_azure_account_06.png)

    1. Check the lower left corner of VSCode for Azure: followed by the account you signed in as.

        !IMAGE[macos_extension_azure_account_07.png](macos_extension_azure_account_07.png)

        > [!TIP]
        > Clicking the account name will bring up a list of subscriptions associated with that account

    1. Close VSCode

#### Install the [Ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible) Extension for VSCode

1. Launch a terminal window by pressing `⌘-T`

    !IMAGE[macos_extension_ansible_01.png](macos_extension_ansible_01.png)

1. Install the Ansible Extension.

    ```
    code --install-extension vscoss.vscode-ansible
    ```

    !IMAGE[macos_extension_ansible_02.png](macos_extension_ansible_02.png)

1. Verify that the Ansible Extension was installed successfully.

    ```
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Ansible extension is enabled.

        !IMAGE[macos_extension_ansible_03.png](macos_extension_ansible_03.png)

## Lab 1D: Cloud Shell Sub-Lab

1. Access the Azure portal at [https://portal.azure.com](https://portal.azure.com)

2. Click the `Cloud Shell` icon in the upper right of the screen.

    !IMAGE[cloud_shell_01.png](cloud_shell_01.png)

3. Click `Show advanced settings`.

    !IMAGE[cloud_shell_02.png](cloud_shell_02.png)

4. Select the subscription and the Cloud Shell region then provide values for Resource Group, Storage Account, and File share.

    !IMAGE[cloud_shell_03.png](cloud_shell_03.png)

    > [!IMPORTANT]
    > The Storage account name must be between 3 and 24 characters in length, use numbers and lower-case letters only, and be globally unique

5. After entering required values, click `Create storage`

    !IMAGE[cloud_shell_04.png](cloud_shell_04.png)

6. Once provisioning is complete, you should see "`Requesting a Cloud Shell Succeeded`".

    !IMAGE[cloud_shell_05.png](cloud_shell_05.png)

# Lab 02 - Creating Azure Resources with Ansible

In this lab we will walk through creating a playbook to provision Azure resources to run our application.  Cloud shell is recommended for this lab and all following labs; however, feel free to use any instantiation of Ansible desired.

The playbooks in this workshop are simple by design.  This is to faciliate participants with varying levels of Ansible experience and keep the focus on how Ansible can be used in conjunction with Azure.

The Azure modules that we will use are located [here](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure).  It is a good idea to bookmark this page if you will be using Ansible with Azure often as it is often needed to refer to the documentation.

1. Let's start by verifying our Ansible installation and version.

    ```
    ansible --version
    ```

    Verify that something similar to the block below is returned.  If not, there might be an issue with your Ansible installation.

    ```
    ansible 2.6.3
    config file = /Users/ox/.ansible.cfg
    configured module search path = [u'/Users/ox/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
    ansible python module location = /Users/ox/source/ansible/vault_test/venv/lib/python2.7/site-packages/ansible
    executable location = /Users/ox/source/ansible/vault_test/venv/bin/ansible
    python version = 2.7.10 (default, Aug 17 2018, 19:45:58) [GCC 4.2.1 Compatible Apple LLVM 10.0.0 (clang-1000.0.42)]
    ```

1. Also verify that the Azure CLI is installed.  If not, install it within your Windows Subsystem for Linux via the [install instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

    > Ensure you perform the install within the WSL shell using the **apt** instructions.  For Ubuntu 16.04 and later, simply run the below command.  For other distros, follow the install instructions of the link provided.

    ```
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```

    Now verify that the Azure CLI is installed:

    ```
    az --version
    ```

    Output should be similiar to the following:

    ```
    azure-cli                         2.0.64

    acr                                2.2.6
    acs                                2.4.1
    advisor                            2.0.0
    ams                                0.4.5
    appservice                        0.2.19
    backup                             1.2.4
    batch                              4.0.1
    batchai                            0.4.8
    billing                            0.2.1
    botservice                         0.2.0
    cdn                                0.2.3
    cloud                              2.1.1
    cognitiveservices                  0.2.5
    command-modules-nspkg               2.0.2
    configure                         2.0.23
    consumption                        0.4.2
    container                         0.3.16
    core                              2.0.64
    cosmosdb                          0.2.10
    deploymentmanager                  0.1.0
    dla                                0.2.5
    dls                                0.1.9
    dms                                0.1.3
    eventgrid                          0.2.3
    eventhubs                          0.3.5
    extension                          0.2.5
    feedback                           2.2.1
    find                               0.3.2
    hdinsight                          0.3.3
    interactive                        0.4.3
    iot                                0.3.8
    iotcentral                         0.1.6
    keyvault                          2.2.15
    kusto                              0.2.2
    lab                                0.1.7
    maps                               0.3.4
    monitor                           0.2.13
    network                            2.4.0
    nspkg                              3.0.3
    policyinsights                     0.1.3
    privatedns                         1.0.0
    profile                            2.1.5
    rdbms                             0.3.10
    redis                              0.4.2
    relay                              0.1.4
    reservations                       0.4.2
    resource                          2.1.14
    role                               2.6.1
    search                             0.1.1
    security                           0.1.1
    servicebus                         0.3.5
    servicefabric                     0.1.18
    signalr                            1.0.0
    sql                                2.2.3
    sqlvm                              0.1.1
    storage                            2.4.1
    telemetry                          1.0.2
    vm                                2.2.20
    
    Python location '/opt/az/bin/python3'
    Extensions directory '/home/ox/.azure/cliextensions'
    
    Python (Linux) 3.6.5 (default, May  2 2019, 00:44:46)
    [GCC 7.4.0]
    
    Legal docs and information: aka.ms/AzureCliLegal
    
    
    Your CLI is up-to-date.
    ```

1. Login to Azure using the CLI using the Username and Password provided by the Learn on Demand environment.

    ```
    az login
    ```

1. Create a new working directory to host all of our files for the labs.  Within the new directory, create a new file that will be our playbook named **azure_infra.yml**

    > If using the WSL, create the directory and playbook file somewhere in your normal user profile and change to that directory within the WSL.
    **cd /mnt/c/Users/MyUserName/Documents/Playbooks**

    ```
    ansible_workshop
    └── azure_infra.yml
    ```

1. Open the **azure_infra.yml** file with your favorite text editor. Start by inserting the top level playbook components: **hosts**, **connection**, **gather_facts**, **vars** and **tasks**.

    ```
    ---
    - hosts: localhost # Used to indicate our playbook will run locally on our dev workstation
      connection: local # Specify that we want to use a local connection, not SSH on WinRM 
      gather_facts: no # turn off fact gathering for this playbook to increase performance
      vars: # dict of variables to be used throughout the playbook

      tasks: # Our list of plays to execute
    ```

1. Proceed by filling out variables that we'll need in our playbook. The variables should be self-explanatory.

    Obtain the your resource group by running the following command.

    ```
    az group list --output table
    ```

    Grab the resource group name for your playbook
    ```
    Name                         Location    Status
    ---------------------------  ----------  ---------
    ansible_workshop_lod9139210  eastus2     Succeeded
    ```

    ```
    vars:
      location: eastus2
      rg_name: ansible_workshop_lod9139210
      debug: False # this will be used to control output from our playbook
      vms:
        azvote_vms:
          azvote1:
            nic: azvote1-nic
            avset: azvote-avset
            pip: azvote1-pip
    ```

    Save the playbook.

1. Now it's time to start adding plays to our playbook.  The **tasks** section takes a list of plays.  
    Azure resources live within a *resource group,* so let's start there.
   
    This first play makes use of the **azure_rm_resourcegroup** module; we just need to provide a few parameters.

    ```
    tasks:
    - name: Create workshop resource group
      azure_rm_resourcegroup:
        name: "{{ rg_name }}"
        location: "{{ location }}"
        state: present
    ```

1. Ensure you're off to a good start by running the ansible playbook in *check* mode.  Check mode runs the playbook but does not actually apply any change.  This will allow us to verify our playbook is valid and is authenticating to Azure.

    ```
    ansible-playbook azure_infra.yml --check
    ```

    Expected similar output:
    ```
    PLAY [localhost] **********************************************************************************************************************

    TASK [Create workshop resource group] *************************************************************************************************
    changed: [localhost]

    PLAY RECAP ****************************************************************************************************************************
    localhost                  : ok=1    changed=1    unreachable=0    failed=0
    ```

    !IMAGE[ansible_rg_check.gif](ansible_rg_check.gif)


    If your output looks similar the preceding figure then your playbook is likely functioning as expected.

1. Like many playbooks, often times we will need to use data from one resource in another.  Register the output from the resource group creation play to a variable named **rg** by adding the register line to our play.  This is something that will be common in several plays.

    ```
    tasks:
    - name: Create workshop resource group
      azure_rm_resourcegroup:
        name: "{{ rg_name }}"
        location: "{{ location }}"
        state: present
      register: rg
    ```

1. Obtain your 7 digit random identifer off the end of the resource group name.  In this case, the identifier is *9139120*. Set a new fact to hold this data so that we can append it to later resources.

    ```
    - name: set identifier
      set_fact:
        identifier: 9139120
    ```

1. Build a Virtual Network (vnet) for our Azure resources by using the **azure_rm_virtualnetwork** module.  Notice that we'll use some returned data from the resource group creation in this play.

    ```
    - name: create the azure vnet
      azure_rm_virtualnetwork:
        name: "{{ rg.state.name }}-vnet"
        state: present
        resource_group: "{{ rg.state.name }}"
        address_prefixes_cidr:
        - 10.13.0.0/16
      register: vnet
    ```

1.  Now that we have a VNet, we need to create some subnets.  We'll use the **azure_rm_subnet** module for this.  As in previous resources, piggy back off of the created resources to fill in the required information for the subnet.

    ```
    - name: create azvote subnet
      azure_rm_subnet:
        name: azvote-subnet
        resource_group: "{{ rg.state.name }}"
        virtual_network_name: "{{ vnet.state.name }}"
        address_prefix_cidr: 10.13.1.0/24
        state: present
      register: azvote_subnet
    ```

1. The application will be public facing so that it is accessible over the Internet.  To accomplish this, create a Public IP Address that will be attached to the NIC for the VM.  Do this using the **azure_rm_publicipaddress** module.

    ```
    - name: create pip for az vote web front end
      with_dict: "{{ vms.azvote_vms }}"
      azure_rm_publicipaddress:
        name: "{{ item.value.pip }}"
        resource_group: "{{ rg.state.name }}"
        domain_name: "{{ item.key }}-{{ identifier }}"
        state: present
        allocation_method: Dynamic
      register: azvote_pips
    ```

1. Create the Network Security Group that will be attached to the VM NIC.

    ```
    - name: create nsg
      azure_rm_securitygroup:
        resource_group: "{{ rg.state.name }}"
        name: azvote-nsg
        rules:
        - name: allow_ssh
          protocol: Tcp
          destination_port_range: 22
          access: Allow
          priority: 500
          direction: Inbound
        - name: allow_http
          protocol: Tcp
          destination_port_range: 80
          access: Allow
          priority: 400
          direction: Inbound
      register: nsg
    ```

1. Provision the NIC that will attach to the *azvote* VM with the **azure_rm_networkinterface** module.  We continue to build on the resources in previous steps by attaching this NIC to the VNet/Subnet and assigning the Public IP created earlier.

    ```
    - name: create azvote nics
      azure_rm_networkinterface:
        resource_group: "{{ rg.state.name }}"
        name: "{{ item.value.nic }}"
        subnet_name: "{{ azvote_subnet.state.name }}"
        virtual_network: "{{ vnet.state.name }}"
        security_group: "{{ nsg.state.name }}"
        ip_configurations:
        - name: primary
          primary: yes
          public_ip_address_name: "{{ item.value.pip }}"
      with_dict: "{{ vms.azvote_vms }}"
      register: azvote_nics
    ```

1. It's a good practice to put your VMs in availability sets.  So, let's go ahead and do that as well with the **azure_rm_availabilityset** module.

    ```
    - name: create availability set
      azure_rm_availabilityset:
        name: azvote-avset
        resource_group: "{{ rg.state.name }}"
        sku: Aligned
        platform_fault_domain_count: 2
      register: avset
    ```

1.  Great!  That's all of the building blocks we need to create a VM.  Deploy the VM with the **azure_rm_virtualmachine** module.  Remember, the **tags** property is common to azure_rm modules.  We haven't used it on previous resources; however, we will use it here.  Take note of the tags section of this resource.

    ```
    - name: create azvote vms
      with_dict: "{{ vms.azvote_vms }}"
      azure_rm_virtualmachine:
        resource_group: "{{ rg.state.name }}"
        name: "{{ item.key }}"
        state: present
        availability_set: "{{ avset.state.name }}"
        network_interface_names:
        - "{{ item.value.nic }}"
        admin_username: azure
        admin_password: P@$$Word123
        vm_size: Standard_DS2_v2
        managed_disk_type: Standard_LRS
        image:
          publisher: Canonical
          offer: UbuntuServer
          sku: 18.04-LTS
          version: latest
        tags:
          voting-app-tier: web
    ```

1. Create a storage account to host diagnostic data using the **azure_rm_storageaccount** module.

    ```
    - name: create diag storage account
      azure_rm_storageaccount:
        resource_group: "{{ rg.state.name }}"
        name: "redisdiag{{ identifier }}"
        state: present
        type: Standard_LRS
      register: diagstorage
    ```


1. Finally, deploy the redis data layer which will be used to store the data for the voting app.  We will use the **azure_rm_rediscache** module to do this.

    > The **azure_rm_rediscache** module is scheduled for release in Ansible version ~> 2.8

    ```
     - name: deploy redis cache
       azure_rm_rediscache:
         name: azvote-cache-{{ identifier }}
         enable_non_ssl_port: yes
         location: "{{ rg.state.location }}"
         resource_group: "{{ rg.state.name }}"
         sku:
           name: basic
           size: C0
         state: present
    ```

1. Execute the whole playbook and ensure it returns no errors.  This process will take about 20-25 minutes.

    > You can view the full playbook to this point [here](files/azure_infra.yml)

    ```
    ansible-playbook azure_infra.yml
    ```

1. Remember to note your unique identifier as it will be needed in following labs.

# Lab 03 - Ansible Dynamic Inventory: Azure

## Description

In this lab, we will continue to build upon the playbook that we created in lab 2.  Now that we have deployed our cloud infrastructure, we need to configure the IaaS components using traditional configuration management processes.  However, in the cloud world, new infrastrucutre may be deployed often and automatically for various reasons; such as, scaling up, self-healing, blue/green deployments, etc.  

We will setup our next set of plays to account for those scenarios where our infrastructure footprint changes continuously by using *Dynamic Inventory*.

> **Reminder**: The Azure modules that we will use are located [here](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure).  It is a good idea to bookmark this page if you will be using Ansible with Azure often as it is often needed to refer to the documentation.

## Lab

1. Let's start by verifying our Ansible installation and version.

    ```
    ansible --version
    ```

    Expected similar output:
    ```
    ansible 2.6.3
    config file = /Users/ox/.ansible.cfg
    configured module search path = [u'/Users/ox/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
    ansible python module location = /Users/ox/source/ansible/vault_test/venv/lib/python2.7/site-packages/ansible
    executable location = /Users/ox/source/ansible/vault_test/venv/bin/ansible
    python version = 2.7.10 (default, Aug 17 2018, 19:45:58) [GCC 4.2.1 Compatible Apple LLVM 10.0.0 (clang-1000.0.42)]
    ```

1. To use Azure Dynamic Inventory, we need to download the Azure Dynamic Inventory Script (azure_rm.py) and configuration file (azure_rm.ini) from the Ansible contrib directory.  Let's do that with the following commands:

    ```
    wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/azure_rm.ini
    ```
    ```
    wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/azure_rm.py
    ```

1. **azure_rm.py** is a script file, so let's go ahead and make that executable.

    ```
    chmod +x azure_rm.py
    ```

1. Update the configuration file (azure_rm.ini) to meet our needs.  Open the file with your favorite text editor and take a look. Notice that the **tags** line is commented out with a #.
   
    !IMAGE[commented_tags.png](commented_tags.png)


     Let's remove the hash and add the tag we created when deploying our VM, **voting-app-tier**.

    !IMAGE[uncommented_tags.png](uncommented_tags.png)

1. Let's test our inventory script to ensure it's working as expected.  We can do this by running the Ansible Inventory cli tool.

    Start by configuring the credentials to authenticate to Azure.  Like before, get this information from the LOD environment.

    ```
    export AZURE_AD_USER='YourUserName'
    export AZURE_PASSWORD='YourPassword'
    export AZURE_SUBSCRIPTION_ID='YourSubscriptionID'
    ```

    Because we're using Dynamic Inventory, we will specify our inventory script as the inventory file.  This will execute the script and return the expected JSON output which Ansible will parse and provide the list of hosts.

    ```
    ansible-inventory -i azure_rm.py --list
    ```

1. Review your notes for the identifier that was generated in the infrastructure deployment playbook as it will be needed here.  Start by retrieving your Azure Redis Cache key from the Azure cli or the Azure Portal.  In this lab, the identifer that was generated was **9139210**.  

    The redis cache is named **azvote-cache-[identifier]**

1. Also, look up one of the Azure Redis access keys in the portal or with the following command:

    ```
    az redis list-keys --resource-group ansible_workshop_lod9139210 --name azvote-cache-9139210
    ```

    !IMAGE[redis_keys.gif](redis_keys.gif)

    > Make note of your primary key as it will be needed in the playbook.

    > New Azure modules for managing Azure Redis Cache, **azure_rm_rediscache** and **azure_rm_rediscache_facts**,  are scheduled for release in Ansible 2.8. The **azure_rm_rediscache_facts** module would provide a way to programatically lookup the Azure Redis access keys.

1. Now that Dynamic Inventory is working as expected, it's time to create the playbook that will configure the Azure infrastructure.

    Create a new playbook file in your working directory.  This lab uses the filename **app_deploy.yml**

    ```
    touch app_deploy.yml
    ```

1. Open the playbook in your favorite editor.  Start by adding the hosts section and some fields to control the execution of the playbook.

    The hosts section is where you see the Dynamic Inventory in action.  Normally, you specify a group of hosts that are in your static inventory file.  However, now that you're implementing dynamic inventory, you will use the tag that we assigned to the VM during deployment.  So, add the following to your playbook:

    ```
    - hosts: voting-app-tier_web # Systems in Azure with voting-app-tier tag and a value of web
      gather_facts: no # increase performance by skipping fact gathering
      become: yes # run the playbook with sudo permissions
    ```

1. Refer to your notes for the identifier and the Azure Redis access key.  Add the **var** section the playbook with your unique identifier and Azure Redis Key.

    ```
    - hosts: voting-app-tier_web # Systems in Azure with voting-app-tier tag and a value of web
      gather_facts: no # increase performance by skipping fact gathering
      become: yes # run the playbook with sudo permissions
      vars:
        identifier: "9139210"
        redis_key: fXrOmPsK1T1j3wbciXShC+NqTsx5g5K0QZ82I2zxVoE=
    ```

1. Add an additional section to store these values as environment variables on the node during playbook execution.

    ```
    - hosts: voting-app-tier_web # Systems in Azure with voting-app-tier tag and a value of web
      gather_facts: no # increase performance by skipping fact gathering
      become: yes # run the playbook with sudo permissions
      vars:
        identifier: "9139210"
        redis_key: fXrOmPsK1T1j3wbciXShC+NqTsx5g5K0QZ82I2zxVoE= 

      environment:
        REDIS: "azvote-cache-{{ identifier }}.redis.cache.windows.net"
        REDIS_PWD: "{{ redis_key }}"
    ```

1. The rest of the playbook is not specific to integration of Azure and Ansible; so, simply type or copy/paste the remainder of the playbook that automates the deployment details of the Azure Voting application.

    ```
    - hosts: voting-app-tier_web # Systems in Azure with voting-app-tier tag and a value of web
      gather_facts: no # increase performance by skipping fact gathering
      become: yes # run the playbook with sudo permissions
      vars:
        identifier: "9139210"
        redis_key: fXrOmPsK1T1j3wbciXShC+NqTsx5g5K0QZ82I2zxVoE=

      environment:
        REDIS: "azvote-cache-{{ identifier }}.redis.cache.windows.net"
        REDIS_PWD: "{{ redis_key }}"

      tasks:
      - name: Install required packages
        apt:
          update_cache: yes
          name:
          - python
          - python-pip
          - python-virtualenv
          - nginx
          - gunicorn
          - git
          - supervisor

      - name: Install pip packages
        pip:
          name:
          - Flask
          - redis

      - name: Download source code
        git:
          repo: 'https://github.com/Azure-Samples/azure-voting-app-redis.git'
          dest: /srv/www

      - name: remove default nginx site
        file:
          path: /etc/nginx/sites-enabled/default
          state: absent

      - name: create azure-vote file
        file:
          path: /etc/nginx/sites-available/azure-vote
          state: touch

      - name: link file
        file:
          src: /etc/nginx/sites-available/azure-vote
          dest: /etc/nginx/sites-enabled/azure-vote
          force: yes
          state: link

      - name: write content
        copy:
          dest: /etc/nginx/sites-enabled/azure-vote
          content: |
            server {
                location / {
                    proxy_pass http://localhost:8000;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                }
            }

      - name: restart nginx
        service:
          name: nginx
          state: restarted
          enabled: yes

      - name: start flask app
        shell: gunicorn main:app -b localhost:8000 -D
        args:
          chdir: /srv/www/azure-vote/azure-vote

      - debug:
          var: identifier

      - debug:
          msg: "Website URL (Change location if necessary): http://azvote1-{{ identifier }}.{{ rg.state.location }}.cloudapp.azure.com"
    ```

1. For simplicity, a password is being used instead of SSH key pairs to login to the Azure Virtual Machines.  Therefore, you need to disable the host key checking feature of Ansible.  Do this by configuring an environment variable to configure Ansible.

    ```
    export ANSIBLE_HOST_KEY_CHECKING=False
    ```

    Also, install the sshpass program.

    ```
    sudo apt install sshpass -y
    ```

1. With the playbook complete, execute the playbook against our virtual machine.  Remember that you haven't stored the hostname or IP address of the virtual machine anywhere; Dynamic Inventory will provide this information based on the tag filter.

    Use the **ansible-playbook** command and specify the **azure_rm.py** script as the inventory file.  The username of the user created with the VM is **azure** and the **-k** flag simply tells ansible to prompt for the password of the **azure** user.

    ```
    ansible-playbook -i azure_rm.py -u azure -k app_deploy.yml
    ```

    Output is expected to be similar to below:

   !IMAGE[playbook_results.png](playbook_results.png)

1. Now that the infrastructure is deployed and the VM is configured, the site should be up and running.  Visit the URL of the VM to take a vote!

# Lab 04 - Securing Vault Password with KeyVault

## Description

To this point you have deployed an Azure Virtual Machine and instance of Azure Redis Cache.  The application is up and running; however, we have an obvious security issue with the playbook to this point.  In the play that creates the VM, we have specified the password in plain text.  It is not a good idea to push this playbook to source control without securing the password in some way.  The easiest and most common way is to use Ansible Vault.

In this lab you will secure the password with Ansible Vault.  Securing the password with Ansible Vault enables you to securely store the password in source control because it will be encrypted.  However, every time you execute the playbook you will have to enter the password manually to decrypt the file password at run time.  To alleviate that step, you will configure Azure KeyVault to store the password that unlocks your vault secrets and then use the contrib script from the Ansible repository to automatically pull the password from Azure KeyVault.

## Lab

1. Start by creating a new vault secret with Ansible to store the password.  In your working directory for the previous labs, create a new YAML variable file with the **ansible-vault** tool; like below:

    ```
    # Will prompt for a new Vault Password
    ansible-vault create secrets.yml
    New Vault password:
    Confirm New Vault password:
    ```

    This will open the newly created variable file in your default editor.  Add a value for **def_password** in the YAML file like below and save the file.

    ```
    ---
    def_password: P@$$Word123
    ```

1. Verify the password is encrypted by viewing the file.

    ```
    [ox@adsl-172-10-0-4 files]cat secrets.yml
    $ANSIBLE_VAULT;1.1;AES256
    32316333346635373164376630313763343163396434343333663261333934393631373931616633
    6463623533643932623961623634366232623631613566310a343137636664396333616536323038
    34393763616132623630346132383833313033333638343861613130666136323064646530336464
    6138626430626537320a323631353431326461613561326261663836623435633839336432663730
    36356635323133336239633765626165356633376533636439313337363035383638333137333133
    3334356532656234313364336561316535363238393235323434
    ```

1. Update the **azure_infra.yml** playbook to use the newly encrypted variable file.

    Insert a new task at the top of the play list to include the new variable file.

    ```
    tasks:
    - name: include secret vars
      include_vars:
        file: secrets.yml
    ```

    Also, change the **admin_password** property on the **azure_rm_virtualmachine** module to use the newly created and imported variable **def_password**.

    ```
    admin_password: "{{ def_password }}"
    ```

1. Run the playbook to ensure everything is still working as expected.  There is an additional switch to add when calling the playbook now that an encrypted variable file is being imported, **--ask-vault-pass**.  This will prompt for the Vault password to unlock the Vault so that the variable can be decrypted.

    ```
    ansible-playbook azure_infra.yml --ask-vault-pass
    Vault password:

    
    PLAY [localhost] *******************************************************************************************************
    
    TASK [include secret vars] *********************************************************************************************
    ok: [localhost]
    ...
    ```

1. Ansible provides the capability to use a password file to store the password that unlocks the Vault.  This can be a simple text file.  This enables you to execute the playbook without having to enter the valut password everytime you run a playbook.  Also, you could now push your variable file to source control and it would be secure because it is encrypted. However, the obvious downside is that you are still storing the master vault password in plain text on your system.

    Ansible can execute a script and return the output in place of using a plain text file for storing the Vault password.  Like the Azure Dynamic Inventory, you can use a script that will pull this password from Azure KeyVault by using the same authentication methods you used for Dynamic Inventory.

    > The account must have access to the Azure KeyVault secrets

    Create a new Azure KeyVault where the password can be stored.  Add the creation of this Azure resource to the **azure_infra.yml** playbook.

    Start by obtaining the **tenant_id** and **object_id** of your user account.  This will be needed to provide access to the secrets stored in Key Vault.

    ```
    # obtain the tenant_id from the account
     az account show

    {
      "environmentName": "AzureCloud",
      "id": "ca5e9994-0911-43f0-9c04-f38057047cd3",
      "isDefault": true,
      "name": "Microsoft Azure Internal Consumption",
      "state": "Enabled",
      "tenantId": "ud3l4234-23a1-52dw-73ba-2a5cd011db65",
      "user": {
        "name": "joe@contoso.com",
        "type": "user"
      }
    }
    ```

    > NOTE: You may need to install the jq tool to use the next command.

    ```
    # obtain the object_id for the user account
     az ad user show --upn-or-object-id myuser@contoso.com | jq -r .objectId
    b443d323-f6e5-4b1e-98cf-c5ae02546653
    ```

    After finding the **object_id** and the **tenant_id**, add the following snippet to the **azure_infra.yml** playbook, replacing the values for object and tenant id.

    ```
    - name: Create Azure KeyVault
      register: kv
      azure_rm_keyvault:
        resource_group: "{{ rg.state.name }}"
        vault_name: "ansible-vault-{{ identifier }}"
        enabled_for_deployment: yes
        enabled_for_template_deployment: yes
        vault_tenant: ud3l4234-23a1-52dw-73ba-2a5cd011db65
        sku:
          name: standard
        access_policies:
        - tenant_id: ud3l4234-23a1-52dw-73ba-2a5cd011db65
          object_id: b443d323-f6e5-4b1e-98cf-c5ae02546653
          secrets:
          - get
          - list
          - set
          - delete

      - debug:
          msg: "Azure KeyVault Name: ansible-vault-{{ identifier }}"
    ```

1. Execute the playbook to create the Azure KeyVault:

    ```
    ansible-playbook azure_infra.yml --ask-vault-pass
    ```

1. With the Azure KeyVault created, use the Azure CLI to create the secret.

    ```
    # replace ansible-vault-[your_identifier]
    # replace "password" with your vault password
    az keyvault secret set --name "vaultpw" --vault-name ansible-vault-9139210 --value "password"
    ```

1. Make note of the secret version as it will be needed later.  This can be obtained by showing the secret with the Azure CLI and pulling it from the end of the URI.

    ```
    az keyvault secret show --name "vaultpw" --vault-name ansible-vault-9139210
    ```

    !IMAGE[vault_secret_version.jpg](vault_secret_version.jpg)

    In this case, the secret version is: **de5c8edb34e548e2af15de92569a9727**.

1. Now that the master vault password is stored in Azure KeyVault, the next step is to configure Ansible to use the master password when executing playbooks.

    Start by downloading the KeyVault integration script and configuration file.

    > Download the integration script

    ```
     wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/vault/azure_vault.py
    ```

    > Download the configuration file

    ```
     wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/vault/azure_vault.ini
    ```

1. Make the downloaded script executable.

    ```
    chmod +x azure_vault.py
    ```

1. Configure an environment variable to specify a default password file for Ansible and to control which secret to use as the master password for the integration script.

    > This value can be stored in the Ansible configuration file as well.

    ```
    export ANSIBLE_VAULT_PASSWORD_FILE="azure_vault.py"
    ```

1. Edit the **azure_vault.ini** script downloaded earlier to point to your Azure KeyVault for the master vault password.

    ```
    # azure_vault.ini
    [azure_keyvault]
    vault_name=ansible-vault-9139210
    secret_name=vaultpw
    secret_version=de5c8edb34e548e2af15de92569a9727
    ```

1.  The vault integraion script can be tested alone just like the dynamic inventory script.  The expected output is simply the value of the secret that the integration script is configured to lookup.

    ```
    python azure_vault.py
    ```

1.  Now that the environment variables to configure Ansible and the integration script have been set, the playbook can be simply ran using the basic **ansible-playbook** command and all secrets are now secured without being stored in plain text anywhere on the system.

    ```
    ansible-playbook azure_infra.yml
    ```