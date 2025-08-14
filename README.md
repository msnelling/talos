# Talos Repository

This repository contains the configuration and setup for Talos, a modern operating system for Kubernetes clusters. Below are the steps to get started with this repository using `go-task`.

## Prerequisites

1. Install [Go Task](https://taskfile.dev/):
   ```bash
   brew install go-task/tap/go-task
   ```

## Getting Started

1. Install the required tools using the `init-macos` task:
   ```bash
   task init-macos
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd talos
   ```

3. Review the available tasks:
   ```bash
   task --list
   ```

4. Bring up the entire system:
   ```bash
   task up
   ```

5. To tear down the system:
   ```bash
   task teardown
   ```

## Taskfile Overview

The `Taskfile.yml` contains predefined tasks to simplify the workflow. Below are some of the key tasks:

### Infrastructure Management
- `up`: Brings up the entire system in order (bootstrap → proxmox → system → base)
- `teardown`: Tears down the entire system in reverse order
- `rebuild`: Complete teardown and rebuild from scratch
- `00-bootstrap`: Sets up the initial bootstrap configuration
- `01-proxmox`: Deploys the Proxmox-related configuration  
- `02-system`: Applies the system-level configuration
- `03-base`: Deploys the base configuration for the cluster

### Talos Upgrades

This repository includes comprehensive Talos upgrade functionality that uses terraform outputs to discover nodes and supports flexible version management.

#### Quick Upgrade Commands

```bash
# Upgrade all nodes using the default version
task upgrade-talos

# Upgrade to a specific version
task upgrade-talos VERSION=v1.11.0

# Upgrade only controllers (safer for etcd)
task upgrade-controllers VERSION=v1.11.0

# Upgrade only workers
task upgrade-workers VERSION=v1.11.0

# Sequential upgrade (safest, one node at a time)
task upgrade-talos-sequential VERSION=v1.11.0

# Upgrade a single node
task upgrade-node NODE=10.1.1.124 VERSION=v1.11.0
```

#### Upgrade Management

```bash
# Check current versions on all nodes
task check-versions

# Set the default upgrade version permanently
task set-upgrade-version VERSION=v1.11.0

# Check upgrade status
task check-upgrade-status

# Perform health check
task health-check
```

#### How Upgrades Work

The upgrade system:
1. **Gets node IPs from terraform outputs** - No dependency on Kubernetes being available
2. **Uses your custom schematic** - Preserves hardware compatibility from your terraform configuration
3. **Supports version override** - Default version in Taskfile, override with `VERSION=x.x.x`
4. **Upgrades safely** - Controllers first (sequential), then workers
5. **Waits for readiness** - Ensures each node is healthy before proceeding

The upgrade image is dynamically constructed as:
```
factory.talos.dev/nocloud-installer/{your-schematic-id}:{version}
```

#### Upgrade Strategies

- **`upgrade-talos`**: Recommended approach - upgrades controllers sequentially, then workers
- **`upgrade-talos-sequential`**: Safest approach - upgrades all nodes one by one
- **`upgrade-controllers`** + **`upgrade-workers`**: Fine-grained control over the upgrade process

### Version Management

The Taskfile supports flexible version management:

- **Default version**: Set in `TALOS_UPGRADE_VERSION` variable (currently `v1.10.6`)
- **Command-line override**: Use `VERSION=v1.x.x` with any upgrade task
- **Permanent update**: Use `task set-upgrade-version VERSION=v1.x.x`

### Monitoring and Health Checks

```bash
# Comprehensive cluster health check
task health-check

# Check current Talos versions on all nodes  
task check-versions

# Check upgrade status
task check-upgrade-status
```

## Architecture

The repository is organized into stages that build upon each other:

1. **00-bootstrap**: Initial Vault and basic infrastructure setup
2. **01-proxmox**: Virtual machine provisioning and Talos image deployment
3. **02-system**: Talos cluster configuration and Kubernetes bootstrap
4. **03-base**: Base applications and services (ArgoCD, cert-manager, etc.)

## Node Discovery

Node discovery is done via terraform outputs rather than kubectl, making upgrades more reliable:

- **Controller nodes**: Retrieved from `terraform output controller_nodes`
- **Worker nodes**: Retrieved from `terraform output worker_nodes`  
- **All nodes**: Combined list of controllers and workers
- **IP addresses**: Extracted from terraform state, sorted and deduplicated

This approach works even when:
- Kubernetes cluster is down or unhealthy
- During initial cluster setup
- When nodes are being upgraded and temporarily unavailable

## Dependencies

The following tools are automatically installed via `task init-macos`:

- go-task
- kubectl  
- kustomize
- helm
- terraform
- talosctl
- k9s
- yq
- jq
