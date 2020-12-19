#### Install community.general
```
ansible-galaxy collection install community.general
```

#### load config
```
source config.sh
```

#### generate inventory
```
./inventory.rb --namespace $NAMESPACE --account $ACCOUNT --user $ANSIBLE_USER --port $ANSIBLE_PORT
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
ansible-playbook -i inventory.yml kibana.yml --flush-cache --diff --ask-vault-pass -vv
```
