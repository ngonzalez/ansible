# ansible

![logo](https://bit.ly/47WuP1s)

The commands run from the admin repository (`make help` lists them all),
with this repository checked out next to it in `../ansible`.

#### Install Ansible
Installs the versions pinned in `requirements.txt` with pyenv's Python
(`.python-version`).
```shell
make -C ../admin ansible-install
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
make -C ../admin ansible-ping    # ansible reaches the node
make -C ../admin ansible-facts   # the facts ansible gathers
make -C ../admin ansible-tags    # the TAGS setup and deploy accept
```

#### Set up the node
`setup.yml` configures the node, role by role. TAGS is required; `TAGS=all`
runs every role. The kube role (tag `kubernetes`) resets the cluster with
`kubeadm reset -f` and builds a new one, so it also needs `CONFIRM=1`.
```shell
make -C ../admin ansible-dry-run TAGS=firewall   # --check --diff: what would change
make -C ../admin setup TAGS=firewall,vim
```

#### Deploy
`deploy.yml` deploys the applications and the monitoring to the cluster.
TAGS is required; `TAGS=all` deploys everything.
```shell
make -C ../admin deploy TAGS=nginx-stream,nginx-frontend
make -C ../admin deploy TAGS=all
```

#### Test
```shell
make -C ../admin ansible-test   # syntax, ansible-lint, tests/*.yml
```
ansible-lint runs at the basic profile.
