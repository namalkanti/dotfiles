#Config Aliases
alias aliases='gvim ~/.bash_aliases'
alias ssh-config='gvim ~/.ssh/config'

# enable color support of ls and also add handy aliases
alias ls='ls -h --color=auto'
alias kat='cat'

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
alias tn='tmux -2 new -s'
alias tl='tmux ls'
alias ta='tmux a -t'


#lf commands
nav () {
    cd "$(command lf -print-last-dir "$@")"
}

#Aider aliases
alias aider='aider --chat-mode ask --cache-prompts --no-gitignore --no-auto-commits --subtree-only --model gemini/gemini-3.5-flash --weak-model anthropic/claude-haiku-4-5-20251001'
alias aider-sonnet='aider --model anthropic/claude-sonnet-4-6 --weak-model anthropic/claude-haiku-4-5-20251001'
alias aider-qwen='aider --model ollama_chat/qwen3.6:35b-mlx'
alias aider-continue='aider --restore-chat-history'
alias aider-opus='aider --model anthropic/claude-opus-4-8 --weak-model anthropic/claude-haiku-4-5-20251001'
alias aider-gpt='aider --model openai/gpt-5.4-2026-03-05 --weak-model openai/gpt-5.4-nano-2026-03-17'
alias aider-gpt-big='aider --model openai/gpt-5.5-2026-04-23 --weak-model openai/gpt-5.4-nano-2026-03-17'
#alias aider-gem='aider --model gemini/gemini-3.5-pro'  # not yet available
aider-qwen-coder() {
    OLLAMA_API_BASE=http://localhost:11434 command aider --chat-mode ask --cache-prompts --no-gitignore --no-auto-commits --subtree-only --model ollama_chat/qwen2.5-coder:14b --weak-model ollama_chat/qwen2.5-coder:14b "$@"
}
export AIDER_READ=~/.aider.instructions.md

#Aichat
alias bash-gen='aichat -e'
alias ai='aichat'
alias ai-nano='aichat -m openai:gpt-5.4-nano-2026-03-17'
alias ai-flash='aichat -m gemini:gemini-3.5-flash'
