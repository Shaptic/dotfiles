alias snip="import snip.png"
alias snipc="snip && xclip -selection clipboard -target image/png < snip.png && rm snip.png"
alias explore="nautilus --no-desktop . &"
alias pdf="evince"

alias lock="light-locker-command -l"

# Task manager.
alias t="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list tasks"
alias ct="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list coding-tasks"

alias colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

alias io="ssh shaptic@192.168.0.101 -p 1337"
alias nflx="firefox --new-tab ~/home/m0bius/nflx.html & disown"

function makepdf {
  pdflatex $1
  if [[ -f references.bib ]]; then
      bibtex $1
      pdflatex $1
  fi
  pdflatex $1
  rm $1.{aux,out,log,bbl,blg}
  pdf $1.pdf &
  disown
}
