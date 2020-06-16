## DJANGO INSTALL CLEAN TEMPLATE

### Преимущества
1. Автоматическая установка виртуального окружения и всех зависимостей в проекте
2. Добавление настроек nginx для доступа к приложению
3. Автоматическая связь gunicorn и nginx
4. Создание юнита gunicorn и добавление его в systemctl
5. Возможность автоматически добавить ssl и редирект с сайту
6. Генерация .env файла, установка **SECRET_KEY** и **DEBUG=False**  

### Старт установки. 

	./install.sh

### Добавление базы данных postgres
На сервере должен присутствовать пользователь **postgres** для работы администрирования баз данных и пользователь **dbuser** пароль которого будет использоваться для доступа
```bash
su - postgres
createdb --encoding UNICODE __database_name__ --username postgres
exit
grant all privileges on database __database_name__ to dbuser;
\c __database_name__
GRANT ALL ON ALL TABLES IN SCHEMA public to dbuser;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public to dbuser;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public to dbuser;
CREATE EXTENSION pg_trgm;
ALTER EXTENSION pg_trgm SET SCHEMA public;
UPDATE pg_opclass SET opcdefault = true WHERE opcname='gin_trgm_ops';
\q
exit
```
Необходимо добавить в `src/core/settings/.env` доступ к созданной базе данных 

`DATABASE_URL=psql://dbuser:__your_password__@localhost:5432/__database_name__`

### Просмотр состояния gunicorn
```bash
sudo systemctl status gunicorn
```
Логи gunicorn'а лежат в `gunicorn/access.log` и `gunicorn/error.log`.
После изменения systemd конфига надо перечитать его и затем перезапустить юнит:

```bash
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
```