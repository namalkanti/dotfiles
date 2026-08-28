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

#Python Aliases
alias pip='uv pip'

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
alias aider='aider --cache-prompts --no-auto-commits --model openrouter/moonshotai/kimi-k2.7-code --weak-model openrouter/deepseek/deepseek-v4-flash-0731'
alias aider-terra='aider --cache-prompts --no-auto-commits --reasoning-effort none --model openai/gpt-5.6-terra --weak-model openai/gpt-5.6-luna'
alias aider-gemini='aider --cache-prompts --no-auto-commits --subtree-only --model gemini/gemini-3.7-flash --weak-model gemini/gemini-3.7-flash'
alias aider-sonnet='aider --cache-prompts --no-auto-commits --thinking-tokens 0 --model anthropic/claude-sonnet-5 --weak-model anthropic/claude-haiku-4-5'
alias aider-opus='aider --cache-prompts --no-auto-commits --thinking-tokens 0 --model anthropic/claude-opus-4-8 --weak-model anthropic/claude-haiku-4-5'
alias aider-sol='aider --cache-prompts --no-auto-commits --reasoning-effort none --model openai/gpt-5.6-sol --weak-model openai/gpt-5.6-luna'
alias aider-deepseek-flash='aider --cache-prompts --no-auto-commits --reasoning-effort none --model openrouter/deepseek/deepseek-v4-flash-0731 --weak-model openrouter/deepseek/deepseek-v4-flash-0731'
alias aider-qwen='aider --cache-prompts --no-auto-commits --model openrouter/qwen/qwen3.8-27b --weak-model openrouter/qwen/qwen3.8-27b'

aider-qwen-coder() {
    OLLAMA_API_BASE=http://localhost:11434 command aider --chat-mode ask --cache-prompts --no-gitignore --no-auto-commits --subtree-only --model ollama_chat/qwen2.5-coder:14b --weak-model ollama_chat/qwen2.5-coder:14b "$@"
}
export AIDER_READ=~/.aider.instructions.md

#Pi aliases
ask() {
    PI_REASONING_LEVEL=off pi -p --no-session --no-tools \
        --system-prompt 'Be concise and direct. Use minimal markdown. End with a single bold summary line starting with "**TL;DR:**".' \
        --model openrouter/deepseek/deepseek-v4-flash-0731 \
        "$@"
}

cmd() {
    local result
    result=$(PI_REASONING_LEVEL=off pi -p --no-session --no-tools \
        --system-prompt 'Output only a single shell command with no explanation, markdown, or extra text. The command must be directly executable in bash.' \
        --model openrouter/deepseek/deepseek-v4-flash-0731 \
        "$@")
    printf '%s\n' "$result"
    printf '%s' "$result" | xclip -selection clipboard
}
