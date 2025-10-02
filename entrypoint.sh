#!/usr/bin/env ash

# --- Проверка обязательных переменных окружения ---
required_vars="ANSIBLE_COLLECTION_URL COLLECTION_PLAYBOOK"

for var in $required_vars; do
    eval value=\$$var
    if [ -z "$value" ]; then
        echo "Ошибка: переменная окружения $var не задана!"
        exit 1
    fi
done

# --- Установка Ansible-коллекции ---
echo "Устанавливаем Ansible-коллекцию из $ANSIBLE_COLLECTION_URL"
ansible-galaxy collection install "$ANSIBLE_COLLECTION_URL"

# --- Скачиваем inventory и structure, если URL задан ---
INVENTORY_PATH=""
STRUCTURE_PATH=""

[ -n "$INVENTORY_URL" ] && {
    echo "$INVENTORY_URL"
    curl -k -o /tmp/inventory.json "$INVENTORY_URL"
    INVENTORY_PATH="/tmp/inventory.json"
    cat /tmp/inventory.json
}

[ -n "$STRUCTURE_URL" ] && {
    echo "$STRUCTURE_URL"
    curl -k -o /tmp/structure.yaml "$STRUCTURE_URL"
    STRUCTURE_PATH="/tmp/structure.yaml"
    cat /tmp/structure.yaml
}

# --- Формируем параметры -i только для существующих файлов ---
INVENTORY_PARAMS=""
[ -n "$INVENTORY_PATH" ] && INVENTORY_PARAMS="$INVENTORY_PARAMS -i $INVENTORY_PATH"
[ -n "$STRUCTURE_PATH" ] && INVENTORY_PARAMS="$INVENTORY_PARAMS -i $STRUCTURE_PATH"

# --- Генерируем локальный playbook с динамическим импортом ---
cat > ./playbook.yaml <<EOF
---
- name: Import a playbook
  ansible.builtin.import_playbook: ${COLLECTION_PLAYBOOK}
EOF


cat ./playbook.yaml

# --- Запуск плейбука ---
ansible-playbook ./playbook.yaml $INVENTORY_PARAMS

