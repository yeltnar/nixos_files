{
  config,
  pkgs, 
  ...
}:
let
  token = "";
  serverAddr = ""; # "https://<ip of first node>:6443";
  role = "agent"; # defaults to agent # one of "server" or "agent" for worker only nodes

  services_k3s_options = { 

    enable = true;

    # required for multi node cluster
    token = token;

    extraFlags = toString [
      # "--kubelet-arg=v=4" # add args to k3s
      # "--with-node-id nixos-clean-2" # this allows you to change node id 
    ];

  }
  # merge keys, if provided 
  // (if serverAddr != "" then { serverAddr = serverAddr; } else {}) 
  // (if role != "" then { role = role; } else { role = "agent" }) 
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

