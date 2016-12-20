#!/usr/bin/env bash
git clone git@github.com/robin-nyombi/APSRR-2016.git
git clone git@github.com/posenhuang/singingvoiceseparationrpca.git
if [ -f MIR-1K.rar ]
then
curl -O http://mirlab.org/dataset/public/MIR-1K.rar
fi
unrar x ./MIR-1K.rar
