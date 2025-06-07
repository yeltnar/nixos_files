new_img=/tmp/gen_image.qcow2

if [ -e ./result ]; then
  rm -rf $new_img
  cp ./result/nixos-image-qcow2* $new_img
  chmod 666 $new_img
fi

qemu-system-x86_64 \
-enable-kvm \
-nographic \
-serial mon:stdio \
-m 2048 \
-nic user,model=virtio,hostfwd=tcp::8022-:22 \
-drive file=$new_img,media=disk,if=virtio

