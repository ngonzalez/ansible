# ansible

#### Install community.general
```
ansible-galaxy collection install community.general
```

#### disable ssh host key checking
```
ANSIBLE_HOST_KEY_CHECKING=False
```

#### run playbook
```
ansible-playbook -i inventory.yml site.yml --flush-cache --diff --ask-vault-pass -v
```

#### ping inventory
```
ansible -i inventory.yml all -m ping
```

#### gather facts
```
ansible -i inventory.yml all -m ansible.builtin.setup
```
