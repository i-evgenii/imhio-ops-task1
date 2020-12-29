# imhio-ops-task1
## Требования:
- 2 x инстанса с доступом из публичных сетей
- OS Centos 7.x
- оба инстанса также подключены к одной частной сети для организации безопасного обмена
данными между приложением и БД
- ко второму инстансу подключен дополнительный внешний volume для хранения данных
- firewall включен только для внешнего интерфейса
- в firewall по-умолчанию все порты закрыты для внешнего интерфейса
- ssh доступ ограничен по IP из публичных сетей
- для первого инстанса доступ к порту 8084 из публичной сети разрешен без ограничений

1. In the Cloud Console, click Activate Cloud Shell.

2. If prompted, click Continue.

3. Download my play-book.
```
wget https://github.com/i-evgenii/imhio-ops-task1/archive/main.zip
unzip main.zip
cd imhio-ops-task1-main/
```
4. Confirm that Terraform is installed
> terraform --version

5. Rewrite the Terraform configurations files to a canonical format and style 
> terraform fmt

6. Initialize Terraform
> terraform init

7. Create an execution plan
> terraform plan

8. Apply the desired changes
> terraform apply

9. Confirm the planned actions
> yes