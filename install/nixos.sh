#!/bin/sh
# set -x
set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

device=$(lsblk -o NAME,MOUNTPOINT | awk '$2==""{print $1}')
num_devices=$(echo "$device" | wc -l)

if [ "$num_devices" -gt 1 ]; then
    echo "More than one unused device found."
    echo $device

    read -p "Please enter the destination storage device: " device < /dev/tty
fi

while true; do
    read -p "NixOS will be installed to /dev/$device. Proceed (y/n)? " yn < /dev/tty
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Exiting."; exit;;
        * ) echo "Please answer y or n.";;
    esac
done

parted "/dev/${device}" --script -- 'print' | awk '/^ [0-9]+/{print $1}' | while read part; do
    parted "/dev/${device}" --script -- rm "$part"
done

echo "Creating partitions" 
parted "/dev/${device}" --script -- mklabel gpt
parted "/dev/${device}" --script -- mkpart primary 512MB -8GB 
parted "/dev/${device}" --script -- mkpart primary linux-swap -8GB 100%
parted "/dev/${device}" --script -- mkpart ESP fat32 1MB 512MB
parted "/dev/${device}" --script -- set 3 esp on

echo "Formatting partitions"
mkfs.ext4 -L nixos "/dev/${device}1"
mkswap -L swap "/dev/${device}2"
mkfs.fat -F 32 -n boot "/dev/${device}3"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon "/dev/${device}2"

#echo "Generating config."
#nixos-generate-config --root /mnt

nix-env -iA nixos.nixVersions.git
nix-env -iA nixos.nixVersions.stable

git clone -b dev --single-branch https://github.com/mattsmirnov97/nix-config
cd nix-config
echo "Please enter login (eg.: aragao): "
read userName < /dev/tty
echo "Please enter full name (eg.: Andre Aragao): "
read fullName < /dev/tty

while true; do
    read -p "You selected: login: $userName/full name: $fullName. Proceed (y/n)? " yn < /dev/tty
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Exiting."; exit;;
        * ) echo "Please answer y or n.";;
    esac
done
oldUserName="aragao"
oldFullName="Andre Aragao"
sed -i "s/$oldUserName/$userName/g" flake.nix
sed -i "s/$oldFullName/$fullName/g" flake.nix

while true; do
    read -p "Enter utm for UTM or prl for Parallels (utm/prl): " virtSystem < /dev/tty
    case $virtSystem in
        [prl]* ) break;;
        [utm]* ) break;;
        * ) echo "Invalid option $virtSystem. Try again or Ctrl+C to exit.";;
    esac
done
nixos-install --flake .#$virtSystem-dev < /dev/tty

