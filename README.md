# Holynix
<a href="https://nixos.wiki/wiki/Flakes" target="_blank"><img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge"></a>
<a href="https://github.com/snowfallorg/lib" target="_blank"><img alt="Built With Snowfall" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&labelColor=5e81ac&message=Snowfall&color=d8dee9&style=for-the-badge"></a>

My own little nix config to manage multiple systems.

# Systems

## Personal Computer
- **[Yon](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/Yon/default.nix)**: Framework 16 Laptop (CPU: AMD Ryzen 7 7840HS; GPU: AMD Radeon 7700S) for gaming, school and development.
- **[Zeta](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/Zeta/default.nix)**: Tower PC (CPU: Intel I5) for office work and picture editing.
- **[PC-Carmen](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/PC-Carmen/default.nix)**: A Lenovo Laptop for office work and websurfing.

## VMs
- **[node1](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/node1/default.nix)**: VM for Kubernetes (k3s)
- **[node2](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/node2/default.nix)**: VM for Kubernetes (k3s)
- **[node3](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/node3/default.nix)**: VM for Kubernetes (k3s)

## Server
- **[srv-raspi5](https://github.com/Svenum/holynix/blob/main/systems/aarch64-linux/srv-raspi5/default.nix)**: Raspberry Pi 5 8GB RAM as little home-server.
- **[srv-dev](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/srv-dev/default.nix)**: VM for development over RDP/VNC.
- **[srv-dev](https://github.com/Svenum/holynix/blob/main/systems/x86_64-linux/srv-oracle/default.nix)** VM inside of the Oracle Cloud (CPU: 2.0 GHz AMD EPYC™ 7551, Shape: VM.Standard.E2.1.Micro) for Docker.
