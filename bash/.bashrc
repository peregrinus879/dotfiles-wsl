# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.config/bash/envs
source ~/.config/bash/shell
source ~/.config/bash/aliases
source ~/.config/bash/init

[[ $- == *i* ]] && bind -f ~/.inputrc
