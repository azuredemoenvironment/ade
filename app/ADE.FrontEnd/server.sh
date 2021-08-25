#!/bin/bash

SCRIPT_FULL_PATH=$(dirname "$0")
cd $SCRIPT_FULL_PATH

# Get App Configuration Values
node configuration.js

# Execute Environment Script
./env.sh

# Start Server
http-server --cors ./ -p 80