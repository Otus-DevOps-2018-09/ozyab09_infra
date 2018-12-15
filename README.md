ozyab09_infra
```
ozyab09 Infra repository
```

### Homework 11 (Ansible-4)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=ansible-4)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)
* `Vagranfile` в директории `ansible` описывает конфигурацию виртуальных машин 
* Добавлен провижининг в определение хоста `dbserver`
* `vagrant provision dbserver` запускает провижинера для `dbserver`
* Добавлен `base.yml` для установки `python` используя модуль `raw`. После этого `vagrant provision dbserver` работает корректно
* Переустановка `MongoDB` завершилась неудачно
* В роль `db` добавлен файл тасков `db/tasks/install_mongo.yml` для установки `MongoDB`
* Задачи управления конфигом `MongoDB` вынесены в отдельный файл `config_mongo.yml`
*  `vagrant provision dbserver` отработал корректно
*  Подключившись к `appserver` командой `vagrant ssh appserver` можем проверить доступность порта монги для хоста `appserver` командой `telnet 10.10.10.10 27017`:
```
telnet 10.10.10.10 27017
Trying 10.10.10.10...
Connected to 10.10.10.10.
Escape character is '^]'.
```
* В роль `app` включена конфигурация из `packer_app.yml` для настройки хоста приложения
* Настройки `puma` сервера помещены в отдельный файл `app/tasks/puma.yml` с содержимым из файла `app/tasks/main.yml`, относящимся к настройке `Puma` сервера и запуску приложения
* В файле `app/tasks/main.yml` добавлен вызов `ruba.yml` и `puma.yml`
* В файл `ansible/Vagrantfile` добавлен `Ansible` провижинер для хоста `appserver`
* В `.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory` содержится временный файл `inventory`
* Выполнен провижинг `appserver`'a командой `vagrant provision appserver`. Запуск завершился ошибкой:
```
TASK [app : Add config for DB connection] *********************
fatal: [appserver]: FAILED! => {"changed": false, "checksum": "a7807c1ccef582e9822f48f9542ea234d77fb131", "msg": "Destination directory /home/appuser does not exist"}
```
* Произведена параметризация имени пользователя, чтобы дать возможность использовать роль для иного пользователя: 
```
roles/app/defaults/main.yml
---
...
deploy_user: appuser
```
* Заменен модуль для копирования `unit` файла с `copy` на `template` в файле `puma.yml`, чтобы иметь возможность параметризировать `unit` файл. Соответственно файл puma.service переехал из app/files в app/templates
* В шаблоне `puma.service.j2` все упоминания `appuser` заменены на переменную `deploy_user`. Аналогичные действия произведены с файлами `app/tasks/puma.yml` и `playbooks/deploy.yml`
* В `Vagrantfile` добавлены `extra_vars` переменные в блок определения провижинера
```
app.vm.provision "ansible" do |ansible|
...
 ansible.extra_vars = {
 "deploy_user" => "ubuntu"
 }
end
```
* Применение провижининга для `appserver`: `vagrant provision appserver` завершилось с ошибкой из-за недостатка прав:
```
TASK [Fetch the latest version of application code] ****************************
fatal: [appserver]: FAILED! => {"changed": false, "cmd": "/usr/bin/git clone --origin origin https://github.com/express42/reddit.git /home/ubuntu/reddit", "msg": "fatal: could not create work tree dir '/home/ubuntu/reddit': Permission denied", "rc": 128, "stderr": "fatal: could not create work tree dir '/home/ubuntu/reddit': Permission denied\n", "stderr_lines": ["fatal: could not create work tree dir '/home/ubuntu/reddit': Permission denied"], "stdout": "", "stdout_lines": []}
```
В связи с чем в `Vagrantfile` заменен `extra_vars`:  `"deploy_user" => "vagrant"`

* Пересоздадим окружение:
```
vagrant destroy -f 
vagrant up 
```
Приложение запускается по адресу `http://10.10.10.20:9292/`
Для запуска приложения по адресу `http://10.10.10.20` необходимо добавить в Vagrantfile:
```
"nginx_sites" => { "default" => [
"listen 80",
"server_name 'reddit'",
"location / { proxy_pass http://127.0.0.1:9292;}"]}
}
```
* Создадим вирутальное окружение:
```
pip install virtualenv virtualenvwrapper
virtualenv pyenv
source pyenv/bin/activate
```
* `ansible/requirements.txt` дополнен зависимостями:
```
...
molecule>=2.6
testinfra>=1.10
python-vagrant>=0.5.15 
```
* molecule init scenario --scenario-name default -r db -d vagrant для создания заготовки тестов для роли db из ansible/roles/db 
* Несколько тестов для проверки конфигурации, настраиваемой ролью db, используя модули Testinfra, помещены в файл `db/molecule/default/tests/test_default.py`:
```
import os
import testinfra.utils.ansible_runner
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')
# check if MongoDB is enabled and running
def test_mongo_running_and_enabled(host):
    mongo = host.service("mongod")
    assert mongo.is_running
    assert mongo.is_enabled
# check if configuration file contains the required line
def test_config_file(host):
    config_file = host.file('/etc/mongod.conf')
    assert config_file.contains('bindIp: 0.0.0.0')
    assert config_file.is_file
```
* Тестовая машина в файле `db/molecule/default/molecule.yml` создается автоматически при выполнении `molecule init` выше 
* Создание VM для проверки роли выполняется из директории `ansible/roles/db` командой `molecule create`
* Список созданных инстансов, которыми управляем `molecule`: `molecule list`
```
Instance Name    Driver Name    Provisioner Name    Scenario Name    Created    Converged
---------------  -------------  ------------------  ---------------  ---------  -----------
instance         vagrant        ansible             default          true       false
```
* В случае необходимости по `ssh` можно подключиться к инстансу: `molecule login -h instance`
* Плэйбук для применения роли находится по адресу `ansible/roles/db/molecule/default/playbook.yml`. Для его применения необходимо воспользоваться командой `molecule converge`
* Прогон тестов: `molecule verify`
* Для проверки доступности порта MongoDB в `ansible/roles/db/tests/test_default.yml` добавлены строки:
```
def test_mongo_port(host):
    port = host.socket("tcp://80")
    assert port.is_listening
```
* Использованы роли `db` и `app` в плейбуках `packer_db.yml` и `packer_app.yml`


### Homework 10 (Ansible-3)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=ansible-3)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)
* Созданы роли `app` и `db`
* Файлы `app.yml` и `db.yml` переписаны под использование ролей
* Создана директория `environments` для определения настроек окружения
* Копия файла `ansible/inventory` перенесена в `ansible/environments/prod` и `ansible/environments/stage`. Исходный файл при этом удален
* Файлом `inventory` по умолчанию задан файл `./environments/stage/inventory`
* Созданы директории `group_vars` в директориях окружений
* Созданы групповые переменные для групп хостов `app`, `db` и `all` в окружениях `stage` и `prod`
* Добавлен вывод информации о том, в каком окружении находится конфигурируемый хост
* Playbook'и организованы согласно best practice
* Исправлены файлы `packer/app.json` и `packer/db.json` согласно расположению файлов `packer_app.yml` и `packer_db.yml` соответственно
* Установлена роль `jdauphant.nginx`. Теперь сервис `puma` доступен по порту 80
* Создан файл с паролем `~/.ansible/vault.key` (вне репозитория)
* Паролем зашифрованы файлы `environments/prod/credentials.yml` и `environments/stage/credentials.yml`

### Homework 9 (Ansible-2)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=ansible-2)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

* Созданы playbook reddit_app.yml и шаблон конфига MongoDB mongod.conf.j2
* Добавлен handler для перезапуска mongod
* Добавлен файл puma.service
* В reddit_app добавлен task компирования puma.service на хост db
* Добавлена команда автозапуска сервиса puma
* Добавлен шаблон файла db_config.j2
* Добавлена задача копирования шаблона конфига db_config.j2 на хост db
* Добавлена переменная db_host в файл reddt_app.yml
* Добавлен output переменной db_internal_ip
* Добавлены модулт git и bundle для клонирования последней версии кода приложения и установки зависимых гемов через bundle
* В файле reddit_app2.yml сценарий разделен на отдельные блоки для app, db и для деплоя приложения
* Созданы файлы app.yml, db.yml и deploy.yml
* Сценарий site.yml включает в себя include из сценариев app.yml, db.yml и deploy.yml
* Созданы файлы packer_app.yml и packer_db.yml
* Заменена секция Provision в образах packer/app.json и packer/db.json на Ansible 

### Homework #8 (Ansible-1)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=ansible-1)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

* Установлен Ansible на локальное окружение вместе с зависимостями
* Создан invenfory file в ini-формате, и в формате yaml
* Создан ansible.cfg
* Опробованы ad-hoc команды
* Создан простой playbook для клонирования репозитория
* Удалив склонированный репозиторий на удаленном сервере с помощью ad-hoc команд, и повторно выполнив playbook, результат будет таким:
```
PLAY RECAP *
appserver : ok=2 changed=1 unreachable=0 failed=0
```
то есть произошло одно изменение, что означает, что действие `было выполнено`
* Добавлен `inventory.json`. Для теста необходимо выполнить `ansible all -i inventory.json -m ping`



### Homework #7 (Terraform-2)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=terraform-2)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

## Продолжаем работать с Terraform:
* Создано правило фаерволла `default-allow-ssh`. Применить его не удалось, тк правило с таким именем уже существует
* Команда `terraform import google_compute_firewall.firewall_ssh FIREWALL_NAME` позволяет импортировать существующее правило
* Добавлен description в правило
* Определен ресурс google_compute_address
* Создана ссылка в ресурсе VM на созданный аттрибут ресурса google_compute_address
* Созданы образы reddit-db-base	и reddit-app-base в GCP
* Конфигурация VM с приложением перенесена в отдельный файл app.tf, база данных - в файл db.tf
* В файле vpc.tf вынесены правила фаервола для ssh доступа
* В фале main.tf только описание провайдера
* Создана папка modules, которую будем наполнять модулями: db, app
* В main.tf добавленв информация о модулях
* Команда `terraform get` загружает модули. Если посмотреть в описание файла `.terraform/modules/modules.json`, то увидим список загруженных модулей
* Добавлен модуль vpc
* Произведена параметризация модуля vpc
* Проверена работа параметров vpc
* Добавлены окружения stage и prod
* Удалены ненужные файлы в директории `terraform/`
* Создание бакета в сервисе Storage
* Добавлены файлы backend.tf для хранения стэйта в gcs
* При одновременном запуске двух окружений, которые обращаются к gsp, получаем ошибку `Error locking state`
* Не удалось настроить provisioner приложения :(

### Homework #6 (Terraform-1)
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=terraform-1)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

## Работа с Terraform:
* Создана виртуальная машина reddit-terraform 
* Добавлен ключ для пользователя appuser
* Выведен output с внешним IP созданной виртуальной машины используя outputs.tf
* Создано правило фаерволла
* Инстансу добавлен тэг
* Разворачивание приложения используя provisioner
* Добавлены input переменные, включая project, public_key_path, disk_image, private_key_path и zone
* Отформатированы конфигурационные файлы (terraform init)
* Добавлен файл terraform.tfvars.example

## Задачи со *
* Добавлены пользователи appuser1-3 используя google_compute_project_metadata
* Добавлен пользователь appuser_web через web-консоль. При следующем выполнении **terraform apply** пользователь быль удален
* Добавлен loadbalancer. Изменен outputs.tf на вывод внешнего ip loadbalancer'a, и на вывод всех ip-адресов инстансов
* Проблемой такой реализиации является то, что база данных находится на каждом инстансе. При создании поста в вэб-интерфейсе он будет размещен на одном из инстансов. Необходимо наличие единой базы данных


### Homework #5 (Packer)

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=packer-base)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

* Создан файл ubuntu.json с простой конфигурацией образа Ubuntu, в которую включены установка mongodb и ruby. Параметры вынесены в отдельный файл variables.json (в репозитории отсутствует)
* В файле variables.json.example расположен образец файла variables.json
* В образе, создаваемом файлом immutable.json также добавлен файл deploy.sh, который устанавливает web-севрис Puma
* В файл deploy.sh добавлен systemd unit puma.servie
(происходит скачивание файла packer/files/puma.service из репозитория в /etc/systemd/system/ ) 
* Для проверки корректности файлов необходимо использовать: 
```
packer validate  -var-file=variables.json.example ubuntu16.json
packer validate  -var-file=variables.json.example immutable.json
```
* В файле packer/config-scripts/create-reddit-vm.sh расположен скрипт создания виртуальной машины из созданного ранее образа


### Homework #4 (GKE)

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=cloud-testapp)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

* Создание инстанса **Compute Engine**

```
gcloud compute instances create reddit-app \
   --boot-disk-size=10GB \
   --image-family ubuntu-1604-lts \
   --image-project=ubuntu-os-cloud \
   --machine-type=g1-small \
   --tags puma-server \
   --restart-on-failure \
   --metadata-from-file startup-script=startup_script.sh
```
 
* Создание firewall правила:
```
gcloud compute \
   --project=infra-219416 firewall-rules create default-puma-server \
   --direction=INGRESS \
   --priority=1000 \
   --network=default \
   --action=ALLOW \
   --rules=tcp:9292 \
   --source-ranges=0.0.0.0/0 \
   --target-tags=puma-server
```

* Адрес сервера:
```
testapp_IP = 35.228.143.155
testapp_port = 9292
```

### Homework #3 (Bastion)

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=cloud-bastion)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

Подключение в одну строку:

```ssh -o ProxyCommand='ssh -W %h:%p appuser@bastion-ip' appuser@local-server-ip```

Подключение через alias: ssh someinternalhost

Необходимо добавить в ~/.ssh/config:

```
Host bastion
  Hostname bastion-ip
  User appuser
  IdentityFile ~/.ssh/appuser

Host someinternalhost
  Hostname local-server-ip
  User appuser
  ProxyCommand ssh -W %h:%p bastion
  IdentityFile ~/.ssh/appuser
```

Кофигурация виртуальных машин:
```
bastion_IP = 35.210.240.60
someinternalhost_IP = 10.132.0.3
```
