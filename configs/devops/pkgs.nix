{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                        CONTAINER & ORCHESTRATION                        |
    # ============================================================================
    # Container Runtime
    docker # Container runtime
    docker-compose # Multi-container orchestration
    buildah # Container image builder
    skopeo # Container image operations
    crane # Container registry operations

    # Kubernetes
    helm # Kubernetes package manager
    kustomize # Kubernetes configuration management
    minikube # Local Kubernetes
    kind # Kubernetes in Docker
    k3s # Lightweight Kubernetes
    k9s # Kubernetes TUI

    # ============================================================================
    # |                        INFRASTRUCTURE AS CODE                           |
    # ============================================================================
    terraform # Infrastructure provisioning
    terraform-ls # Terraform language server
    terragrunt # Terraform wrapper
    pulumi # Infrastructure as code
    ansible # Configuration management
    ansible-lint # Ansible linting

    # ============================================================================
    # |                            CI/CD & BUILD                               |
    # ============================================================================
    gitlab-runner # GitLab CI runner
    github-runner # GitHub Actions runner

    # ============================================================================
    # |                        MONITORING & OBSERVABILITY                       |
    # ============================================================================
    # Metrics & Logging
    prometheus # Metrics collection
    grafana # Metrics visualization
    loki # Log aggregation
    promtail # Log shipping
    prometheus-node-exporter # Node metrics
    cadvisor # Container metrics

    # ELK Stack
    tuistash # TUI for Logstash
    # kibana # ELK Stack UI - removed due to EOL Node.js dependency
    # logstash # ELK Stack log shipping - conflicts with elasticsearch
    elasticsearch # ELK Stack search and analytics

    # ============================================================================
    # |                            CLOUD & API TOOLS                           |
    # ============================================================================
    # Cloud Providers
    awscli2 # AWS command line
    azure-cli # Azure command line
    google-cloud-sdk # Google Cloud SDK
    # amazon-ecs-cli # Amazon ECS CLI # FUCKING DEPRICATED IN FAVOR OF AWS Copilot CLI.
    copilot-cli
    acr-cli # Azure Container Registry CLI

    # VPS Providers
    doctl # DigitalOcean CLI
    linode-cli # Linode CLI
    vultr-cli # Vultr CLI

    # ============================================================================
    # |                            DEVOPS TUI TOOLS                            |
    # ============================================================================
    lazydocker # Docker TUI
    stern # Kubernetes log tailing
    lazyhetzner # Hetzner Cloud TUI
  ];
}

