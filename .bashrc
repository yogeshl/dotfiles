# Enable programmable bash completion (for Docker, Git, etc.)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Alias for ssh-copy-id using fzf to select remote host
alias ssh-copy="ssh-copy-id -i ~/.ssh/id_rsa.pub \$(grep -oP 'Host \K.*' ~/.ssh/config | fzf)"

# Initialize Oh My Posh with a default theme
eval "$(oh-my-posh init bash --config ~/.poshthemes/stelbent.minimal.omp.json)"