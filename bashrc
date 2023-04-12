#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
source '/opt/kube-ps1/kube-ps1.sh'
PS1='[\u@\h \W $(kube_ps1)]$ '

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/erasmussen/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
