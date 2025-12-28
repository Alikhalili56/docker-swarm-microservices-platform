# Microservices Infrastructure with Docker Swarm

A fully automated, production-ready microservices infrastructure deployment using Ansible, Docker Swarm, and modern DevOps practices. This project demonstrates infrastructure as code, container orchestration, centralized authentication, and comprehensive observability.

## Project Overview

This project deploys a complete microservices ecosystem featuring:

- **Git Server**: Forgejo with Single Sign-On authentication
- **Authentication**: Centralized SSO via Dex (OpenID Connect)
- **Monitoring**: Prometheus + Grafana with custom dashboards
- **Logging**: Loki + Promtail for centralized log aggregation
- **Reverse Proxy**: Traefik with automatic service discovery and TLS
- **Database**: PostgreSQL for persistent data storage
- **Container Registry**: Private Docker registry for custom images
- **Orchestration**: Docker Swarm for high availability and automatic failover

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ USERS: Browser → https://*.vcc.internal                         │
├─────────────────────────────────────────────────────────────────┤
│ TRAEFIK: Reverse proxy, TLS termination, service discovery      │
├─────────────────────────────────────────────────────────────────┤
│ APPLICATIONS: Forgejo, Grafana, Dex, Prometheus, Loki           │
├─────────────────────────────────────────────────────────────────┤
│ DATABASE: PostgreSQL (shared by Forgejo, Dex, Grafana)          │
├─────────────────────────────────────────────────────────────────┤
│ ORCHESTRATION: Docker Swarm (manager + worker nodes)            │
├─────────────────────────────────────────────────────────────────┤
│ STORAGE: NFS shared storage across all nodes                    │
├─────────────────────────────────────────────────────────────────┤
│ INFRASTRUCTURE: Ubuntu 24.04 VMs (automated via Vagrant)         │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

- **Fully Automated Deployment**: Single command deploys entire infrastructure
- **Infrastructure as Code**: All configuration in version-controlled Ansible playbooks
- **High Availability**: Docker Swarm provides automatic failover and load balancing
- **Centralized Authentication**: Single Sign-On across all services via Dex
- **Comprehensive Monitoring**: Real-time metrics and dashboards for all services
- **Centralized Logging**: All container logs aggregated and searchable
- **Secure by Default**: TLS encryption, secrets management via Ansible Vault
- **Service Discovery**: Automatic routing via Traefik with Docker Swarm labels

## Quick Start

### Prerequisites

- **Vagrant** (with VMware provider)
- **Python 3.12+**
- **Make**

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd exam-0-0
```

2. Set up Python environment and Ansible:
```bash
make python-setup
```

3. Start virtual machines:
```bash
vagrant up
```

4. Deploy the entire infrastructure:
```bash
make setup-all
```

The deployment takes approximately 15 minutes. Once complete, access the services:

- **Forgejo (Git)**: https://git.vcc.internal
- **Grafana (Monitoring)**: https://mon.vcc.internal
- **Prometheus**: https://prom.vcc.internal
- **Dex (Auth)**: https://auth.vcc.internal

**Default credentials**: `admin` / `password` (change these in production!)

## Available Make Targets

- `make setup-all` - Full deployment from scratch
- `make setup-from-images-onwards` - Rebuild images and redeploy services
- `make setup-from-service-onwards` - Redeploy services only (fastest iteration)
- `make python-setup` - Set up Python virtual environment with Ansible

## Project Structure

```
.
├── playbook.yml              # Main Ansible playbook
├── inventory                 # Ansible inventory file
├── Vagrantfile              # VM configuration
├── Makefile                 # Automation targets
├── requirements.txt         # Python dependencies
├── requirements.yml         # Ansible collections
├── group_vars/
│   └── all/
│       ├── vars.yml         # Configuration variables
│       └── vault.yml        # Encrypted secrets (Ansible Vault)
└── roles/
    ├── docker/              # Docker installation
    ├── docker-swarm/        # Swarm cluster setup
    ├── nfs/                 # Shared storage configuration
    ├── tls-certificate/     # TLS certificate generation
    ├── docker-registry/     # Private container registry
    ├── swarm-images/        # Custom image building
    ├── pull-images/         # Image distribution
    └── swarm-services/      # Service deployment
        ├── templates/
        │   └── exam.yml     # Docker Compose stack definition
        └── files/
            ├── configs/     # Service configurations
            └── images/      # Custom Dockerfiles
```

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Automation | Ansible | Infrastructure provisioning and configuration |
| Orchestration | Docker Swarm | Container orchestration and high availability |
| Reverse Proxy | Traefik v3.6.2 | Traffic routing, TLS termination, service discovery |
| Git Server | Forgejo 9.0.3 | Self-hosted Git service |
| Authentication | Dex v2.41.1 | OpenID Connect provider for SSO |
| Database | PostgreSQL 17 | Persistent data storage |
| Monitoring | Prometheus v3.0.1 | Metrics collection and alerting |
| Visualization | Grafana 11.4.0 | Dashboards and data visualization |
| Logging | Loki 3.3.1 + Promtail 3.2.2 | Log aggregation and querying |
| Storage | NFS | Shared persistent storage |
| Metrics Export | Node Exporter v1.8.2 | System-level metrics |

## Security Features

- **Secrets Management**: All sensitive data encrypted with Ansible Vault
- **TLS Encryption**: All services accessible only via HTTPS
- **Authentication**: Centralized SSO prevents credential sprawl
- **Network Isolation**: Services communicate via internal Docker networks
- **Registry Authentication**: Private registry requires authentication
- **No Exposed Ports**: Only Traefik (80/443) exposed externally

## Monitoring & Observability

The project includes pre-configured Grafana dashboards for:

- **Monitoring Stack**: Health status of all services
- **Traefik Metrics**: Request rates, response times, error rates
- **Swarm Nodes**: CPU, memory, disk usage per node
- **Logging Stack**: Centralized log exploration and search

All services expose Prometheus metrics and send logs to Loki for comprehensive observability.

## Learning Outcomes

This project demonstrates proficiency in:

- **Infrastructure as Code**: Declarative infrastructure management
- **Container Orchestration**: Multi-node cluster management with Swarm
- **Service Mesh**: Internal service discovery and communication
- **Observability**: Metrics collection, log aggregation, and visualization
- **Security**: Secrets management, TLS, and centralized authentication
- **DevOps Practices**: Automation, reproducibility, and documentation

## Development Workflow

### Iterating on Services

1. Modify service configuration in `roles/swarm-services/templates/exam.yml`
2. Run `make setup-from-service-onwards` to redeploy
3. Check logs: `vagrant ssh target1 -c "sudo docker service logs <service-name>"`

### Building Custom Images

1. Add Dockerfile to `roles/swarm-images/files/images/<image-name>/`
2. Run `make setup-from-images-onwards` to rebuild and deploy
3. Images are automatically pushed to the local registry

### Debugging

```bash
# Check service status
vagrant ssh target1 -c "sudo docker service ls"

# View service logs
vagrant ssh target1 -c "sudo docker service logs <service-name>"

# Inspect service details
vagrant ssh target1 -c "sudo docker service ps <service-name> --no-trunc"

# Check Swarm nodes
vagrant ssh target1 -c "sudo docker node ls"
```

## Production Considerations

To make this production-ready, consider:

- **Alerting**: Add Alertmanager for automated notifications
- **Backups**: Implement automated database and volume backups
- **High Availability**: Add PostgreSQL replication
- **Resource Limits**: Define CPU/memory limits for all services
- **Security Hardening**: Run containers as non-root users
- **Scaling**: Add more worker nodes for increased capacity
- **External DNS**: Replace `.vcc.internal` with real domain names
- **Certificate Management**: Use Let's Encrypt for trusted certificates

## Configuration

### Customizing Variables

Edit `group_vars/all/vars.yml` to customize:
- Domain names
- Service versions
- Resource allocations
- Network configuration

### Managing Secrets

Secrets are stored in `group_vars/all/vault.yml` (encrypted with Ansible Vault):

```bash
# Edit encrypted secrets
ansible-vault edit group_vars/all/vault.yml

# Vault password is in .vault_pass (not committed to git)
```

## Contributing

This project was developed as part of the Virtualization and Cloud Computing course at Università di Genova (DIBRIS).

## Acknowledgments

- **Course**: Virtualization and Cloud Computing 2024
- **Instructors**: Giacomo Longo, Enrico Russo
- **Institution**: Università di Genova - DIBRIS
