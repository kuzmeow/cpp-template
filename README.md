# Команды

Нужны `g++` с C++23, CMake 3.28+, GNU Make и Git. Ninja и vcpkg качаются в `tools/` и в систему не ставятся.

```
make install        скачать ninja и vcpkg в tools/
make deps           поставить пакеты из vcpkg.json
make compile        собрать, бинарник в out/app
make run            запустить out/app
make clean          удалить build/ и out/

make install-dev    install, плюс clang-format и pre-commit
make hooks          поставить хук, который форматирует staged-файлы
make format         отформатировать исходники
make format-staged  отформатировать только staged-файлы
```

`make help` печатает тот же список.

Обычный порядок: `make install`, затем `make deps`, затем `make compile`. `make run` сам не собирает. Аргументы ему не передать; имя запускается так: `out/app имя` (на Windows `out\app.exe`).

Образ:

```
docker compose build
docker compose run --rm app
```

Аргумент образа — тоже имя: `docker compose run --rm app имя`.
