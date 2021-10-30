require "pry"

class Error < StandardError ; end

class Kubernetes
  attr_accessor :namespaces, :nodes, :pods, :ingress
  attr_accessor :namespace, :ingress_name

  def initialize(namespace: nil, ingress_name: nil)
    # logger
    @logger = Logger.new $stdout

    # init
    @namespace = namespace
    @ingress_name = ingress_name
    @namespaces = []
    @nodes = []
    @pods = []

    set_namespaces
    set_nodes
    set_pods
    set_ingress
  rescue => _exception
    @logger.error Error.new(_exception.message)
  end

    private

  def set_namespaces
    res = `kubectl get ns -o json | jq -r '[.items[] | { name: .metadata.name }]'`
    @namespaces = JSON.parse res, symbolize_names: true
    raise Error.new("Invalid namespace") unless namespaces.map { |ns| ns[:name] }.include?(namespace)
  rescue => _exception
    raise Error.new("Failed to detect namespace")
  end

  def set_nodes
    res = `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | { name: .metadata.name, internal_ip: .status.addresses[] | select(.type=="InternalIP") }]'`
    @nodes = JSON.parse res, symbolize_names: true
  rescue => _exception
    raise Error.new("Failed to detect node")
  end

  def set_pods
    res = `kubectl -n #{namespace} get po -o json | jq -r '[.items[] | { name: .metadata.name, host_ip: .status.hostIP, pod_ip: .status.podIP }]'`
    @pods = JSON.parse res, symbolize_names: true
  rescue => _exception
    raise Error.new "Failed to find pods"
  end

  def set_ingress
    res = `kubectl -n #{namespace} get ing #{ingress_name} -o json | jq -r '[.status[] | { ip: .ingress[].ip }]'`
    @ingress_name = JSON.parse res, symbolize_names: true
  rescue => _exception
    raise Error.new "Failed to set ingress"
  end
end
