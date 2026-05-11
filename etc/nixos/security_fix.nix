{ ... }: {

    boot.blacklistedKernelModules = [ "algif_aead" ];
    boot.extraModprobeConfig = "install algif_aead /bin/false";

  imports = [
    
    # for copy fail
    ({ ... }:{
      boot.blacklistedKernelModules = [ "algif_aead" ];
      boot.extraModprobeConfig = "install algif_aead /bin/false";
    })

    # for dirty frag
   ({ ... }:{
     # 1. Prevent the vulnerable modules from loading
     boot.blacklistedKernelModules = [ "esp4" "esp6" "rxrpc" ];
     # 2. Hard-disable the modules (prevents manual loading)
     boot.extraModprobeConfig = ''
       install esp4 /bin/false
       install esp6 /bin/false
       install rxrpc /bin/false
     '';
   })

  ];

}
