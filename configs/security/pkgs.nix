{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                        NETWORK & SECURITY TOOLS                         |
    # ============================================================================
    # Network Analysis
    nmap # Network scanner
    wireshark-cli # Network analyzer
    tcpdump # Packet analyzer
    netcat # Network utility
    openssl # SSL/TLS toolkit

    # Security Scanning
    trivy # Vulnerability scanner
    grype # Vulnerability scanner
    syft # Software composition analysis
    semgrep # Static analysis
    bandit # Python security linter
    pip-audit # Python dependency audit

    # Secrets Management
    vault # Secrets management
    sops # Secrets encryption
    age # File encryption
    gopass # Password manager
    pass # Password store
    keychain # SSH key management

    # Security Analysis
    nuclei # Vulnerability scanner
    subfinder # Subdomain discovery
    amass # Subdomain enumeration
    assetfinder # Asset discovery
    waybackurls # Wayback machine URLs
    gau # Get all URLs
    ffuf # Web fuzzer
    gobuster # Directory/file brute forcer
    dirb # Web content scanner
    nikto # Web vulnerability scanner
  ];
}

