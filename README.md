# ozyab09_infra
ozyab09 Infra repository

* Подключение в одну строку:
ssh -o ProxyCommand='ssh -W %h:%p appuser@bastion-ip' appuser@local-server-ip

* Подключение через команду ssh someinternalhost
Необходимо добавить в ~/.ssh/config:

Host bastion
  Hostname bastion-ip
  User appuser
  IdentityFile ~/.ssh/appuser

Host someinternalhost
  Hostname local-server-ip
  User appuser
  ProxyCommand ssh -W %h:%p bastion
  IdentityFile ~/.ssh/appuser

После этого можно подключаться :)
