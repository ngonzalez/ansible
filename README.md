#### load config
```
source config.sh
```

#### Install community.general
```
ansible-galaxy collection install community.general
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
ansible-playbook -i inventory.yml $CLUSTER_NAME.yml --flush-cache --diff --ask-vault-pass --tags "deploy" -vv
```
