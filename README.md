# ansible

#### Install community.general
```
ansible-galaxy collection install community.general
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
ansible-playbook -i inventory.yml site.yml --list-host
ansible-playbook -i inventory.yml site.yml --diff --check
ansible-playbook -i inventory.yml site.yml
```
