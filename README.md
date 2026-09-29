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

## Vizualizace 

```bash
ansible-inventory --graph
```

## Práce s `make`

`make help`

```bash
Usage: make [target]

Targets:
  all:                   Run all linting checks (yamllint, ansible-lint, and ansible-playbook syntax check)
  yaml-lint:             Run yamllint on all YAML files in the repository
  ansible-lint:          Run ansible-lint on all Ansible playbooks in the repository
  ansible-playbook-syntax-check: Check the syntax of all Ansible playbooks in the repository
  lint:                  Run all linting checks (yaml-lint, ansible-lint, and ansible-playbook syntax check)
  setup:                 Download and install dependencies, set up virtual environment, and prepare the developmentenvironment.
  clean:                 Clean build artifacts.
  clean-all:             Clean all build artifacts and dependencies.
```

> [!tip]
> Pokud přidáte další závislosti do `requirements.yml`, `make setup` je doporučený příkaz pro inicializaci a aktualizaci prostředí.

> [!warning]
> Pokud se změní obsah repo závislotí je potřeba spustit `bin/setup` ručně!

> [!note]
> Při tvorbě vlastních rolí je doporučeno spustit `make lint` pro kontrolu kódu.