ifeq ($(OS),Windows_NT)
EXE := .exe
native = $(subst /,\,$(1))
VCPKG_TRIPLET := x64-mingw-dynamic
else
EXE :=
native = $(1)
VCPKG_TRIPLET := x64-linux-dynamic
endif

ifneq ($(SKIP_VCPKG),1)
VCPKG_ROOT := $(CURDIR)/tools/vcpkg
endif

VCPKG := $(call native,$(VCPKG_ROOT)/vcpkg$(EXE))
APP := $(call native,out/app$(EXE))
FORMAT := $(call native,tools/clang-format$(EXE))

GIT_LS := git ls-files --cached --others --exclude-standard --
GIT_STAGED := git diff --cached --name-only --diff-filter=ACMR --
FORMAT_EXT := "*.cpp" "*.hpp" "*.h" "*.cc" "*.cxx" "*.cppm"

ifneq ($(wildcard .git),)
FORMAT_SRCS := $(shell $(GIT_LS) $(FORMAT_EXT))
STAGED_FORMAT := $(strip $(shell $(GIT_STAGED) $(FORMAT_EXT)))
endif

.DEFAULT_GOAL := compile

.PHONY: help deps compile run clean format format-staged hooks install install-dev

help:
	@echo deps          - поставить пакеты из vcpkg.json
	@echo compile       - собрать все программы
	@echo run           - собрать и запустить app
	@echo install       - скачать ninja и vcpkg в tools/
	@echo install-dev   - скачать clang-format в tools/ и поставить хук
	@echo hooks         - поставить хук format-staged
	@echo format        - clang-format
	@echo format-staged - clang-format по staged
	@echo clean         - удалить каталоги build и out


vcpkg_installed/.stamp: vcpkg.json
	$(VCPKG) install --triplet $(VCPKG_TRIPLET) --host-triplet=$(VCPKG_TRIPLET)
	cmake -E touch $@

deps: vcpkg_installed/.stamp

compile:
	cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM="$(CURDIR)/tools/ninja$(EXE)" -DCMAKE_CXX_COMPILER=g++ -DCMAKE_PREFIX_PATH="$(CURDIR)/vcpkg_installed/$(VCPKG_TRIPLET)"
	cmake --build build

run:
	$(APP)

install:
	cmake -P scripts/install.cmake

install-dev: install
	cmake -P scripts/install-dev.cmake
	$(MAKE) hooks

hooks:
	cmake -E copy scripts/pre-commit .git/hooks/pre-commit
ifneq ($(OS),Windows_NT)
	chmod +x .git/hooks/pre-commit
endif

clean:
	cmake -E rm -rf build out

format:
	$(FORMAT) -i $(FORMAT_SRCS)

format-staged:
ifneq ($(STAGED_FORMAT),)
	$(FORMAT) -i $(STAGED_FORMAT)
endif
