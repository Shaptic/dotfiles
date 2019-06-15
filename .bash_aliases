alias snip="import snip.png"
alias snipc="snip && xclip -selection clipboard -target image/png < snip.png && rm snip.png"

alias lock="light-locker-command -l"

# ML4T setup
alias ml4t="cd ~/school/ml4t-cs7646 && source .venv/bin/activate && cd projects/"

# Task manager.
alias t="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list tasks"
alias ct="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list coding-tasks"

alias colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

alias io="ssh shaptic@192.168.0.101 -p 1337"
alias nflx="firefox --new-tab ~/.config/i3/scripts/nflx.html & disown"

alias explore="thunar . & disown"

function makepdf {
  pdflatex $1
  if [[ -f references.bib ]]; then
      bibtex $1
      pdflatex $1
  fi
  pdflatex $1
  rm $1.{aux,out,log,bbl,blg}
  pdf $1.pdf
}

function pdf {
  evince $1 & disown
}

function note {
  echo -n "Enter a snippet name: "
  read -r filename
  echo "Saving snippet to assets/$filename.png"
  import assets/$filename.png
  echo "\begin{figure}[H]
  \centering
  \includegraphics[width=2in]{assets/$filename.png}
  \caption{}
  \label{fig:$filename}
\end{figure}" | xclip -i -selection clipboard
  echo "Clipboard ready."
}
