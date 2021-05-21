# ansible

![formation-ansible](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

#### Install community.general
```
ansible-galaxy collection install community.general
```

#### generate inventory
```
./inventory.rb --namespace $NAMESPACE	\
							 --account $ACCOUNT	\
							 --user $ANSIBLE_USER	\
							 --port $ANSIBLE_PORT	\
							 --ingress_name $INGRESS_NAME	\
							 --database_loadbalancer $DATABASE_LOADBALANCER
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
ansible-playbook -i inventory.yml app.yml --flush-cache --diff --ask-vault-pass -vv
```
