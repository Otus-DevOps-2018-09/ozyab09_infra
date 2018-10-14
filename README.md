# ozyab09_infra
```ozyab09 Infra repository```

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
  IdentityFile ~/.ssh/appuser```

``````

Кофигурация виртуальных машин:
```
bastion_IP = 35.210.240.60
someinternalhost_IP = 10.132.0.3
```

