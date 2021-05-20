# ansible
export ACCOUNT='docker'
export ANSIBLE_USER='debian'
export ANSIBLE_PORT='22'

# gcp
export NAMESPACE='k8s'
export GCP_ENABLED='true'
export PROJECT_NAME='app-56468'
export BUCKET_NAME="$PROJECT_NAME-storage"
export APP_CLUSTER_IP=`kubectl -n $NAMESPACE describe ing app-ingress | grep Address | awk '{ print $2 }'`
export DB_CLUSTER_IP=`kubectl -n $NAMESPACE describe service database-loadbalancer | grep Ingress | awk '{ print $3 }'`
