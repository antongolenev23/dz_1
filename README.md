# Домашнее задание 1 — Dockerfile и том для данных

Приложение Flask записывает заметки в PostgreSQL. Данные базы хранятся в именованном томе `golenev-09-data` и сохраняются при пересоздании контейнеров.

## Параметры

Вариант 09. Приложение: `python:3.12-alpine`, порт хоста 8027, внутренний порт 5009. База: `postgres:16-alpine`, порт хоста 8029.

## Запуск

Нужны Docker с поддержкой Linux-контейнеров, Bash, curl и Python 3. Команды выполняются в Ubuntu или WSL2, из корня репозитория.

```bash
bash run.sh
curl -s localhost:8027/me | python3 -m json.tool --no-ensure-ascii
curl -s -X POST localhost:8027/notes -d text=golenev-09-applab
curl -s localhost:8027/notes | python3 -m json.tool --no-ensure-ascii
```

Повторный `bash run.sh` пересоздаёт приложение и базу на прежнем томе. Он запускает приложение версии 2.0. Имена контейнеров: `golenev-09-web` и `golenev-09-db`. Порты 8027 и 8029 должны быть свободны.

## Обновление приложения

```bash
docker build --build-arg VERSION=2.1 -t golenev-09/probe:2.1 .
docker rm -f golenev-09-web
docker run -d --name golenev-09-web \
  -p 8027:5009 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8029/lab \
  golenev-09/probe:2.1
```

База при обновлении приложения не пересоздаётся. `lab` — учебный пароль для локального стенда.
