machine:
  network:
    interfaces:
      - interface: eth0
        dhcp: true
        vip:
          ip: ${vip}

cluster:
  allowSchedulingOnControlPlanes: ${schedule_on_controllers}
  extraManifests:
    # Install the Gateway API CRDs
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/experimental/gateway.networking.k8s.io_gateways.yaml
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
    - https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v${gateway_api_version}/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
  inlineManifests:
    # Cilium Helm values
    - name: cilium-values
      contents: |
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: cilium-values
          namespace: kube-system
        data:
          values.yaml: |-
            ${indent(12, cilium_values)}
    # Install Cilium
    - name: cilium-bootstrap
      contents: |
        ${indent(8, cilium_install)}
    # Cilium IP pools
    - name: cilium-ip-pools
      contents: |
        apiVersion: "cilium.io/v2alpha1"
        kind: CiliumLoadBalancerIPPool
        metadata:
          name: traefik
        spec:
          blocks:
            - start: "10.1.1.48"
          serviceSelector:
            matchLabels:
              io.kubernetes.service.namespace: traefik
              io.kubernetes.service.name: traefik
    # Install ArgoCD
    - name: argocd-install
      contents: |
        ${indent(8, argocd_install)}
    # ArgoCD bootstrap project
    - name: argocd-bootstrap
      contents: |
        ${indent(8, argocd_bootstrap)}
