source <(sops -d ./.env.enc)

tofu plan -destroy --out plan.plan

# tofu plan --out plan.plan
# && tofu apply plan.plan \ 
# tofu destroy
