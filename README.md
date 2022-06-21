# ansible

⚠️ Please follow the link of the name of the project

#### Vagrant setup
 * https://github.com/ngonzalez/ansible/tree/virtualbox

#### Debian setup
 * https://github.com/ngonzalez/ansible/tree/debian

#### Database project
 * https://github.com/ngonzalez/ansible/tree/database

#### Backend project
 * https://github.com/ngonzalez/ansible/tree/backend

#### Frontend project
 * https://github.com/ngonzalez/ansible/tree/frontend

#### Stream project
 * https://github.com/ngonzalez/ansible/tree/stream

![formation-ansible](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

#### ping inventory
```shell
ansible -i $INVENTORY_FILE all -m ping
```

#### gather facts
```shell
ansible -i $INVENTORY_FILE all -m ansible.builtin.setup
```

#### run playbook
```shell
ansible-playbook -i $INVENTORY_FILE virtualbox.yml --flush-cache --diff -vv --limit "vagrant-*"
```
=======
