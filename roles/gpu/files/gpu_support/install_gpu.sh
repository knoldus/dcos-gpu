#!/bin/bash

PRIVATE_DEPLOYMENT=" pass your value ( true or false) "
S3_ENDPOINT= " pass the s3 enpoint value"
VULKAN_FILE_PATH= " pass the path where the vulkan file is stored"


# blacklist nvidia conflicting kernel modules
cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF

GRUB_CMDLINE_LINUX="modprobe.blacklist=nouveau"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# install cuda driver

if [[ $PRIVATE_DEPLOYMENT == "true" ]];then
  sudo yum-config-manager --disable rhui-REGION-client-config-server-7 || true
  sudo yum-config-manager --disable rhui-REGION-rhel-server-releases || true
  sudo yum-config-manager --disable rhui-REGION-rhel-server-rh-common || true
  sudo yum-config-manager --disable nodesource || true
else
  curl -O https://${S3_ENDPOINT}/${VULKAN_FILE_PATH}
  sudo rpm -i vulkan-filesystem-1.1.73.0-1.el7.noarch.rpm
  curl -O https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
  sudo rpm -i cuda-repo-rhel7-8.0.61-1.x86_64.rpm
  sudo yum clean all
fi

sudo yum -y install cuda-8-0.x86_64


sudo bash -c "cat > /etc/ld.so.conf.d/cuda-lib64.conf << EOF
/usr/local/cuda/lib64
EOF"

export PATH=$PATH:/usr/local/cuda/bin
