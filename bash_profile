#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
. "$HOME/.cargo/env"
export PATH=$PATH:/usr/local/go/bin

# We're fine with this here
# shellcheck disable=SC2139
alias go="$HOME/go/bin/go1.22.1"
