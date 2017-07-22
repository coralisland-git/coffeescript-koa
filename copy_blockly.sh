#!/bin/sh

BPATH=./ninja/vendor/blockly

mkdir $BPATH 2>/dev/null
cp ./node_modules/node-blockly/blockly/msg/js/en.js $BPATH
cp ./node_modules/node-blockly/blockly/blockly_compressed.js $BPATH/blockly_compressed.js
cp ./node_modules/node-blockly/blockly/blocks_compressed.js $BPATH/blocks_compressed.js
cp ./node_modules/node-blockly/blockly/javascript_compressed.js $BPATH/javascript_compressed.js

