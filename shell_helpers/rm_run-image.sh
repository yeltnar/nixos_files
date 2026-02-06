new_img=/tmp/gen_image.qcow2
new_img=./gen_image.qcow2

# if [ -e ./result ]; then
#   rm -rf $new_img
#   cp ./result/nixos-image-qcow2* $new_img
#   chmod 666 $new_img
# fi

# new_img="./nixos-image-qcow2-25.11.20251206.d9bc5c7-x86_64-linux.qcow2"
chmod 666 $new_img

qemu-system-x86_64 \
-enable-kvm \
-serial mon:stdio \
-m 2048 \
-nic none \
-drive file=$new_img,media=disk,if=virtio
# -nographic \

