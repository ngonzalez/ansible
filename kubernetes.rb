class Kubernetes
	attr_accessor :namespace, :namespaces, :nodes, :pods
	def initialize(namespace)
		@namespace = namespace
		raise "Invalid namespace" unless namespaces.include? namespace
	end

	def namespaces ; @namespaces ||= set_namespaces ; end
	def nodes ; @nodes ||= set_nodes ; end
	def pods ; @pods ||= set_pods ; end

		private

	def set_namespaces
		JSON.parse `kubectl get namespaces -o json | jq -r '[.items[] |
			.metadata.name
		]'`, symbolize_names: true
	end

	def set_nodes
		JSON.parse `kubectl -n #{namespace} get no -o json | jq -r '[.items[] | {
			name:.metadata.name,
			external_ip:.status.addresses[] | select(.type=="ExternalIP"),
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
end
