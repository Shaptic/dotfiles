alias snip="import snip.png"
alias snipc="snip && xclip -selection clipboard -target image/png < snip.png && rm snip.png"
alias explore="nautilus --no-desktop &"
alias pdf="evince"

alias lock="gnome-screensaver-command -l"

# Task manager.
alias t="python2 ~/taskmgr/t.py --task-dir ~/taskmgr/tasks --list tasks"
alias ct="python2 ~/taskmgr/t.py --task-dir ~/taskmgr/tasks --list coding-tasks"

alias io="ssh shaptic@192.168.0.101 -p 1337"
alias phone="ssh mobile@192.168.0.100"

alias colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

alias spotify="spotify --force-device-scale-factor=1.5"
