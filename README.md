ozyab09_infra
```
ozyab09 Infra repository
```

### Homework #7
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


### Homework #6
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


### Homework #5

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



### Homework #4

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

### Homework #3

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

