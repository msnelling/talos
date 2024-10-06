---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: bootstrap
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: Bootstrap Project
  sourceRepos:
    - '*'
  destinations:
    - namespace: '*'
      server: '*'
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  clusterResourceBlacklist:
    - group: cilium.io
      kind: CiliumIdentity
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: bootstrap
  source:
    path: 01-bootstrap
    repoURL: https://github.com/msnelling/argocd-bootstrap.git
    targetRevision: talos
  destination:
    namespace: argocd
    name: in-cluster
  syncPolicy:
    automated: {}
    retry:
      limit: 10 # number of failed sync attempt retries; unlimited number of attempts if less than 0
      backoff:
        duration: 10s # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        factor: 2 # a factor to multiply the base duration after each failed retry
        maxDuration: 3m # the maximum amount of time allowed for the backoff strategy
