---
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-install
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-install
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: argocd-install
    namespace: kube-system
---
apiVersion: batch/v1
kind: Job
metadata:
  name: argocd-install
  namespace: kube-system
spec:
  backoffLimit: 10
  template:
    metadata:
      labels:
        app: argocd-install
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
      serviceAccountName: argocd-install
      containers:
        - name: argocd-install
          image: docker.io/bitnami/kubectl:latest
          command:
            - "bin/bash"
            - "-c"
            - "kubectl apply -n argocd -f https://github.com/argoproj/argo-cd/raw/release-${argocd_release}/manifests/install.yaml"
