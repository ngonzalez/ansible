require "pry"

class Error < StandardError ; end

class Kubernetes
  attr_accessor :namespace, :namespaces
  attr_accessor :nodes, :pods
  attr_accessor :ingress, :ingress_name
  attr_accessor :database_loadbalancer, :database_loadbalancer_name

  def initialize(namespace: nil, ingress_name: nil, database_loadbalancer_name: nil)
    # logger
    @logger = Logger.new $stdout

    # init
    @namespace = namespace
    @ingress_name = ingress_name
    @database_loadbalancer_name = database_loadbalancer_name
    @namespaces = []
    @nodes = []
    @pods = []

    set_namespaces
    set_nodes
    set_pods
    set_ingress
    set_database_loadbalancer
  rescue => _exception
    @logger.error Error.new(_exception.message)
  end

    private

  def set_namespaces
    res = `kubectl get ns -o json | jq -r '[.items[] | { name: .metadata.name }]'`
    @namespaces = JSON.parse res, symbolize_names: true
    raise Error.new("Invalid namespace") unless namespaces.map { |ns| ns[:name] }.include?(namespace)
    @logger.info "Namespace: %s" % namespace.inspect
  rescue => _exception
    raise Error.new("Failed to detect namespace")
  end

  def set_nodes
    res = `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | { name: .metadata.name, internal_ip: .status.addresses[] | select(.type=="InternalIP") }]'`
    @nodes = JSON.parse res, symbolize_names: true
    @logger.info "Nodes: %s" % @nodes.map { |node| [node[:name], node[:internal_ip][:address]] }.inspect
  rescue => _exception
    raise Error.new("Failed to detect node")
  end

  def set_pods
    res = `kubectl -n #{namespace} get po -o json | jq -r '[.items[] | { name: .metadata.name, host_ip: .status.hostIP, pod_ip: .status.podIP }]'`
    @pods = JSON.parse res, symbolize_names: true
    @logger.info "Pods: %s" % @pods.map { |pod| [pod[:name], pod[:pod_ip]] }.inspect
  rescue => _exception
    raise Error.new "Failed to find pods"
  end

  def set_ingress
    res = `kubectl -n #{namespace} get ing #{ingress_name} -o json | jq -r '[.status[] | { ip: .ingress[].ip }]'`
    @ingress = JSON.parse res, symbolize_names: true
    @logger.info "Ingress: %s" % @ingress.map { |ing| [ing[:ip]] }
  rescue => _exception
    raise Error.new "Failed to set ingress"
  end

  def set_database_loadbalancer
    res = `kubectl -n #{namespace} get svc #{database_loadbalancer_name} -o json | jq -r '[.status[] | { ip: .ingress[].ip }]'`
    @database_loadbalancer = JSON.parse res, symbolize_names: true
    @logger.info "DB Loadbalancer: %s" % @database_loadbalancer.map { |lb| [lb[:ip]] }
  rescue => _exception
    raise Error.new "Failed to set database loadbalancer"
  end
end
