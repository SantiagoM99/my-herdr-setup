# Agent instructions

Before changing anything in this repo, read `skills/herdr-setup/SKILL.md`. It has the repo layout, the shortcut scheme, how to check for key collisions, how to test a change in a throwaway pane, and the commit rules.

The short version:

- Everything in this repo is in English: code, comments, docs and commit messages.
- Nothing project-specific: no project names or private paths. Per-machine values go in local config files outside the repo, such as `~/.config/herdr-setup/job-status.conf`.
- Edit the repo, never the installed copies. `install.sh` symlinks these files into `~/.config` and `~/.local/bin`.
