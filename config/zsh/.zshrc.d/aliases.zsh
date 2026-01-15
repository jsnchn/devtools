# Shell aliases

alias ll="ls -al"
alias lzg="lazygit"
alias lzd="lazydocker"
alias lt="npx localtunnel --subdomain jsnchn --port"
alias air="~/go/bin/air"
alias opencode="opencode upgrade && opencode"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Devtools management
alias devtools="cd ~/.devtools"
alias devtools-up="cd ~/.devtools && git add -A && git commit -m 'update configs' && git push"
alias devtools-down="cd ~/.devtools && git pull && ./install.sh"
