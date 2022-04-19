
⚠️ Please follow these links for the changes related to ___backend___ ___frontend___ and ___database___ clusters:
 * https://github.com/ngonzalez/ansible/tree/backend
 * https://github.com/ngonzalez/ansible/tree/frontend
 * https://github.com/ngonzalez/ansible/tree/database

# ansible

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
