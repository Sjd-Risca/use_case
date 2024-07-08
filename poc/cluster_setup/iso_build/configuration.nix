{ config, lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users = {
    demo = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "demo";
    };
  };

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  ];
  services.openssh.enable = true;
  virtualisation.podman.enable = true;
  programs.tmux.enable = true;

  environment.systemPackages = with pkgs; [
    python311
    tanka
    buildah
    vim
    kubie
    k9s
    stern
    tanka
    fzf
  ];

  system.stateVersion = "24.05";
}
