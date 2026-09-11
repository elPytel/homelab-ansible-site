# Homelab Ansible Site

## Inicializace pracovního prostředí
Jak inicializovat repo [Ansible Site](./DOC/Ansible_Site.md).

Aktivace virtuálního prostředí:
```bash
source bin/activate
```

> [!note]
> Pro deaktivaci virtuálního prostředí použijte příkaz `deactivate`.

Stažení Galaxy závislostí:
```bash
bin/setup
```

## Testování playbooku
Kontrola dostupnosti hostitele `Zalman`:
```bash
ansible Zalman -m ping
```

Testování playbooku s omezením na hostitele `Zalman` a s kontrolou změn:
```bash
ansible-playbook site.yml --limit Zalman --check --diff
```

## Ostrá konfigurace
Spuštění playbooku s omezením na hostitele `Zalman`:
```bash
ansible-playbook site.yml --limit Zalman
```