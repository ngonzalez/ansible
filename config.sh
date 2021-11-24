# ansible
export ACCOUNT='docker'
export ANSIBLE_USER='debian'
export ANSIBLE_PORT='22'
export INVENTORY_FILE='inventory.yml'

# kubernetes
export NAMESPACE='k8s'
export APP_LOADBALANCER='app-loadbalancer'
export DB_LOADBALANCER='database-loadbalancer'
export LOADBALANCERS_INVENTORY_FILE='roles/app/vars/inventory.yml'

# gcp
export GCP_ENABLED='true'
