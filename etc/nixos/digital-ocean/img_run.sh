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
-netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=udp::51820-:51820 \
-device virtio-net,netdev=net0 \
-drive file=$new_img,media=disk,if=virtio

