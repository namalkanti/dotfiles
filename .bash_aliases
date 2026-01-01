#Config Aliases
alias aliases='gvim ~/.bash_aliases'
alias ssh-config='gvim ~/.ssh/config'

# enable color support of ls and also add handy aliases
alias ls='ls -h --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

#Vim aliases
alias vim='nvim'
alias gvim='neovide'

#Usability aliases
alias ll='ls -alF'
alias la='ls -A'
alias du='du -kh'
alias df='df -kTh'

alias status='sudo systemctl status'
alias is-active='sudo systemctl is-active'
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias daemon-reload='sudo systemctl daemon-reload'
alias sysedit='sudo -E systemctl edit'

#Arch Aliases
alias offline='sudo shutdown now'
alias reboot='sudo shutdown --reboot now'

#Tmux aliases
alias tn='tmux new -s'
alias tl='tmux ls'
alias ta='tmux a -t'

#lf commands
nav () {
    # `command` is needed in case `lfcd` is aliased to `lf`
    cd "$(command lf -print-last-dir "$@")"
}

#Aider aliases
alias aider='aider --model openai/gpt-5.2 --chat-mode ask --no-auto-commits --subtree-only'
alias aider-continue='aider --restore-chat-history'

#Chatgpt Cli aliases
alias chatgpt='chatgpt --model=gpt-4.1'
alias chatblade='chatblade --openai-api-key=${OPENAI_API_KEY} --openai-base-url="https://api.openai.com/v1/" --chat-gpt=gpt-4.1 -l'
