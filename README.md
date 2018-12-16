# psm

This Playbook will install the CyberArk psm software on a Windows 2016 server / VM / instance

Requirements
------------

- Windows 2016 must be installed on the server
- Administrator credentials (either Local or Domain)
- Network connection to the vault and the repository server
- Location of psm CD image
- PAS packages version 10.5 and above


## Role Variables

A list of vaiables the playbook is using 

**Flow Variables**
                    
| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| psm_prerequisites                | no           | false                                                                          | Install psm pre requisites               |
| psm_install                      | no           | false                                                                          | Install psm                              |
| psm_postinstall                  | no           | false                                                                          | psm port install role                    |
| psm_hardening                    | no           | false                                                                          | psm hardening role                       |
| psm_registration                 | no           | false                                                                          | psm Register with Vault                  |
| psm_upgrade                      | no           | false                                                                          | N/A                                      |
| psm_clean                        | no           | false                                                                          | Clean server after deployment            |
| psm_uninstall                    | no           | false                                                                          | N/A                                      |

**Deployment Variables**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| psm_base_bin_drive               | no           | "C:"                                                                           | Base path to extract CyberArk packages   |
| psm_zip_file_path                | yes          | None                                                                           | Zip File path of CyberArk packages       |
| psm_extract_folder               | no           | "{{psm_base_bin_drive}}\\Cyberark\\packages"                                   | Path to extract the CyberArk packages    |
| psm_artifact_name                | no           | "psm.zip"                                                                      | zip file name of psm package             |
| psm_component_folder             | no           | "PSM"                                                                          | The name of psm unzip folder             |
| psm_installation_drive           | no           | "C:"                                                                           | Base drive to install psm                |
| vault_ip                         | yes          | None                                                                           | Vault ip to perform registration         |
| dr_vault_ip                      | no           | None                                                                           | vault dr ip to perform registration      |
| vault_port                       | no           | 1858                                                                           | vault port                               |
| vault_username                   | no           | "administrator"                                                                | vault username to perform registration   |
| vault_password                   | yes          | None                                                                           | vault password to perform registration   |
| pvwa_url                         | yes          | None                                                                           | URL of registered PVWA                   |
| accept_eula                      | yes          | "No"                                                                           | Accepting EULA condition                 |
| psm_out_of_domain                | no           | false                                                                          | Flag if server is out of domain          |


## Usage 

**psm_prerequisites**

This task will run the psm pre-requisites steps

**psm_install**

This task will deploy the psm to required folder and validate deployment succeed.

**psm_postinstall**

This task will run the psm post installation steps

**psm_hardening**

This task will run the psm hardening process

**psm_registration**

This task perform registration with active Vault

**psm_validateparameters**

This task validate which psm steps already occurred on the server so the other tasks won't run again

**psm_clean**

This task will clean inf files from installation, delete psm installation logs from Temp folder & Delete cred files


## Example Playbook

Example playbook to show how to call the psm main playbook with several parameters:

    ---
    - hosts: localhost
      connection: local
      tasks:
        - include_task:
            name: main
          vars:
            psm_prerequisites: true
            psm_install: true
            psm_postinstall: true
            psm_hardening: true
            psm_clean: true

## Running the  playbook:

To run the above playbook:

    ansible-playbook -i ../inventory.yml psm-orchestrator.yml -e "psm_install=true psm_installation_drive='D:'"

## License

 **TBD**
