ozyab09_infra
```
ozyab09 Infra repository
```

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=cloud-bastion)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09)

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

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09_infra.svg?branch=cloud-testapp)](https://travis-ci.com/Otus-DevOps-2018-09/ozyab09)

### Homework #4

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

