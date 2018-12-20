i3-msg 'workspace 1;
    exec "echo \"source ~/.bashrc; cd ~/projects/beacon/messenger; source .venv/bin/activate\" > tmp0 && urxvt -title ganache -e bash --init-file tmp0"'

sleep 1

i3-msg 'workspace 4;
    append_layout ~/.config/i3/layouts/beacon-terminals.json;
    exec "echo \"source ~/.bashrc; cd ~/projects/beacon/blockchain; ./node_modules/.bin/ganache-cli -d\" > tmp && urxvt -title ganache -e bash --init-file tmp";
    exec "echo \"sleep 5; source ~/.bashrc; cd ~/projects/beacon/messenger; source .venv/bin/activate; python contract_setup.py\" > tmp2 && urxvt -title scratch -e bash --init-file tmp2";
    exec "echo \"source ~/.bashrc; cd ~/projects/beacon/server; source .venv/bin/activate\" > tmp3 && urxvt -title server -e bash --init-file tmp3";
    exec "bash -c \"sleep 1 && rm ~/tmp*\"";
    workspace 1;
    focus;'

sleep 1

i3-msg '[title=^server$] focus;'
