cluster:
  name: homelab
  id: 1

l7Proxy: true
kubeProxyReplacement: true

# https://docs.cilium.io/en/stable/network/concepts/ipam/
ipam:
  mode: kubernetes

# Talos specific
k8sServiceHost: localhost
k8sServicePort: 7445
securityContext:
  capabilities:
    ciliumAgent: 
      - CHOWN
      - KILL
      - NET_ADMIN
      - NET_RAW
      - IPC_LOCK
      - SYS_ADMIN
      - SYS_RESOURCE
      - DAC_OVERRIDE
      - FOWNER
      - SETGID
      - SETUID
    cleanCiliumState:
      - NET_ADMIN
      - SYS_ADMIN
      - SYS_RESOURCE
cgroup:
  autoMount:
    enabled: false
  hostRoot: /sys/fs/cgroup

# Roll out cilium agent pods automatically when ConfigMap is updated.
rollOutCiliumPods: true
#resources:
#  limits:
#    cpu: 1000m
#    memory: 1Gi
#  requests:
#    cpu: 200m
#    memory: 512Mi

# Increase rate limit when doing L2 announcements
k8sClientRateLimit:
  qps: 20
  burst: 100

l2announcements:
  enabled: true

externalIPs:
  enabled: false

ciliumEndpointSlice:
  enabled: true

loadBalancer:
  # https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/#maglev-consistent-hashing
  algorithm: maglev

gatewayAPI:
  enabled: false

operator:
  rollOutPods: true
#  resources:
#    limits:
#      cpu: 500m
#      memory: 256Mi
#    requests:
#      cpu: 50m
#      memory: 128Mi

envoy:
  rollOutPods: true
  securityContext:
    privileged: true
    capabilities:
      keepCapNetBindService: true
      envoy:
        - NET_ADMIN
        - PERFMON
        - BPF
#        # Enable NET_BIND_SERVICE capability to use port numbers < 1024, e.g. 80 or 443
#        - NET_BIND_SERVICE

ingressController:
  enabled: true
  default: true
  loadbalancerMode: shared
  service:
    annotations:
      lbipam.cilium.io/ips: ${loadbalancer_ip}

hubble:
  enabled: true
  relay:
    enabled: true
    rollOutPods: true
  ui:
    enabled: true
    rollOutPods: true
