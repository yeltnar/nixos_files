new_img=./gen_image.qcow2

if [ -e ./result ]; then
  rm -rf $new_img
  cp ./result/nixos-image-qcow2* $new_img
  chmod 666 $new_img
fi

mnt_dir="/tmp/gen_image_mnt"

cleanup(){
  sudo umount "$mnt_dir"
  sudo qemu-nbd --disconnect /dev/nbd0
  rmdir "$mnt_dir"
}

cleanup
echo after clean
echo

trap cleanup EXIT

# cp ./date.txt "$mnt_dir/home/drew/"

mountit(){
  sudo modprobe nbd max_part=8
  echo sleep 1 for modprobe
  sleep 1

  sudo qemu-nbd --connect=/dev/nbd0 ./gen_image.qcow2

  echo sleep 1 for qemu-nbd
  sleep 1

  mkdir -p "$mnt_dir"

  sudo mount /dev/nbd0p1 "$mnt_dir/"
}

copy_keys(){
  # create sops files, copy secret to image, delete local key
  sops_mnt_path="$mnt_dir/etc/sops/age"
  sops_file="keys.txt"
  # age-keygen 2>/dev/null | awk '!/#/' > "$sops_file" ;
  sudo mkdir -p "$sops_mnt_path"
  ls -alt "$sops_mnt_path"
  sops -d ./secrets/secrets.yaml | yq .sops_key | sudo tee "$sops_mnt_path/$sops_file" > /dev/null
  age-keygen -y "$sops_mnt_path/$sops_file" > pub."$sops_file" ;

  # sudo cp "$sops_file" "$mnt_dir/etc/sops/age/"
  mkdir -p "${mnt_dir}/home/drew/.config/sops/age"
  ln -s /etc/sops/age/keys.txt "${mnt_dir}/home/drew/.config/sops/age/keys.txt"

  # rm "$sops_file"
  ls "$sops_mnt_path"
}

resize(){
  qemu-img resize "$new_img" 20G
}

resize
mountit
copy_keys


