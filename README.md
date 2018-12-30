# PSM

This playbook will install the [CyberArk PSM](https://www.cyberark.com/products/privileged-account-security-solution/core-privileged-account-security/) software on a Windows 2016 server / VM / instance.


## Requirements
------------
- The host running the playbook must have network connectivity to the remote hosts in the inventory
- Windows 2016 must be installed on the remote host
- Administrator credentials for access to the remote host (either Local or Domain)
- Network connectivity to the CyberArk vault and the repository server
- PSM package version 10.6 and above, including the location of the CD images

### Flow Variables

Variable                         | Required     | Default                                   | Comments
:--------------------------------|:-------------|:------------------------------------------|:---------
psm_prerequisites                | no           | false                                     | Install PSM pre requisites
psm_install                      | no           | false                                     | Install PSM
psm_postinstall                  | no           | false                                     | PSM port install role
psm_hardening                    | no           | false                                     | PSM hardening role
psm_registration                 | no           | false                                     | PSM Register with Vault
psm_upgrade                      | no           | false                                     | N/A
psm_clean                        | no           | false                                     | Clean server after deployment
psm_uninstall                    | no           | false                                     | N/A

### Deployment Variables

Variable                         | Required     | Default                                              | Comments         
:--------------------------------|:-------------|:-----------------------------------------------------|:---------
vault_ip                         | yes          | None                                                 | Vault IP to perform registration   
vault_password                   | yes          | None                                                 | Vault password to perform registration
pvwa_url                         | yes          | None                                                 | URL of registered PVWA                 
accept_eula                      | yes          | **No**                                               | Accepting EULA condition       
psm_zip_file_path                | yes          | None                                                 | Zip File path of CyberArk packages
psm_disable_nla                  | yes          | **No**                                               | This will disable NLA on the server
vault_username                   | no           | **administrator**                                    | Vault username to perform registration
vault_port                       | no           | **1858**                                             | Vault port
dr_vault_ip                      | no           | None                                                 | Vault DR IP address to perform registration
psm_base_bin_drive               | no           | **C:**                                               | Base path to extract CyberArk packages
psm_extract_folder               | no           | **{{psm_base_bin_drive}}\\Cyberark\\packages**       | Path to extract the CyberArk packages
psm_artifact_name                | no           | **psm.zip**                                          | Zip file name of PSM package
psm_component_folder             | no           | **Central Policy Manager**                           | The name of PSM unzip folder
psm_installation_drive           | no           | **C:**                                               | Base drive to install PSM
psm_out_of_domain                | no           | false                                                | Flag to determine if server is out of domain

## Dependencies
None

## Usage
The role consists of a number of different tasks which can be enabled or disabled for the particular
run.

`psm_prerequisites`

This task will run the PSM pre-requisites steps.

`psm_install`

This task will deploy the PSM to required folder and validate successful deployment.

`psm_postinstall`

This task will run the PSM post installation steps.

`psm_hardening`

This task will run the PSM hardening process.

`psm_registration`

This task will perform registration with active Vault.

`psm_validateparameters`

This task will validate which PSM steps have already occurred on the server to prevent repetition.

`psm_clean`

This task will clean the configuration (inf) files from the installation, delete the
PSM installation logs from the Temp folder and delete the cred files.


## Example Playbook
Below is an example of how you can incorporate this role into an Ansible playbook
to call the PSM role with several parameters:

```
---
- include_role:
    name: psm
  vars:
    - psm_prerequisites: true
    - psm_install: true
    - psm_postinstall: true
    - psm_hardening: true
    - ps_clean: true
```

## Running the  playbook:

For an example of how to incorporate this role into a complete playbook, please see the
**[pas-orchestrator](https://github.com/cyberark/pas-orchestrator)** example.

## License

[Apache 2](LICENSE)
