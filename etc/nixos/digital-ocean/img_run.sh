new_img=/tmp/gen_image.qcow2
rm -rf $new_img
cp ./result/nixos-image-qcow2* $new_img
chmod 666 $new_img
qemu-system-x86_64 -enable-kvm -m 2048 -nic user,model=virtio -drive file=$new_img,media=disk,if=virtio
