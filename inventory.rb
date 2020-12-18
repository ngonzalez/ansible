#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'securerandom'
require 'yaml'

ansible_port		= ENV['ANSIBLE_PORT'].to_i
ansible_user		= ENV['ANSIBLE_USER']
namespace		= ENV['NAMESPACE']
gcloud_user		= ENV['GCLOUD_USER']

namespaces = JSON.parse `kubectl get namespaces -o json | jq -r '[.items[] | .metadata.name ]'`

raise "Invalid namespace" unless namespaces.include? namespace

nodes = JSON.parse `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | {
	name:.metadata.name,
	external_ip:.status.addresses[] | select(.type=="ExternalIP"),
	internal_ip:.status.addresses[] | select(.type=="InternalIP")
}]'`

raise "No nodes found" if nodes.empty?

pods = JSON.parse `kubectl -n #{namespace} get po -o json | jq -r '[.items[] | {
	name:.metadata.name,
	host_ip:.status.hostIP,
	pod_ip:.status.podIP
}]'`

raise "No pods found" if pods.empty?

inventory_hash = pods.each_with_object({}) do |item, hash|

	random_id = Digest::SHA256.hexdigest(SecureRandom.uuid)[0..10].upcase

	item_node = nodes.detect { |node| node['internal_ip']['address'] == item['host_ip'] }
	
	item_external_ip_address = item_node['external_ip']['address']

	hash[random_id] = {
		'hosts' => {
			item['name'] => {
				'ansible_host' => item['pod_ip'],
				'ansible_port' => ansible_port,
				'ansible_user' => ansible_user,
			}
		},
		'vars' => {
			'ansible_ssh_common_args' => "-o ProxyCommand=\"ssh -W %h:%p -q #{gcloud_user}@#{item_external_ip_address}\""
		},
	}

end

File.open("inventory.yml", "w") do |f|
	f.write inventory_hash.to_yaml
end

exit 0
