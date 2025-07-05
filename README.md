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

- `up`: Brings up the entire system in order.
- `teardown`: Tears down the entire system.
- `00-bootstrap`: Sets up the initial bootstrap configuration.
- `01-proxmox`: Deploys the Proxmox-related configuration.
- `02-system`: Applies the system-level configuration.
- `03-base`: Deploys the base configuration for the cluster.
