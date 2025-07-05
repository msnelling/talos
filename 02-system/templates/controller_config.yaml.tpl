machine:
  network:
    interfaces:
      - interface: eth0
        dhcp: true
        vip:
          ip: ${vip_ipv4}

cluster:
  apiServer:
    certSANs:
%{ for san in cert_sans }
      - ${san}
%{ endfor }
  allowSchedulingOnControlPlanes: ${schedule_on_controllers}
%{ if gateway_api_enabled }
  extraManifests:
    - https://github.com/kubernetes-sigs/gateway-api/releases/download/v${gateway_api_version}/standard-install.yaml
%{ if gateway_api_experimental }
    - https://github.com/kubernetes-sigs/gateway-api/releases/download/v${gateway_api_version}/experimental-install.yaml
%{ endif }
%{ endif }
  inlineManifests:
%{ if cilium_enabled }
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
%{ endif }
    # Bootstrap Job
    - name: bootstrap-job
      contents: |
        ${indent(8, bootstrap_job)}
    # ArgoCD bootstrap project
    - name: argocd-bootstrap
      contents: |
        ${indent(8, argocd_bootstrap)}
