#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'optparse'
require 'securerandom'
require 'yaml'

option_parser = OptionParser.new do |opts|
  opts.on '-n', '--namespace', 'Kubernetes namespace'
  opts.on '-a', '--account', 'Kubernetes account'
  opts.on '-u', '--user', 'Ansible user'
  opts.on '-p', '--port', 'Ansible port'
end

options = {}
option_parser.parse!(into: options)
options.each_with_index { |(k,v),i| options[k] = ARGV[i] }

class Kubernetes
	attr_accessor :namespace, :namespaces, :nodes, :pods
	def initialize(namespace)
		@namespace = namespace
		raise "Invalid namespace" unless namespaces.include? namespace
	end
	def namespaces
		@namespaces ||= JSON.parse `kubectl get namespaces -o json | jq -r '[.items[] | .metadata.name ]'`
	end
	def nodes
		@nodes ||= JSON.parse `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | {
			name:.metadata.name,
			external_ip:.status.addresses[] | select(.type=="ExternalIP"),
			internal_ip:.status.addresses[] | select(.type=="InternalIP")
		}]'`
	end
	def pods
		@pods ||= JSON.parse `kubectl -n #{namespace} get po -o json | jq -r '[.items[] | {
			name:.metadata.name,
			host_ip:.status.hostIP,
			pod_ip:.status.podIP
		}]'`
	end
end

kube = Kubernetes.new options[:namespace]

inventory_hash = kube.pods.each_with_object({}) do |item, hash|

	random_id = Digest::SHA256.hexdigest(SecureRandom.uuid)[0..10].upcase

	item_node = kube.nodes.detect { |node| node['internal_ip']['address'] == item['host_ip'] }
	
	item_external_ip_address = item_node['external_ip']['address']

	hash[random_id] = {
		'hosts' => {
			item['name'] => {
				'ansible_host' => item['pod_ip'],
				'ansible_port' => options[:port].to_i,
				'ansible_user' => options[:user],
			}
		},
		'vars' => {
			'ansible_ssh_common_args' => "-o ProxyCommand=\"ssh -W %h:%p -q #{options[:account]}@#{item_external_ip_address}\"",
		},
	}

end

File.open("inventory.yml", "w") do |f|
	f.write inventory_hash.to_yaml
end

exit 0
