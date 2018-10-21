ozyab09_infra
```
ozyab09 Infra repository
```

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=cloud-bastion)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

### Homework #3

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

### Homework #5

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=packer-base)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra)

* Создан файл ubuntu.json с простой конифгурацией образа Ubuntu, в которую включены установка mongodb и ruby. Параметры вынесены в отдельный файл variables.json (в репозитории отсутсвует)
* В файле variables.json.example расположен образец файла variables.json
* В образе, создаваемом файлом immutable.json также добавлен файл deploy.sh, который устанавливает web-севрис Puma
* Была попытка добавить в файл deploy.sh systemd unit puma.servie (происходит скачиваение файла packer/files/puma.service из текущего репозитория в /etc/systemd/system/, но почему-то не сработало :( ))
* Для проверки корректности файлов необходимо использовать: 
```
packer validate  -var-file=variables.json.example ubuntu16.json
packer validate  -var-file=variables.json.example ubuntu16.json
```
* В файле packer/config-scripts/create-reddit-vm.sh расположен скрипт создания виртуальной машины из созданного ранее образа

