class Error < StandardError ; end

class Kubernetes
  attr_accessor :account, :vagrant_ip
  attr_accessor :namespace, :namespaces
  attr_accessor :nodes, :pods

  def initialize(account: nil, vagrant_ip: nil, namespace: nil)
    # logger
    @logger = Logger.new $stdout

    # init
    @account = account
    @vagrant_ip = vagrant_ip
    @namespace = namespace
    @namespaces = []
    @nodes = []
    @pods = []

    set_namespaces
    set_nodes
    set_pods
  rescue Error => error
    @logger.error error.message
  end

    private

  def set_namespaces
    namespaces_json = `ssh #{account}@#{vagrant_ip} "kubectl get ns -o json | jq -r '[.items[] | { name: .metadata.name }]'"`
    @namespaces = JSON.parse(namespaces_json, symbolize_names: true)
    raise Error.new("Invalid namespace") unless namespaces.map { |ns| ns[:name] }.include?(namespace)
    @logger.info "Namespace: %s" % namespace.inspect
  rescue => _exception
    raise Error.new("Failed to detect namespace")
  end

  def set_nodes
    nodes_json = `ssh #{account}@#{vagrant_ip} "kubectl -n #{namespace} get no -o json | jq -r '[.items[] | { name: .metadata.name, internal_ip: .status.addresses[] | select(.type==\\"InternalIP\\") }]'"`
    @nodes = JSON.parse(nodes_json, symbolize_names: true)
    raise Error.new("Can't find any nodes") if @nodes.empty?
    @logger.info "Nodes: %s" % @nodes.map { |node| [node[:name], node[:internal_ip][:address]] }.inspect
  rescue => _exception
    raise Error.new("Failed to detect node")
  end

  def set_pods
    pods_json = `ssh #{account}@#{vagrant_ip} "kubectl -n #{namespace} get po -o json | jq -r '[.items[] | { name: .metadata.name, host_ip: .status.hostIP, pod_ip: .status.podIP }]'"`
    @pods = JSON.parse(pods_json, symbolize_names: true)
    raise Error.new("Can't find any pods") if @pods.empty?
    @logger.info "Pods: %s" % @pods.map { |pod| [pod[:name], pod[:pod_ip]] }.inspect
  rescue => _exception
    raise Error.new "Failed to find pods"
  end
end
