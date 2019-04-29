#!/bin/bash

# there should already be frpc.ini and authorized_keys files here
# usage: bash colab_init.sh <password_of_new_user>

# make new user
echo "### making new user with password $1"
adduser -q colab --gecos "Google Colab" --disabled-password
echo "colab:$1" | chpasswd
usermod -aG sudo colab


# configure ssh
echo "### configuring ssh"
mkdir -p /home/colab/.ssh
mv authorized_keys /home/colab/.ssh/authorized_keys
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "Port 23333" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile %h/.ssh/authorized_keys" >> /etc/ssh/sshd_config
echo "LD_LIBRARY_PATH=/usr/lib64-nvidia" >> /home/colab/.bashrc
echo "export LD_LIBRARY_PATH" >> /home/colab/.bashrc
service ssh restart

# download frp
echo "### downloading frp"
wget -q --show-progress -c https://github.com/fatedier/frp/releases/download/v0.25.2/frp_0.25.2_linux_amd64.tar.gz
tar xzf frp_0.25.2_linux_amd64.tar.gz -C /opt/
mv /opt/frp_0.25.2_linux_amd64 /opt/frp
mv frpc.ini /opt/frp/frpc.ini
chmod -R 755 /opt/frp
echo "### start frp"
nohup /opt/frp/frpc -c /opt/frp/frpc.ini &

# install packages
echo "### installing packages"
apt-get -qq update
# apt install -qq -o=Dpkg::Use-Pty=0 openssh-server pwgen
apt-get -qq install net-tools tmux mosh
# echo y | unminimize

echo "### done"