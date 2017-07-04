#!/usr/bin/python2
import os
import sys
import subprocess

REPO_PATH = "~/.dotfiles/"
BASE_PATH = "~/"

DIRECTORIES = {
    # source folder -> destination folder
    r".bashrc": "",
    r".bash_colors": "",
    r".bash_aliases": "",
    r".inputrc": "",
    r".Xresources": "",
    r".ssh/config": "",
    r".i3blocks.conf": "i3/",
    r".config/i3/": "i3/",
    r".config/dunst/dunstrc": "dunst/",
    r"/etc/init.d/gk-sensitivity.sh": "init.d/",
    r".config/sublime-text-3/Installed\ Packages/": "sublime-text-3/",
    r".config/sublime-text-3/Packages/": "sublime-text-3/",
}

def copy(src, dst):
    cmd = "cp -R %s %s" %(src, dst)
    subprocess.Popen(cmd, shell=True)

print "Assuming base path:", BASE_PATH
print "Assuming repo path:", REPO_PATH
for src, dst in DIRECTORIES.items():
    # Skip the unnecessary cache files.
    if src.lower().find("cache") != -1:
        continue

    # An empty string implies that we should mirror the destination path.
    if not dst:
        dst = src

    print "Backing up '%s' to '%s'" % (src, dst)

    # If the folder doesn't exist, create it.
    root = dst
    while root.count("/") > 1:
        root, _ = os.path.split(root)
    root, _ = os.path.split(root)   # one more time to leave off files
    full_dst = os.path.expanduser(os.path.join(REPO_PATH, root))

    if not os.path.exists(full_dst):
        print "The folder '%s' doesn't exist, creating it at '%s'" % (root, full_dst)
        os.mkdir(full_dst)

    copy(os.path.join(BASE_PATH, src), full_dst)
