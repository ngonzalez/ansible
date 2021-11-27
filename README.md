
⚠️ Please follow these links for the changes related to ___app___ and ___db___ clusters:
 * https://github.com/ngonzalez/ansible/tree/app
 * https://github.com/ngonzalez/ansible/tree/db

# ansible

![formation-ansible](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

#### generate inventory
```
./inventory.rb --namespace $NAMESPACE	\
               --account $ACCOUNT	\
               --vagrant_ip $VAGRANT_IP	\
               --user $ANSIBLE_USER	\
               --port $ANSIBLE_PORT	\
               --inventory_file $INVENTORY_FILE \
               --loadbalancers "$APP_LOADBALANCER $DB_LOADBALANCER" \
               --loadbalancers_inventory_file $LOADBALANCERS_INVENTORY_FILE
```

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
ansible-playbook -i inventory.yml app.yml --flush-cache --diff --ask-vault-pass -vv --limt "app-*"
```
