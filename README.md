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
`setup.yml` configures the node, role by role. Without TAGS it runs every
role, including the kube role (tag `kubernetes`), which resets the cluster
with `kubeadm reset -f` and builds a new one: everything must be deployed
again afterwards (`make deploy`). Use TAGS to run only some roles.
```shell
make dry-run TAGS=firewall   # --check --diff: what would change
make setup TAGS=firewall,vim
make setup                   # every role: rebuilds the cluster
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
ansible-lint runs at the basic profile. The tests in `tests/` run on
localhost, without the node:

- `admin-files.yml`: every manifest and helm values file the admin role
  deploys exists in the admin repository checked out next to this one
  (`ADMIN_DIR` to use another), is valid and targets `development`, and
  every file there is deployed (or listed in `admin_unused_files`)
- `admin-env.yml`: the apps' env templates render from the vault (the vault
  password is needed), with no empty or duplicate keys, and the Postgres and
  Redis passwords agree across the vault files. No secret is printed.
- `tags.yml`: every task is tagged, each setup role has its own tag,
  every deploy task runs with `admin`, and each `include_vars` runs with
  the tasks that read it
- `versions.yml`: CRI-O and Kubernetes versions match, the pod networks
  agree, and every helm chart is pinned
- `firewall.yml`: the ufw rules the firewall role keeps and removes
