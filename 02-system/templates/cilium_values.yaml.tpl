ipam:
  mode: kubernetes

operator:
  replicas: 1

gatewayAPI:
  enabled: true

envoy:
  enabled: true

ingressController:
  enabled: true
  loadbalancerMode: shared
  service:
    annotations:
      lbipam.cilium.io/ips: ${loadbalancer_ip}

l7Proxy: true
kubeProxyReplacement: true

serviceAccounts:
  cilium:
    name: cilium
  operator:
    name: cilium-operator

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

k8sServiceHost: localhost
k8sServicePort: 7445
