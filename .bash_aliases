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
