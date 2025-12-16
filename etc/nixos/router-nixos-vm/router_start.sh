cd /root/playin/qemu/                                                                                                            [0/231]
# new_img=/tmp/gen_image.qcow2
new_img=./gen_image.qcow2

# if [ -e ./result ]; then
#   rm -rf $new_img
#   cp ./result/nixos-image-qcow2* $new_img
#   chmod 666 $new_img
# fi

qemu-system-x86_64 \
-enable-kvm \
-m 2048 \
-nographic \
-device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
-netdev bridge,br=br-lan,id=br0 \
-drive file=$new_img,media=disk,if=virtio

# removed this so the init process would work
# -serial mon:stdio \


# -netdev user,id=net0,hostfwd=tcp:192.168.2.1:8022-:22,hostfwd=udp::51820-:51820 \
