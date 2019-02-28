# PSM Ansible Role
This Ansible Role will deploy and install CyberArk Privileged Session Manager including the pre-requisites, application, hardening and connect to an existing Vault environment.

## Requirements
------------

- Windows 2016 installed on the remote host
- WinRM open on port 5986 (**not 5985**) on the remote host
- Pywinrm is installed on the workstation running the playbook
- The workstation running the playbook must have network connectivity to the remote host
- The remote host must have Network connectivity to the CyberArk vault and the repository server
  - 443 port outbound
  - 1858 port outbound
- Administrator access to the remote host
- PSM CD image


### Flow Variables
Variable                         | Required     | Default                                   | Comments
:--------------------------------|:-------------|:------------------------------------------|:---------
psm_prerequisites                | no           | false                                     | Install PSM pre requisites
psm_install                      | no           | false                                     | Install PSM
psm_postinstall                  | no           | false                                     | PSM post install role
psm_hardening                    | no           | false                                     | Apply PSM hardening
psm_registration                 | no           | false                                     | Connect PSM to the Vault
psm_upgrade                      | no           | false                                     | N/A
psm_clean                        | no           | false                                     | N/A
psm_uninstall                    | no           | false                                     | N/A

### Deployment Variables
Variable                         | Required     | Default                                              | Comments
:--------------------------------|:-------------|:-----------------------------------------------------|:---------
vault_ip                         | yes          | None                                                 | Vault IP to perform registration
vault_port                       | no           | **1858**                                             | Vault port
vault_username                   | no           | **administrator**                                    | Vault username to perform registration
vault_password                   | yes          | None                                                 | Vault password to perform registration
dr_vault_ip                      | no           | None                                                 | Vault DR IP address to perform registration
accept_eula                      | yes          | **No**                                               | Accepting EULA condition (Yes/No)
psm_zip_file_path                | yes          | None                                                 | CyberArk PSM installation Zip file package path
connect_with_rdp                 | yes          | **No**                                               | Disable NLA on the server
psm_installation_drive           | no           | **C:**                                               | Destination installation drive
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

## Running the playbook:
For an example of how to incorporate this role into a complete playbook, please see the
**[pas-orchestrator](https://github.com/cyberark/pas-orchestrator)** example.

## License
Apache License, Version 2.0
