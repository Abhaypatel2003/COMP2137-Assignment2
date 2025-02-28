#!/bin/bash

echo "=== Starting Assignment 2 Script ==="

# configure Network (Netplan)
echo "Configuring network settings..."
NETPLAN_FILE="/etc/netplan/50-cloud-init.yaml"

if grep -q "192.168.16.21/24" "$NETPLAN_FILE"; then
    echo "Network already configured."
else
    cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.16.21/24]
      gateway4: 192.168.16.2
EOF
    netplan apply
    echo "Network settings updated."
fi

# Update /etc/hosts
echo "Updating /etc/hosts..."
if grep -q "192.168.16.21 server1" /etc/hosts; then
    echo "Hosts file already updated."
else
    sed -i '/server1/d' /etc/hosts
    sed -i '/server2/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
    echo "192.168.16.22 server2" >> /etc/hosts
    echo "/etc/hosts updated."
fi

# Istall apache2 and squid
echo "Installing required packages..."
apt update -y
apt install -y apache2 squid
systemctl enable --now apache2 squid
echo "apache2 and squid installed and running."

#reate Users & Configure SSH Keys
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${USERS[@]}"; do
    if id "$user" &>/dev/null; then
        echo "User $user already exists."
    else
        useradd -m -s /bin/bash "$user"
        echo "User $user created."
    fi

    mkdir -p /home/$user/.ssh
    ssh-keygen -t rsa -N "" -f /home/$user/.ssh/id_rsa
    ssh-keygen -t ed25519 -N "" -f /home/$user/.ssh/id_ed25519
    cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
    cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
    chown -R $user:$user /home/$user/.ssh
    chmod 700 /home/$user/.ssh
    chmod 600 /home/$user/.ssh/authorized_keys
    echo "SSH keys configured for $user."
done

#dd sudo access for dennis
usermod -aG sudo dennis
echo "Dennis granted sudo access."

echo "=== Assignment 2 Script Completed Successfully ==="
