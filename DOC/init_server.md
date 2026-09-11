# Inicializace serveru pro Ansible

1. Spusť server
2. Vytvoř uživatele *ansible* s administrátorskými právy
3. Přidej veřejný klíč pro uživatele *ansible*
4. Spusť *openssh-server*

## Příklad příkazů pro inicializaci serveru (Debian):

Vytvoření uživatele ansible a přidání do sudoers:
```bash
sudo adduser ansible
sudo usermod -aG sudo ansible
```

Přidání veřejného klíče pro uživatele ansible:
```bash
sudo mkdir /home/ansible/.ssh
sudo vim /home/ansible/.ssh/authorized_keys
sudo chown -R ansible:ansible /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys
```

Instalace a spuštění OpenSSH serveru:
```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

## Spuštění playbooku pro inicializaci serveru

Po dokončení výše uvedených kroků spusť playbook pro inicializaci serveru:
```bash
ansible-playbook -i inventories/hosts.ini servers/init_server.yml
```
