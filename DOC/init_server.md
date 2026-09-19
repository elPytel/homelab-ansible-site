# Inicializace serveru pro Ansible

1. Spusťte server
2. Vytvořte uživatele *ansible* s administrátorskými právy
3. Přidejte veřejný klíč pro uživatele *ansible*
4. Spusťte *openssh-server*
5. Změňte heslo pro účet *ansible*
6. Nastavte sudo bez hesla (NOPASSWD)

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

## Změna hesla pro účet ansible**
Zavolejte `passwd` s názvem cílového účtu. Zadávané heslo se na obrazovce klasicky nebude zobrazovat.

```bash
passwd ansible
```

## Nastavení sudo bez hesla (NOPASSWD)
Z hlediska správného návrhu je čistší nevrtat přímo do hlavního `/etc/sudoers`, ale vytvořit pro Ansible dedikovaný soubor ve složce `/etc/sudoers.d/`. K bezpečné úpravě (která rovnou kontroluje syntaxi) slouží `visudo`.


```bash
EDITOR=vim visudo -f /etc/sudoers.d/ansible
```

> [!note]
> Na Proxmoxu budete muset doinstalovat `sudo` balíček, protože je v základní instalaci od Proxmoxu vynechán.

Do otevřeného souboru vlož tento jediný řádek:

```text
ansible ALL=(ALL) NOPASSWD: ALL
```

Můžete si rovnou otestovat, že vše funguje, ještě než se odhlásíte:

```bash
su - ansible
sudo ls /root
```

Pokud systém vypíše obsah rootovské složky a nezeptá se na heslo, je Ansible připraven. 

## Spuštění playbooku pro inicializaci serveru

Po dokončení výše uvedených kroků spusť playbook pro inicializaci serveru:
```bash
ansible-playbook site.yml
```
