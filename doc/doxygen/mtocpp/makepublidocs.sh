#!/bin/bash
DIR=../morepas_web/software/mtocpp/docs
cd build
rm -rf $DIR
cmake -DCMAKE_INSTALL_PREFIX="~/agh" -DCUSTOM_DOC_DIR="$DIR" ..
make install
