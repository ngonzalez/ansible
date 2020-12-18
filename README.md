# ansible

#### Install community.general
```
ansible-galaxy collection install community.general
```

#### disable ssh host key checking
```
ANSIBLE_HOST_KEY_CHECKING=False
```

#### generate inventory
```
./inventory.rb --namespace <NS> --account <example@gmail.com> --user <ANSIBLE_USER> --port <ANSIBLE_PORT>
```

#### ping inventory
```
ansible -i inventory.yml all -m ping
```

#### gather facts
```
ansible -i inventory.yml all -m ansible.builtin.setup
```
