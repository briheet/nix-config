if status is-interactive
    # Commands to run in interactive sessions can go here
    alias vi='nvim'
    alias tmux='tmux -u'
    alias fzfprev=' fzf --preview="bat --color=always {}" '
    alias ff='fastfetch --config groups.jsonc'
    alias clock='tty-clock -c'
    alias task='go-task'
    #    alias ls='exa -l --icons'

    bind \co ranger-cd
    pyenv init - fish | source
    set -x MAKE_OPTS "-j1"
end
starship init fish | source

#function fish_prompt
#    echo -n (hostname)' '(basename (pwd))' \$'
#end
