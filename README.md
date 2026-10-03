# ansible

![logo](https://bit.ly/47WuP1s)

###### Install Ansible
```shell
pyenv install -s 3.12.7
pyenv local 3.12.7
sudo python3.12 -m pip install --upgrade pip
pip install virtualenv
virtualenv -p python3 .venv
source .venv/bin/activate
pip install ansible
python --version
ansible --version
source config.sh
```

#### Create Inventory
Create inventory.yaml file at the root of the repository.

```yaml
D5BFA3BCA28:
  hosts:
    debian-01:
      ansible_host: 192.168.1.14
      ansible_port: 22
      ansible_user: root
```

#### Ping Inventory
```shell
ansible -i $INVENTORY_FILE all -m ping
```

#### Gather Facts
```shell
ansible -i $INVENTORY_FILE all -m ansible.builtin.setup
```

#### GitLab token
The Rails apps read `RAILS_MASTER_KEY` from the CI/CD variables of their
GitLab `-org` project. Create a personal access token with the `read_api`
scope, then store it in the vault:

```shell
ansible-vault create roles/admin/vars/env_vault_gitlab.yaml
```

```yaml
gitlab_api_token: glpat-...
```

The `RAILS_MASTER_KEY` variables must be masked, not hidden: the API never
returns the value of a hidden variable.

#### Run Playbook for ubuntu-* target host
```shell
ansible-playbook -i $INVENTORY_FILE setup.yml \
    --ask-become-pass    \
    --become             \
    --become-user=root   \
    --diff               \
    --flush-cache        \
    --limit "debian-*"
```

#### Run Playbook with tags
Run the playbook with or without admin tag
to make sure all tasks are included.

```shell
ansible-playbook -i $INVENTORY_FILE deploy.yml \
    --ask-become-pass    \
    --become             \
    --become-user=root   \
    --diff               \
    --flush-cache        \
    --limit "debian-*"   \
    --tags "admin, redis, admin redis"
```

#### Run Playbook locally
```shell
ansible-playbook -i $INVENTORY_FILE deploy.yml \
    --ask-become-pass    \
    --become             \
    --become-user=root   \
    --diff               \
    --flush-cache        \
    --connection "local" \
    --limit "debian-*"
```
