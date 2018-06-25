alias snip="import snip.png"
alias snipc="snip && xclip -selection clipboard -target image/png < snip.png && rm snip.png"
alias explore="nautilus --no-desktop &"
alias pdf="evince"

alias lock="light-locker-command -l"

# Task manager.
alias t="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list tasks"
alias ct="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list coding-tasks"

alias colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

alias io="ssh shaptic@192.168.0.101 -p 1337"
alias spotify="spotify --force-device-scale-factor=1.5"
alias nflx="firefox --new-tab ~/home/m0bius/nflx.html &"

function makepdf {
  pdflatex $1.tex
  pdflatex $1.tex
  rm $1.out $1.log
  evince $1.pdf
}
