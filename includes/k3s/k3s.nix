{
  config,
  pkgs, 
  ...
}:
let
  token = "";
  exampleServerAddr = "https://<ip of first node>:6443";
  serverAddr = "https://<ip of first node>:6443";

  services_k3s_options = { 

    enable = true;
    role = "server"; # Or "agent" for worker only nodes

    # required for multi node cluster
    token = token;

    extraFlags = toString [
      # "--kubelet-arg=v=4" # add args to k3s
      # "--with-node-id nixos-clean-2" # this allows you to change node id 
    ];

  }
  # merge keys, if provided 
  // (if serverAddr != exampleServerAddr then { serverAddr = serverAddr; } else {}) 
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

