# ansible

![logo](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

###### Install Ansible
```shell
brew install git python3 curl
sudo pip3 install virtualenv
virtualenv -p python3 .venv
source .venv/bin/activate
pip install ansible
ansible --version
```


#### Ping Inventory
```shell
ansible -i $INVENTORY_FILE all -m ping
```

#### Gather Facts
```shell
ansible -i $INVENTORY_FILE all -m ansible.builtin.setup
```

#### Run Playbook
```shell
ansible-playbook -i $INVENTORY_FILE deploy.yml \
    --ask-become-pass    \
    --become             \
    --become-user=root   \
    --diff               \
    --flush-cache        \
    --limit "ubuntu-*"   \
    --connection "local" \
    --tags "admin, admin nginx-frontend"
```
