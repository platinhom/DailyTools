#! /bin/bash
# Author: Hom, 2015.10.13
# Setup for bashrc

export WORKDIR_PATH="~"
export DESKTOP_PATH="~/Desktop"
export MYGIT_PATH="/Users/Hom/MyGit"
export MYGIT_ALL="platinhom.github.com CADDHom DailyTools HomPDF MolShow"
export GHPAGE_PATH="${MYGIT_PATH}/platinhom.github.com"
export GIT_DAILYTOOLS_PATH="${MYGIT_PATH}/DailyTools"
export GIT_CADDHOM_PATH="${MYGIT_PATH}/CADDHom"
export GIT_MOLSHOW_PATH="${MYGIT_PATH}/MolShow"
export GIT_HOMPDF_PATH="${MYGIT_PATH}/HomPDF"
export dt="$GIT_DAILYTOOLS_PATH/scripts"
export PATH="$HOME/bin:$PATH:$dt:$GIT_DAILYTOOLS_PATH/bin"
export HPCC='zhaozx@gateway.hpcc.msu.edu:~'

###### alias ########
# goto
alias goto_blog="cd $GHPAGE_PATH"
alias goto_mygit="cd $MYGIT_PATH"
alias goto_desktop="cd $DESKTOP_PATH"
alias goto_work="cd $WORKDIR_PATH"

# source
alias source_bashrc='source ~/.bashrc'
## only work for exist software
alias source_amber="source ~/AmberTools/amber.sh"
alias source_g09="source ~/gau_setup.sh"

# short command
alias ll='ls -lh'
alias la='ls -ah'
alias vi='vim'

# ssh
alias hpcc='ssh zhaozx@hpcc.msu.edu'
alias weilab="ssh root@23.239.23.221"

# software
alias subl="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
#alias subl="/c/Program\ Files/Sublime\ Text\ 3/subl.exe"
alias matlabno="matlab -nodesktop -nosplash"
alias mou="/Applications/Mou.app/Contents/MacOS/Mou"
alias mysql="/Applications/XAMPP/bin/mysql"
