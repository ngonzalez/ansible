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
  opts.on '-l', '--loadbalancers', 'Loadbalancers list'
end

options = {}
option_parser.parse!(into: options)
options.each_with_index { |(k,v),i| options[k] = ARGV[i] }

@logger = Logger.new $stdout

require_relative 'kubernetes'

kube = Kubernetes.new(
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

class String
  def underscore
    self.gsub('-', '_')
  end
end

if !kube.loadbalancers.empty?
  hsh = {}
  kube.loadbalancers.each do |name, ip|
    hsh.merge! name.underscore => ip
  end
  begin
    FileUtils.rm_f('roles/app/vars/inventory.yml')
    File.open('roles/app/vars/inventory.yml', 'w') { |f| f.write hsh.to_yaml }
  rescue => _exception
    @logger.error "Failed to write loadbalancers inventory details"
  end
end

exit 0
