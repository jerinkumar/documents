
# Ansible Automation Platform (AAP) Execution Instance Configuration Guide

## Overview
This document provides step-by-step instructions to configure **Execution Instances** in Red Hat Ansible Automation Platform (AAP).  
It is designed for system administrators and automation engineers setting up distributed execution environments.

---

## Prerequisites
- Access to **Automation Controller (AAP UI)**
- Access to the **Execution Host (on-prem)**
- SSH privileges to the execution host
- Root or sudo access to install required packages
- Internet or repository access for Ansible collections

---

## Step 1: Create Execution Instance in AAP
1. Navigate to **Automation Execution → Infrastructure → Instances**.
2. Click **Create Instance**.
3. Provide the **Host Name (FQDN)** or **IP Address** of your execution node.
4. Leave other fields as default and click **Create Instance**.

---

## Step 2: Associate Peers (Mesh Configuration)
1. Select the newly created instance.
2. Under **Peers**, choose the **mesh-ingress hop node**.
3. Click **Associate Peers** to establish mesh connectivity.

> **Note:** The instance will initially appear as **Unavailable** — this is expected.

---

## Step 3: Download the Bundle
1. Select the created instance.
2. Navigate to the **Details** tab.
3. Click **Download Bundle** — this will download the configuration bundle file for the instance.

---

## Step 4: Transfer and Extract the Bundle
1. Copy the downloaded bundle to the **Execution Host** under `/opt` directory:
   ```bash
   scp execution-bundle.tar.gz user@<execution_host>:/opt/
   ```
2. SSH into the execution host:
   ```bash
   ssh user@<execution_host>
   ```
3. Extract the bundle:
   ```bash
   cd /opt
   tar -xvzf <bundle_filename>.tar.gz
   ```

---

## Step 5: Update Inventory File
Modify the extracted `inventory.yml` file as follows so that the playbook runs **locally**:

```yaml
[execution_nodes]
localhost ansible_connection=local
```

---

## Step 6: Install Ansible-Core
Install Ansible Core using DNF:

```bash
sudo dnf install -y ansible-core
```

---

## Step 7: Enable Local Repository
> (Steps to be provided later — insert repository enablement commands here.)

Ensure the local YUM/DNF repository is configured properly for Ansible dependencies.

---

## Step 8: Configure Proxy (if applicable)
If the server uses a proxy, set the following environment variables:

```bash
export http_proxy=http://<proxy>:<port>
export https_proxy=http://<proxy>:<port>
export no_proxy=localhost,127.0.0.1
```

---

## Step 9: Install Ansible Receptor Collection
Run the following command to install the required collection:

```bash
ansible-galaxy collection install ansible.receptor
```

---

## Step 10: Run the Receptor Installation Playbook
Execute the playbook to install and configure the receptor service:

```bash
ansible-playbook -i inventory.yml install_receptor.yml
```

If the installation completes successfully, the receptor service should be active on the execution node.

---

## Step 11: Verify from AAP UI
1. Return to the **AAP UI → Infrastructure → Instances**.
2. Select the configured instance.
3. Run a **Health Check**.
4. The instance status should now display as **Ready**.

---

## Step 12: Verify in Topology View
Navigate to the **Topology View** in the AAP UI to visualize the overall connectivity between AAP and your execution instance.

---

## Troubleshooting Tips
- If the instance remains unavailable:
  - Check `/var/log/receptor` logs on the execution host.
  - Ensure the correct FQDN/IP is used in the instance configuration.
  - Verify that firewall and SELinux settings allow required ports.
  - Confirm that Ansible Core and receptor are installed successfully.

---

## Summary
You have now successfully configured and registered an **Execution Instance** in Red Hat Ansible Automation Platform.  
This instance can now execute playbooks as part of your Automation Mesh.
