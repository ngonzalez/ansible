class Kubernetes
	attr_accessor :namespace, :ingress_name, :database_loadbalancer_name
	def initialize(namespace, ingress_name=nil, database_loadbalancer_name=nil)
		@namespace = namespace
		raise "Invalid namespace" unless namespaces.include? namespace
		@ingress_name = ingress_name unless ingress_name.nil?
		@database_loadbalancer_name = database_loadbalancer_name unless database_loadbalancer_name.nil?
	end

	attr_accessor :namespaces, :nodes, :pods, :ingress_ip
	def namespaces ; @namespaces ||= set_namespaces ; end
	def nodes ; @nodes ||= set_nodes ; end
	def pods ; @pods ||= set_pods ; end
	def ingress_ip ; @ingress_ip ||= set_ingress_ip ; end
	def database_loadbalancer_ip ; @database_loadbalancer_ip ||= set_database_loadbalancer_ip ; end

		private

	def set_namespaces
		JSON.parse `kubectl get ns -o json | jq -r '[.items[] |
			.metadata.name
		]'`, symbolize_names: true
	end

	def set_nodes
		JSON.parse `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | {
			name:.metadata.name,
			internal_ip:.status.addresses[] | select(.type=="InternalIP")
		}]'`, symbolize_names: true
	end

	def set_pods
		JSON.parse `kubectl -n #{namespace} get po -o json | jq -r '[.items[] | {
			name:.metadata.name,
			host_ip:.status.hostIP,
			pod_ip:.status.podIP
		}]'`, symbolize_names: true
	end

	def set_ingress_ip
		JSON.parse `kubectl -n #{namespace} get ing #{ingress_name} -o json | jq -r '[.status[] | {
			ip: .ingress[].ip,
		}]'`, symbolize_names: true
	end

	def set_database_loadbalancer_ip
		JSON.parse `kubectl -n #{namespace} get svc #{database_loadbalancer_name} -o json | jq -r '[.status[] | {
			ip: .ingress[].ip,
		}]'`, symbolize_names: true
	end
end
