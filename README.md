
⚠️ Please follow these links for the changes related to ___backend___ ___frontend___ and ___database___
 * https://github.com/ngonzalez/ansible/tree/backend
 * https://github.com/ngonzalez/ansible/tree/frontend
 * https://github.com/ngonzalez/ansible/tree/database

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
               --loadbalancers "$BACKEND_LOADBALANCER $FRONTEND_LOADBALANCER $DB_LOADBALANCER" \
               --loadbalancers_inventory_file $LOADBALANCERS_INVENTORY_FILE
```

#### ping inventory
```
ansible -i $INVENTORY_FILE all -m ping
```

#### gather facts
```
ansible -i $INVENTORY_FILE all -m ansible.builtin.setup
```

#### run playbook
```
ansible-playbook -i $INVENTORY_FILE frontend.yml --flush-cache --diff -vv --limit "frontend-*"
```
