source <(sops -d ./.env.enc)

# tofu import proxmox_virtual_environment_vm.my_vm pve/101

# tofu plan -destroy --out plan.plan

tofu plan --out plan.plan
# && tofu apply plan.plan \ 
# tofu destroy
