alias snip="import snip.png"
alias snipc="snip && xclip -selection clipboard -target image/png < snip.png && rm snip.png"

alias lock="light-locker-command -l"

# Task manager.
alias t="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list tasks"
alias ct="python2 ~/.tasks/t.py --task-dir ~/.tasks/tasks --list coding-tasks"

alias colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

alias io="ssh shaptic@192.168.0.101 -p 1337"
alias nflx="firefox --new-tab ~/.config/i3/scripts/nflx.html & disown"

alias explore="thunar . & disown"
alias first="python ~/projects/init_script.py"

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
  evince "$*" & disown
}

function note {
  echo -n "Enter a snippet name: "
  read -r filename
  echo "Saving snippet to assets/$filename.png"
  import assets/$filename.png
  echo "\begin{figure}[H]
  \centering
  \includegraphics[width=0.3\textwidth]{assets/$filename.png}
  \caption{}
  \label{fig:$filename}
\end{figure}" | xclip -i -selection clipboard
  echo "Clipboard ready."
}

function wnote {
  echo -n "Enter a snippet name: "
  read -r filename
  echo "Saving snippet to assets/$filename.png"
  import assets/$filename.png
  echo "\begin{wrapfigure}{r}{0.475\textwidth}
  \centering
  \includegraphics[width=0.9\linewidth]{assets/$filename.png}
  \caption{}
  \label{fig:$filename}
\end{wrapfigure}" | xclip -i -selection clipboard
  echo "Clipboard ready."
}

function tweet {
  if hugo config > /dev/null; then
    local FILENAME=$(date '+blurb-%s.md')
    echo "Creating blurb with name $FILENAME"

    local FULLPATH=$(hugo new blurbs/$FILENAME | awk -F' ' '{print $1}')
    echo "$*" >> $FULLPATH
    subl -a $FULLPATH
  else
    echo "Error: $(pwd) does not contain a Hugo-based website."
  fi
}
