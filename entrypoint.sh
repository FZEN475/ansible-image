#!/usr/bin/env ash

if [ -n "$ANSIBLE_COLLECTION_PATH" ]; then
    echo "Installing Ansible collection from $ANSIBLE_COLLECTION_PATH"
    ansible-galaxy collection install "$ANSIBLE_COLLECTION_PATH" "${ANSIBLE_COLLECTION_EXTRA_FLAGS:-}"
fi

if [ -n "$ANSIBLE_COLLECTION_URL" ]; then
    echo "Installing Ansible collection from $ANSIBLE_COLLECTION_URL"
    # shellcheck disable=SC2034
    access_token_arg=""
    if [ -n "$ACCESS_TOKEN" ]; then
      # shellcheck disable=SC2034
      access_token_arg="--token $ACCESS_TOKEN"
    fi
    ansible-galaxy collection install "$ANSIBLE_COLLECTION_URL" "$access_token_arg" "${ANSIBLE_COLLECTION_EXTRA_FLAGS:-}"
fi

if [ -n "$ANSIBLE_COLLECTION_REQUIREMENTS_FILE" ]; then
    echo "Installing private Ansible collection from $ANSIBLE_COLLECTION_REQUIREMENTS_FILE"
    ansible-galaxy collection install -r "$ANSIBLE_COLLECTION_REQUIREMENTS_FILE" "${ANSIBLE_COLLECTION_EXTRA_FLAGS:-}"
fi

ansible-galaxy collection list -c

if [ -n "$ANSIBLE_PLAYBOOK_OR_COLLECTION" ]; then

    if [ -f "$ANSIBLE_PLAYBOOK_OR_COLLECTION" ]; then
        # chmod to prevent SSH client from complaining
        echo "Found playbook file: $ANSIBLE_PLAYBOOK_OR_COLLECTION"
        # shellcheck disable=SC2034
        ansible_playbook="${ANSIBLE_PLAYBOOK_OR_COLLECTION}"
    else
        echo "Playbook in collection: $ANSIBLE_PLAYBOOK_OR_COLLECTION"

        cat > /tmp/playbook.yaml <<-EOF
---
- name: Import a playbook
  ansible.builtin.import_playbook: "${ANSIBLE_PLAYBOOK_OR_COLLECTION}"

EOF
        ansible_playbook="/tmp/playbook.yaml"
    fi
else
    echo "Playbook not found!"
    exit 1
fi


if [ -n "$ANSIBLE_INVENTORY_FILES_OR_URLS" ]; then
    IFS=','
    inventory_list=""
    for file_or_url in $ANSIBLE_INVENTORY_FILES_OR_URLS; do
        if [ -f "$file_or_url" ]; then
            inventory_list="$inventory_list -i $file_or_url"
        else
            mkdir -p /tmp/ansible-inventory
            filename=$(basename "$file_or_url")
            curl -sSLk "$file_or_url" -o "/tmp/ansible-inventory/$filename"
            inventory_list="$inventory_list -i /tmp/ansible-inventory/$filename"
        fi
    done
    echo "Inventory: $inventory_list"
else
    echo "Inventory not found!"
    exit 1
fi

if [ -f "$ANSIBLE_PRIVATE_KEY" ]; then
    chmod 0600 "$ANSIBLE_PRIVATE_KEY"
    private_key="--private-key=$ANSIBLE_PRIVATE_KEY -e ssh_private_key_file=$ANSIBLE_PRIVATE_KEY -e ANSIBLE_SSH_PRIVATE_KEY_FILE=$ANSIBLE_PRIVATE_KEY"
else
    echo "Private key not found"
fi

IFS=' '
set -- $inventory_list $private_key ${ANSIBLE_EXTRA_FLAGS:-} "${ansible_playbook}"
ansible-playbook "$@"

## --- Проверка обязательных переменных окружения ---
#required_vars="ANSIBLE_COLLECTION_URL COLLECTION_PLAYBOOK"
#
#for var in $required_vars; do
#    eval value=\$$var
#    if [ -z "$value" ]; then
#        echo "Ошибка: переменная окружения $var не задана!"
#        exit 1
#    fi
#done
#
## --- Установка Ansible-коллекции ---
#echo "Устанавливаем Ansible-коллекцию из $ANSIBLE_COLLECTION_URL"
#ansible-galaxy collection install "$ANSIBLE_COLLECTION_URL"
#
## --- Скачиваем inventory и structure, если URL задан ---
#INVENTORY_PATH=""
#STRUCTURE_PATH=""
#
#[ -n "$INVENTORY_URL" ] && {
#    echo "$INVENTORY_URL"
#    curl -k -o /tmp/inventory.json "$INVENTORY_URL"
#    INVENTORY_PATH="/tmp/inventory.json"
#    cat /tmp/inventory.json
#}
#
#[ -n "$STRUCTURE_URL" ] && {
#    echo "$STRUCTURE_URL"
#    curl -k -o /tmp/structure.yaml "$STRUCTURE_URL"
#    STRUCTURE_PATH="/tmp/structure.yaml"
#    cat /tmp/structure.yaml
#}
#
## --- Формируем параметры -i только для существующих файлов ---
#INVENTORY_PARAMS=""
#[ -n "$INVENTORY_PATH" ] && INVENTORY_PARAMS="$INVENTORY_PARAMS -i $INVENTORY_PATH"
#[ -n "$STRUCTURE_PATH" ] && INVENTORY_PARAMS="$INVENTORY_PARAMS -i $STRUCTURE_PATH"
#
## --- Генерируем локальный playbook с динамическим импортом ---
#cat > ./playbook.yaml <<EOF
#---
#- name: Import a playbook
#  ansible.builtin.import_playbook: ${COLLECTION_PLAYBOOK}
#EOF
#
#
#cat ./playbook.yaml
#
## --- Запуск плейбука ---
#ansible-playbook ./playbook.yaml $INVENTORY_PARAMS ${ANSIBLE_EXTRA_FLAGS:-}

