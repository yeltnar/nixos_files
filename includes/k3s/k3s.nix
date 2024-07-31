# docs
# https://search.nixos.org/options?channel=unstable&show=services.k3s.serverAddr&from=0&size=50&sort=relevance&type=packages&query=k3s
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/cluster/k3s/default.nix

# to clean, use `sudo rm -rf /var/lib/rancher ; sudo rm -rf /etc/rancher/`

# considering linking `/etc/rancher/k3s/k3s.yaml` -> `/home/drew/.kube/config`
# (and `chmod +x ...`)

{
  config,
  pkgs, 
  ...
}:
let
  # token can be found on the server (master) at `/var/lib/rancher/k3s/server/node-token` 
  token = "";
  # TODO change token to tokenFile

  serverAddr = ""; # "https://<ip of first node>:6443";
  role = "agent"; # defaults to agent # one of "server" or "agent" for worker only nodes

  services_k3s_options = { 

    enable = true;

    # required for multi node cluster
    token = token;

    extraFlags = toString [
      # "--kubelet-arg=v=4" # add args to k3s
      # "--with-node-id" # this adds a random string to the end of the node names
      # "--node-name nixos-clean-2" # this allows you to change the k8s node name 
    ];

  }
  # merge keys, if provided 
  // (if serverAddr != "" then { serverAddr = serverAddr; } else {}) 
  // (if role != "" then { role = role; } else { role = "agent"; }) 
  // (if token != "" then { token = token; } else {}) 
  ;

in
{

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  
  services.k3s = services_k3s_options;

}

