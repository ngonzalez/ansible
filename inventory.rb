#!/usr/bin/env ruby

require 'digest'
require 'fileutils'
require 'json'
require 'logger'
require 'optparse'
require 'securerandom'
require 'yaml'
# require 'pry'

option_parser = OptionParser.new do |opts|
  opts.on '-n', '--namespace', 'Kubernetes namespace'
  opts.on '-a', '--account', 'Kubernetes account'
  opts.on '-u', '--user', 'Ansible user'
  opts.on '-p', '--port', 'Ansible port'
  opts.on '-l', '--app_loadbalancer', 'App Loadbalancer'
  opts.on '-d', '--database_loadbalancer', 'Database Loadbalancer'
end

options = {}
option_parser.parse!(into: options)
options.each_with_index { |(k,v),i| options[k] = ARGV[i] }

@logger = Logger.new $stdout

require_relative 'kubernetes'

kube = Kubernetes.new(
  namespace: options[:namespace],
  app_loadbalancer_name: options[:app_loadbalancer],
  database_loadbalancer_name: options[:database_loadbalancer],
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
      'ansible_ssh_common_args' => "-o ProxyCommand='ssh -W %h:%p -q #{options[:account]}@#{node[:internal_ip][:address]}'",
    },
  }

end

kube.nodes.map { |item| item[:internal_ip][:address] }.each do |node_ip|
  if `ssh-keygen -F #{node_ip}`.empty?
    `ssh-keyscan -H #{node_ip} >> ~/.ssh/known_hosts`
  end
end

File.open('inventory.yml', 'w') do |f|
  f.write inventory_hash.to_yaml
end

begin
  hsh = {}
  hsh.merge! 'app_cluster_ip' => kube.app_loadbalancer[0][:ip] if kube.app_loadbalancer
  hsh.merge! 'db_cluster_ip' => kube.database_loadbalancer[0][:ip] if kube.database_loadbalancer
  FileUtils.rm_f('roles/app/vars/inventory.yml')
  File.open('roles/app/vars/inventory.yml', 'w') { |f| f.write hsh.to_yaml }
rescue => _exception
  @logger.info "If the ingress is not being assigned an IP: minikube addons enable ingress" if kube.ingress
  @logger.info "Try the following if the load balancer external IP is pending: sudo minikube tunnel" if kube.database_loadbalancer
end

exit 0
