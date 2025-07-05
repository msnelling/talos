---
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
---
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bootstrap-job
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bootstrap-job
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: bootstrap-job
    namespace: kube-system
---
apiVersion: batch/v1
kind: Job
metadata:
  name: bootstrap
  namespace: kube-system
spec:
  backoffLimit: 10
  template:
    metadata:
      labels:
        app: bootstrap
    spec:
      restartPolicy: OnFailure
      tolerations:
        - operator: Exists
        - effect: NoSchedule
          operator: Exists
        - effect: NoExecute
          operator: Exists
        - effect: PreferNoSchedule
          operator: Exists
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoSchedule
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoExecute
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: PreferNoSchedule
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
      serviceAccountName: bootstrap-job
      containers:
        - name: bootstrap
          image: docker.io/alpine/k8s:${kube_version}
          command:
            - /bin/sh
            - -c
            - |
              set -ex
              kubectl wait --for=condition=Available --timeout=300s -n kube-system deployment/coredns

              helm repo add external-secrets https://charts.external-secrets.io
              helm repo update

              helm template external-secrets external-secrets/external-secrets -n external-secrets | kubectl apply -f -
              kubectl wait --for=condition=Available --timeout=300s -n external-secrets deployment/external-secrets

              kustomize build --enable-helm https://github.com/msnelling/argocd-bootstrap.git//argocd | kubectl apply -n argocd -f -
              kubectl wait --for=condition=Available --timeout=300s -n argocd deployment/argocd-server
