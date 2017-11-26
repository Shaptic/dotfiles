i3-msg 'workspace 3;
    append_layout ~/.config/i3/layouts/workspace-3.json;
    exec firefox;
    exec thunderbird;
    workspace 4;
    layout splith;
    exec spotify --force-device-scale-factor=1.5;
    exec slack;
    workspace 4;'

sleep 5

i3-msg 'workspace 4;
    [class=Spotify] resize shrink width 10;
    workspace 1'
