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
    --tags "admin, nginx-frontend, admin nginx-frontend"
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
