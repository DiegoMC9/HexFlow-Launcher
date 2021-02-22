#!/bin/sh
# echo -n "Insert homebrew name: "
# read TITLE
# echo -n "Insert homebrew title ID (4 characters): "
# read ID
TITLE="test"
ID="TEST"

vita-mksfoex -s TITLE_ID="${ID}00001" $TITLE src/sce_sys/param.sfo
7z a -tzip "$TITLE.vpk" -r ./src/* ./lpp/eboot.bin
