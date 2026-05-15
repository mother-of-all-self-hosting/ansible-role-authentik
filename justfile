# SPDX-FileCopyrightText: 2023, 2024 Aine
# SPDX-FileCopyrightText: 2023-2026 Slavi Pantaleev
# SPDX-FileCopyrightText: 2025 Guillaume MASSON
# SPDX-FileCopyrightText: 2025 Suguru Hirahara
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# show help by default
default:
    @{{ just_executable() }} --list --justfile "{{ justfile() }}"

# mise (dev tool version manager)
mise_data_dir := env("MISE_DATA_DIR", justfile_directory() / "var/mise")
mise_trusted_config_paths := justfile_directory() / "mise.toml"
prek_home := env("PREK_HOME", justfile_directory() / "var/prek")

# Invokes mise with the project-local data directory
mise *args: _ensure_mise_data_directory
    #!/bin/sh
    export MISE_DATA_DIR="{{ mise_data_dir }}"
    export MISE_TRUSTED_CONFIG_PATHS="{{ mise_trusted_config_paths }}"
    export MISE_YES=1
    export PREK_HOME="{{ prek_home }}"
    mise {{ args }}

# Runs prek (pre-commit hooks manager) with the given arguments
prek *args: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} mise exec -- prek {{ args }}

# Runs pre-commit hooks on staged files
prek-run-on-staged *args: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} prek run {{ args }}

# Runs pre-commit hooks on all files
prek-run-on-all *args: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} prek run --all-files {{ args }}

# Installs the git pre-commit hook
prek-install-git-pre-commit-hook: _ensure_mise_tools_installed
    #!/usr/bin/env sh
    set -eu
    {{ just_executable() }} --justfile {{ justfile() }} mise exec -- prek install
    hook="{{ justfile_directory() }}/.git/hooks/pre-commit"
    # The installed git hook runs later under Git, outside this just/mise environment.
    # Injecting PREK_HOME keeps prek's cache under var/prek instead of a global home dir,
    # which is more predictable and works better in sandboxed tools like Codex/OpenCode.
    if [ -f "$hook" ] && ! grep -q '^export PREK_HOME=' "$hook"; then
        sed -i '2iexport PREK_HOME="{{ prek_home }}"' "$hook"
    fi

# Internal - ensures var/mise and var/prek directories exist
_ensure_mise_data_directory:
    @mkdir -p "{{ mise_data_dir }}"
    @mkdir -p "{{ prek_home }}"

# Internal - ensures mise tools are installed
_ensure_mise_tools_installed: _ensure_mise_data_directory
    @{{ just_executable() }} --justfile {{ justfile() }} mise install --quiet
