{
  description = "A basic Nix flake to run a container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      image_name = "pi_agent_img";
      container_name = "pi_agent";

      npm_prefix_dir = "/npm";

      container_script = pkgs.writeScriptBin "container_script" ''
        #!/bin/bash
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        export NODE_EXTRA_CA_CERTS="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        export PATH="/npm/bin:$PATH"
        export EDITOR=nvim
        export VISUAL=nvim

        mkdir -p /usr
        ln -s /bin /usr/bin

        npm config set cafile "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        npm config set prefix ${npm_prefix_dir}; 

        if [ -z $(command -v pi) ]; then
          npm install -g @mariozechner/pi-coding-agent
        fi

        if [ "$1" == "pi" ]; then
          exec pi
        else
          exec bash
        fi

      '';

      # Create a combined environment for all runtime packages
      containerEnvironment = pkgs.buildEnv {
        name = "container-environment";
        paths = with pkgs; [
          bash
          coreutils
          cacert
          gnugrep
          gawk
          gnused
          # curl
          fd
          ripgrep
          git
          nix
          nodejs_24
          container_script
          pandoc
          findutils
          neovim
          iputils
          jq
          yq-go
          less
          lazygit
        ];
        pathsToLink = [ "/bin" ];
      };

      # Define a simple container image
      myContainerImage = pkgs.dockerTools.buildImage {
        name = image_name;
        tag = "latest";
        # Configuration for the container
        config = {
          # Entrypoint = [ "/bin/echo" "Hello from container! (Nix-built)" ];
          # Entrypoint = [ "/bin/bash" "-c" "${container_script}" ];
          Entrypoint = [ "/bin/bash" ];
          Command = [ "-c" "/bin/container_script" ];
          # ExposedPorts = { "80/tcp" = {}; };
        };
        # Files to include in the container, copied to the root of the image
        copyToRoot = [
          containerEnvironment
        ];
      };

      piApp = {
          type = "app";
          program = "${pkgs.writeScript "run-container" ''
            #!${pkgs.bash}/bin/bash
            # Define a unique identifier for the built image based on its Nix store path hash
            # This hash will be stable for the same image content
            imageHash="$(nix-store -q --hash '${myContainerImage}' | sed 's/^sha256://')";

            echo "Building and running the container with tag: $imageHash"
            
            # Check if the image with the hash as its repository name already exists locally
            # We check for the repository name being exactly the hash, and any tag.
            if ! podman images --format "{{.Repository}}" | grep -q "$imageHash$"; then
              podman rmi -f "${image_name}:latest"
              echo "Image with repository '$imageHash' not found, loading and retagging..."
              # Load the image; it will be named "${image_name}:latest" as per buildImage config
              podman load < "${myContainerImage}" || exit 1
              # Tag the newly loaded image with just the hash as its repository name
              # We explicitly tag it with ':latest' to ensure it's runnable without explicit tag
              podman tag "${image_name}:latest" "$imageHash:latest" || exit 1
              # Remove the original "${image_name}:latest" tag
              podman rmi "${image_name}:latest"
            else
              echo "Image '$imageHash:latest' already loaded."
            fi

            command="pi"
            if [ "$1" == "bash" ]; then
              command="bash"
            fi

            pi_dir="$HOME/playin/pi_agent/pi"
            pi_npm="$HOME/playin/pi_agent/npm"
            pi_host="$HOME/playin/pi_agent/host"

            mkdir -p "$pi_dir"
            mkdir -p "$pi_npm"
            mkdir -p "$pi_host"

            inspect_exit_code=$(podman inspect ${container_name} >/dev/null 2>&1 ; echo $?)

            # if it is running, attach to it, if not, create it
            if [ "$inspect_exit_code" -eq 0 ]; then

              echo exec
              podman exec \
                -it \
                ${container_name} \
                /bin/container_script "$command"

            else

              echo run
              podman run \
                --rm \
                --name ${container_name}\
                -it \
                -v "$pi_dir":/.pi \
                -v "$pi_npm":/npm \
                -v "$pi_host":/host \
                -v "/mnt/rustfs/pi-agent/":/rustfs/ \
                "$imageHash:latest" \
                /bin/container_script "$command"

            fi

          ''}";
        };

    in
    {
      # devShells.${system}.default = pkgs.mkShell {
      #   packages = with pkgs; [
      #     podman
      #   ];
      #   shellHook = ''
      #     echo "Welcome to the container flake devShell!"
      #     echo "You can run the container with 'nix run .'"
      #   '';
      #
      # };

      apps.${system} = {
        default = piApp;
        piApp = piApp;
        # bash = bash;
      };
    };
}
