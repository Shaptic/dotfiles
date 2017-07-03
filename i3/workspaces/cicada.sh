i3-msg 'workspace 2;
    layout tabbed;
    exec subl -a -n ~/cicada;'

i3-msg 'workspace 1;
    append_layout ~/.config/i3/layouts/cicada-terminals.json;
    exec i3-sensible-terminal;
    exec i3-sensible-terminal;
    exec i3-sensible-terminal;
    focus;'

i3-msg 'workspace 5;
    exec evince ~/cicada/chord.pdf;'
