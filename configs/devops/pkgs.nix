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
    k3s # Lightweight Kubernetes (kept as the single small k8s; minikube/kind removed)
    k9s # Kubernetes TUI
    # Removed: minikube, kind (heavy, occasional local k8s; use k3s or external clusters)

    # ============================================================================
    # |                        INFRASTRUCTURE AS CODE                           |
    # ============================================================================
    terraform # Infrastructure provisioning
    terraform-ls # Terraform language server
    terragrunt # Terraform wrapper
    # pulumi removed (large, occasional IaC use; bring in ad-hoc via nix shell if needed)
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
    # Removed heavy self-hosted observability (prom/grafana/loki) for debloat;
    # they are occasional-use and pull large Go/JS closures. Use hosted or
    # `nix shell` for one-offs. Kept the light shippers/exporters for basic host monitoring.
    grafana-alloy # Log/metric/trace shipping (promtail successor) -- kept (light)
    prometheus-node-exporter # Node metrics -- kept (light)
    cadvisor # Container metrics -- kept (light)
    # Removed: prometheus, grafana, loki, elasticsearch

    # ELK Stack
    tuistash # TUI for Logstash
    # kibana # ELK Stack UI - removed due to EOL Node.js dependency
    # logstash # ELK Stack log shipping - conflicts with elasticsearch
    # elasticsearch removed (heavy; was only for occasional local ELK)

    # ============================================================================
    # |                            CLOUD & API TOOLS                           |
    # ============================================================================
    # Cloud Providers
    awscli2 # AWS command line
    azure-cli # Azure command line
    google-cloud-sdk # Google Cloud SDK
    # amazon-ecs-cli # Amazon ECS CLI # Deprecated in favor of AWS Copilot CLI.
    # copilot-cli # Removed from nixpkgs (upstream EOL — AWS archived the project).
    # acr-cli: temporarily removed — nixpkgs 0.18.1 tests fail on current Go (ParseDuration error type mismatch in purge_test.go).

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

