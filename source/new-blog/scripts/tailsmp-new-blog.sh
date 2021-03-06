#!/bin/bash
read -p "Enter your desired username: " username
read -p "Enter your desired key password: " -s password
echo ""
read -p "Enter your server IP: " serverip
read -p "Enter your desired server name: " servername
read -p "Enter the path to your website directory: " webdir
echo "Generating an ssh keypair..."
ssh-keygen -q -t ed25519 -o -a 100 -C $username -N $password -f ~/.ssh/id_$username
printf '%s\n%s' '[defaults]' 'inventory = ~/.ansible/hosts' >> ~/.ansible.cfg
printf '%s\n%s\n' '[new-tailsmp]' "$serverip" >> ~/.ansible/hosts
echo "Setting up the server..."
ansible-playbook ../main.yml -vvvv --extra-vars "admin_user=$username admin_sshkey=~/.ssh/id_$username.pub user_html=$webdir" -k
echo "Adding $servername to the your .ssh/config"
printf '\n%s\n\t%s\n\t%s\n\t%s' "Host $servername" "HostName $serverip" "User $username" "IdentityFile ~/.ssh/id_$username" >> ~/.ssh/config
echo "Cleaning up Ansible hosts"
cat ~/.ansible/hosts | head -n -2 > ~/.ansible/hosts
cat ~/.ansible.cfg | head -n -2 > ~/.ansible.cfg
echo "Adding $servername to your .ansible/hosts"
printf '%s\n%s\n' "[$servername]" "$servername" >> ~/.ansible/hosts
echo "Log into your server with ssh $servername"
