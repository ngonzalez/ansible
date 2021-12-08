#!/usr/bin/env ruby

require 'digest'
require 'fileutils'
require 'json'
require 'logger'
require 'optparse'
require 'securerandom'
require 'yaml'

option_parser = OptionParser.new do |opts|
  opts.on '-n', '--namespace', 'Kubernetes namespace'
  opts.on '-a', '--account', 'Kubernetes account'
  opts.on '-u', '--user', 'Ansible user'
  opts.on '-p', '--port', 'Ansible port'
  opts.on '-i', '--inventory_file', 'Inventory file'
  opts.on '-v', '--vagrant_ip', 'Vagrant IP'
  opts.on '-l', '--loadbalancers', 'Loadbalancers list'
  opts.on '-p', '--loadbalancers_inventory_file', 'Loadbalancers inventory file'
end

options = {}
option_parser.parse!(into: options)
options.each_with_index { |(k,v),i| options[k] = ARGV[i] }

@logger = Logger.new $stdout

require_relative 'kubernetes'

kube = Kubernetes.new(
  account: options[:account],
  vagrant_ip: options[:vagrant_ip],
  namespace: options[:namespace],
  loadbalancers_names: options[:loadbalancers],
)

inventory_hash = kube.pods.each_with_object({}) do |pod, hash|

  random_id = Digest::SHA256.hexdigest(SecureRandom.uuid)[0..10].upcase

  node = kube.nodes.detect { |node| node[:internal_ip][:address] == pod[:host_ip] }

  hash[random_id] = {
    'hosts' => {
      pod[:name] => {
        'ansible_host' => pod[:pod_ip],
        'ansible_port' => options[:port].to_i,
        'ansible_user' => options[:user],
      },
    },
    'vars' => {
      'ansible_ssh_common_args' => "-o ProxyCommand='ssh -W %h:%p -q #{options[:account]}@#{options[:vagrant_ip]}'",
    },
  }

end

# Add node IP to SSH known_hosts
kube.nodes.map { |item| item[:internal_ip][:address] }.each do |node_ip|
  if `ssh-keygen -F #{node_ip}`.empty?
    `ssh-keyscan -H #{node_ip} >> ~/.ssh/known_hosts`
  end
end

# Update inventory file
begin
  inventory_file = options[:inventory_file]
  FileUtils.rm_f("#{inventory_file}")
  FileUtils.touch("#{inventory_file}")
  File.open("#{inventory_file}", 'w') { |f| f.write inventory_hash.to_yaml }
  @logger.info "Inventory updated: #{inventory_file}"
rescue => _exception
  @logger.error "Failed to write inventory file"
end

# Update Loadbalancers inventory file
if kube.loadbalancers
  begin
    kube_loadbalancers_hash = kube.loadbalancers.each_with_object({}) do |(name, ip), hsh|
      hsh.merge! name.gsub('-', '_') => ip
    end
    loadbalancers_inventory_file = options[:loadbalancers_inventory_file]
    FileUtils.rm_f("#{loadbalancers_inventory_file}")
    FileUtils.touch("#{loadbalancers_inventory_file}")
    File.open(loadbalancers_inventory_file, 'w') { |f| f.write kube_loadbalancers_hash.to_yaml }
    @logger.info "Loadbalancers variables updated: #{loadbalancers_inventory_file}"
    @logger.debug kube_loadbalancers_hash.to_yaml.inspect
  rescue => _exception
    @logger.error "Failed to write loadbalancers inventory file"
  end
end

exit 0
