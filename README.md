# ansible-image
## Description
* Образ содержит ansible и утилиты.
* Для загрузки playbook.yaml требуется указать environment.ANSIBLE_REPO.
* Образ зависим от файлов structure.yaml и inventory.json, которые копируются из "безопасного" расположения.
  * Файлы создаются при выполнении [terraform](https://github.com/FZEN475/terraform).
  * Путь для скачивания указывается через environment.SECURE_SERVER и environment.SECURE_PATH. 
* Общие [библиотеки](https://github.com/FZEN475/ansible-library.git) 
  * Загружаются в /source/library при каждом создании контейнера.
  * Репозиторий библиотек environment.LIBRARY.

## Variables
| Дополнительно               | Значение   | Comment                                                            |
|:----------------------------|:-----------|:-------------------------------------------------------------------|
| secrets.id_ed25519          | id_ed25519 | Закрытый ключ "безопасного" сервера                                |
| environment.ANSIBLE_REPO    | git url    | Репозиторий с playbook.yaml                                        |
| environment.SECURE_SERVER   | IP/DNS     | IP или DNS "безопасного" сервера с inventory.json и structure.yaml |
| environment.SECURE_PATH     | path       | Расположение на "безопасном" сервере                               |
| environment.LIBRARY         | git url    | Репозиторий с библиотеками ansible                                 |
| environment.GIT_EXTRA_PARAM | -bdev      | Дополнительные параметры git clone                                 |
