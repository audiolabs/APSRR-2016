#!/usr/bin/env bash
git clone https://github.com/robin-nyombi/APSRR-2016
git clone https://github.com/posenhuang/singingvoiceseparationrpca
curl -O http://mirlab.org/dataset/public/MIR-1K.rar
# if you do not have unrar, then
brew install unrar
# which is followed by
unrar x ./MIR-1K.rar
