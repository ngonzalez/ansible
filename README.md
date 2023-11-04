# ansible

![logo](https://user-images.githubusercontent.com/26479/113611957-81d90b80-964f-11eb-95c9-2fb0dfa3cb0b.png)

#### ping inventory
```shell
ansible -i $INVENTORY_FILE all -m ping
```

#### gather facts
```shell
ansible -i $INVENTORY_FILE all -m ansible.builtin.setup
```

#### run playbook
```shell
ansible-playbook -i $INVENTORY_FILE ubuntu.yml --flush-cache --diff -vv --limit "ubuntu-*"
```
