# ansible-image
## Описание
* Образ основан на alpine
* Образ содержит ansible и утилиты.
* Для загрузки playbook.yaml требуется указать Переменные среды.

## Variables
| Дополнительно                      | Значение                         | Comment                               |
|:-----------------------------------|:---------------------------------|:--------------------------------------|
| secrets.id_ed25519                 | /root/.ssh/id_ed25519            | Ключ для подключения к серверам.      |
| environment.ANSIBLE_COLLECTION_URL | git URL                          | Ссылка на ansible-galaxy collection   |
| environment.INVENTORY_URL          | URL (опционально)                | Ссылка на инвентарь                   |
| environment.STRUCTURE_URL          | URL (опционально)                | Ссылка на структуру                   |
| environment.COLLECTION_PLAYBOOK    | [ns].[name].playbooks.[filename] | Путь к файлу playbook.yml в коллекции |
| environment.ANSIBLE_EXTRA_FLAGS    | -vvv                             | Дополнительные флаги для отладки      |

## Troubleshoots

<!DOCTYPE html>
<table>
  <thead>
    <tr>
      <th>Проблема</th>
      <th>Решение</th>
    </tr>
  </thead>
  <tr>
      <td>Из контейнера не определяется DNS имя без домена.</td>
      <td>
На хосте докера:  
/etc/docker/daemon.json

```json
{
  "dns": ["192.168.2.1","8.8.8.8"]
}
```
</td>
  </tr>
  <tr>
  </tr>
</table>
