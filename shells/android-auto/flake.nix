{
  description = "A flake for an FHS development environment without flake-utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Change this to "aarch64-linux" if you are on an ARM machine
      system = "x86_64-linux"; 
      pkgs = import nixpkgs { inherit system; };

      android_derivation = pkgs.stdenv.mkDerivation {
        name="android_derivation";
        src = pkgs.fetchzip {
          # TODO need this to be smarter 
          url= "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip";
          sha256 = "sha256-dt8nwjL8wyRfBZOedCPYXh7zyeMUeH0gOPpTcpxCegU=";
        };

        installPhase = ''

          mkdir -p "$out/src/cmdline-tools/latest"
          cp -ar * "$out/src/cmdline-tools/latest/"

        '';
      };

      # Define the FHS environment
      fhs = pkgs.buildFHSEnv {
        name = "my-fhs-env";

        # System-level binaries (placed in /bin, /usr/bin)
        targetPkgs = pkgs: with pkgs; [
          # Java Environment
          jdk_headless

          # The main requirement
          llvmPackages.libcxx
          
          # Graphics / UI
          libGL
          libGLU
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXrandr
          xorg.libXi
          SDL2
          SDL2_ttf
          libpng
          
          # System / Audio
          alsa-lib
          portaudio
          pulseaudio
          udev
          libusb1
          zlib
          glib
          dbus
        ];

        # Library-level dependencies (placed in /lib, /usr/lib)
        multiPkgs = pkgs: with pkgs; [
          # libgcc
          libGL
        ];

        __noChroot = true;
        runScript = ''

        export PATH="$PATH:${pkgs.jdk_headless}/bin"

        out="$HOME/android-sdk"

        mkdir -p "$out/cmdline-tools/latest"
        cp -ar * "$out/cmdline-tools/latest/"

        cp -ar ${android_derivation}/src/cmdline-tools/latest/ "$out/cmdline-tools"

        export ANDROID_HOME="$out"
        
        # 2. Add the different tool directories to your PATH
        export PATH="$PATH:$ANDROID_HOME/platform-tools"    # For adb, fastboot
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin" # For sdkmanager, avdmanager
        export PATH="$PATH:$ANDROID_HOME/emulator"          # For the emulator binary
        export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0" # For aapt, apksigner (version varies)

        echo $PATH | tr ':' '\n' | grep cmdline

        echo "$ANDROID_HOME/cmdline-tools/latest/bin"
        ls "$ANDROID_HOME/cmdline-tools/latest/bin"

        ls ${pkgs.jdk_headless}/bin
        export JAVA_HOME="${pkgs.jdk_headless}"

        # shellHook = 

        printexit(){
          echo exiting
        }
        trap printexit EXIT

        cd ~/
        echo hidrew

        # TODO: 
        # download pacakge https://developer.android.com/studio#command-line-tools-only
        # extract. this should be in DIR/cmdline-tools/latest
        # mkdir ~/android-sdk/
        # extract /tmp/commandlinetools-linux-13114758_latest.zip ~/android-sdk

        export PATH=$PATH:"$ANDROID_HOME/extras/google/auto"

        yes | sdkmanager --install "extras;google;auto"

        # this assumes you have adb set up... maybe it shouldn't
        adb forward tcp:5277 tcp:5277 && desktop-head-unit && exit

        export alias runme="sdkmanager --list"

        # call bash so we get shell with this setup
        ${pkgs.bash}/bin/bash

        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "fhs-shell";
        
        nativeBuildInputs = [ fhs ];

        # This automatically launches the FHS environment
        shellHook = ''
          echo "🚀 Entering FHS environment for ${system}..."
          exec ${fhs}/bin/my-fhs-env
        '';
      };
    };
}
