# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository that automates development environment setup on Debian/Ubuntu-based Linux machines. It consists of a single installer script plus the config files it deploys — there is no build system, package manager, or test suite.

## Documentation maintenance (required)

This repo has no CI, so its docs only stay accurate if edits keep them in sync manually. On **every** change to `install.sh` (new/removed/renamed tool, changed detection logic, changed usage flow, etc.):

- Update `README.md`'s "Included Tools and Configurations" and "Uninstallation" sections to match the new behavior.
- Update this `CLAUDE.md` if the change affects the architecture, conventions, or "Adding a new tool" steps described below (e.g. a new install pattern, a new mandatory step, a change to the selection UI).

Treat these doc updates as part of the change itself, not a follow-up — don't leave a PR/commit with `install.sh` changed but `README.md`/`CLAUDE.md` stale.

## Files

- `install.sh` — the installer. Copies config files into `$HOME` and interactively installs developer tools.
- `.bashrc`, `.gitconfig` — config files copied verbatim to `~/.bashrc` and `~/.gitconfig` by the installer.
- `README.md` — user-facing setup/uninstall instructions; keep it in sync with `install.sh` when tools are added/removed.

## Running / testing changes

- Syntax-check after editing: `bash -n install.sh`
- There's no automated test suite. Verify behavior by running `bash install.sh` on an Ubuntu/Debian machine (or container) and checking the whiptail checklist, install/skip logic, and resulting files in `$HOME`.

## Architecture of `install.sh`

- **Mandatory setup** (not selectable) runs first and unconditionally: apt base deps (`git`, `unzip`, `bash-completion`, `whiptail`), then copying `.bashrc` and `.gitconfig` into `$HOME`. `git` is required by `install_fzf`, which clones from GitHub. A failure here `exit 1`s the script, since nothing downstream can succeed.
- **Selectable tools** are each implemented as an `install_<tool>()` function (e.g. `install_docker`, `install_aws`, `install_ssm_plugin`, `install_terraform`, `install_kubectl`, `install_nvm`, `install_uv`, `install_fzf`, `install_ohmyposh`, `install_ssh`, `install_gh`, `install_glab`, `install_htop`). Every function follows the same pattern:
  1. Guard clause: detect if the tool is already installed (via `command -v`, `dpkg -s`, or checking for a directory like `~/.nvm`/`~/.fzf`) and `return` early with `print_skip` if so.
  2. Otherwise run the install commands (unchanged from the tool's official install instructions) and log with `print_info`/`print_success`.
  3. Return non-zero on failure so the dispatch loop can record it. apt-based tools get this for free from the `apt_update`/`apt_install` helpers (see below); tools that fail another way should `print_error "..."` and `return 1` explicitly.
- **Selection UI**: after mandatory setup, a `whiptail --checklist` presents all tools with `ON` (pre-checked) by default. The user toggles with SPACE and confirms with ENTER.
- **Dispatch**: the script parses the `whiptail` output and calls the corresponding `install_<tool>` function via a `case` statement for each selected key. If the user cancels or selects nothing, tool installation is skipped entirely (mandatory setup still applies). Whiptail's exit status is captured into `WHIPTAIL_STATUS` immediately — don't put any command between the assignment and the check, or `$?` is clobbered.
- **Failure reporting**: each dispatched function's exit status is checked and failing keys are collected into the `FAILED` array. If it's non-empty the script prints them via `print_error` and exits 1. This exists because a single malformed file in `/etc/apt/sources.list.d` makes *every* subsequent apt call fail, and the script otherwise reported success for tools that never installed.

### Adding a new tool

1. Write an `install_<tool>()` function following the existing guard-clause + install pattern.
2. Add an entry to the `TOOLS` array (`key "Description" ON`) used to build the whiptail checklist — keep new tools defaulted to `ON`.
3. Add the matching `key) install_<tool> ;;` case in the dispatch loop.
4. Update the whiptail checklist height/item-count args (currently `24 70 13` — height, width, list-height) if the number of items changes.
5. Make sure the function returns non-zero on failure so it's picked up by the `FAILED` summary.
6. Update `README.md`'s "Included Tools and Configurations" and "Uninstallation" sections to match.

## Conventions

- Logging: use `print_info "..."` before an install step, `print_success "..."` after it completes, `print_skip "..."` when a guard clause short-circuits, and `print_error "..."` on failure (it writes to stderr) — don't use raw `echo` for status messages.
- apt: always go through `apt_update` and `apt_install <pkgs>` rather than calling `sudo apt-get` directly, and pair each with `|| return 1`. The wrappers turn a silent apt failure into a visible error plus a non-zero status.
- Distro detection: read `/etc/os-release` (`ID`, `VERSION_CODENAME`, `UBUNTU_CODENAME`, `ID_LIKE`), never `/etc/lsb-release` — it doesn't exist on Debian. Validate that the resolved value is non-empty before interpolating it into an apt source line; an empty codename produces a malformed entry that breaks apt globally for the rest of the run.
- Keep each tool's actual install commands as close as possible to that tool's official documented install steps (this repo intentionally mirrors upstream instructions rather than wrapping package managers).
