nixos-rebuild --flake .#build-image build-image --image-variant qemu &&
cp ./result/nixos-image-qcow2-*.qcow2 /tmp/nix.qcow2  &&
chmod 666 /tmp/nix.qcow2 && 
qemu-system-x86_64 -enable-kvm -m 2048 -nic user,model=virtio -drive file=/tmp/nix.qcow2,media=disk,if=virtio
# qemu-system-x86_64 -nographic -enable-kvm -m 2048 -nic user,model=virtio -drive file=/tmp/nix.qcow2,media=disk,if=virtio
