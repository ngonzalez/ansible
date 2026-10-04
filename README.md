# ansible

![logo](https://bit.ly/47WuP1s)

`make help` lists the commands. The admin repository, checked out next to
this one, runs the same ones as `make ansible-<target>`, `make setup` and
`make deploy`.

#### Install Ansible
Installs the versions pinned in `requirements.txt` with pyenv's Python
(`.python-version`).
```shell
make install
```

#### Create Inventory
Create inventory.yaml file at the root of the repository.

```yaml
D5BFA3BCA28:
  hosts:
    debian-01:
      ansible_host: 192.168.1.14
      ansible_port: 22
      ansible_user: root
```

#### Check the node
```shell
make ping    # ansible reaches the node
make facts   # the facts ansible gathers
make tags    # the TAGS setup and deploy accept
```

#### Set up the node
`setup.yml` configures the node, role by role. TAGS is required; `TAGS=all`
runs every role. The kube role (tag `kubernetes`) resets the cluster with
`kubeadm reset -f` and builds a new one, so it also needs `CONFIRM=1`.
```shell
make dry-run TAGS=firewall   # --check --diff: what would change
make setup TAGS=firewall,vim
```

#### Deploy
`deploy.yml` deploys the applications and the monitoring to the cluster.
Without TAGS it deploys everything; TAGS limits it to some projects.
```shell
make deploy
make deploy TAGS=nginx-stream,nginx-frontend
```

#### Test
```shell
make test    # syntax, ansible-lint, tests/*.yml
```
ansible-lint runs at the basic profile.
