
⚠️ Please follow these links for the changes related to ___app___ and ___db___ clusters:
 * https://github.com/ngonzalez/ansible/tree/app
 * https://github.com/ngonzalez/ansible/tree/db

# ansible

![formation-ansible](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

#### ping inventory
```
ansible -i inventory.yml all -m ping
```

#### gather facts
```
ansible -i inventory.yml all -m ansible.builtin.setup
```

#### run playbook
```
ansible-playbook -i inventory.yml main.yml --flush-cache --diff -vv
```
