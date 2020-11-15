# ansible


#### ping inventory
```
ansible all -i inventory.yml -m ping
```

#### run playbook
```
ansible-playbook -i inventory.yml site.yml --list-host
ansible-playbook -i inventory.yml site.yml --diff --check
ansible-playbook -i inventory.yml site.yml
```
