#!/bin/bash

rsync -rlhcv --delete _book/ cslinux:/courses/cs3110/2019sp/textbook

#cslinux:/people/mrc26/3110-2018fa/textbook

if [[ `git status --porcelain` ]]; then 
  cat <<EOF
===========================================================
WARNING

Your working tree has uncommitted changes, which means 
you've just deployed something into production that is not
under source control.  You might want to fix that.  Have 
you forgotten to pull, to add new files, or to push your 
changes?  

Run "git status" if you want to see what has changed
in your working tree.
===========================================================
EOF
fi
