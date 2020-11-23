# ansible

#### Install community.general
```
ansible-galaxy collection install community.general
```

#### run playbook
```
ansible-playbook -i inventory.yml site.yml --flush-cache --diff --ask-vault-pass --tag deploy -v
```

#### ping inventory
```
ansible -i inventory.yml all -m ping
```

#### gather facts
```
ansible -i inventory.yml all -m ansible.builtin.setup
```
