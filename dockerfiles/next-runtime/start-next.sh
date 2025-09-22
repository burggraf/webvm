#!/bin/sh
set -e

cd /home/user/next-app

if [ ! -d node_modules ]; then
  echo "Installing npm dependencies..."
  npm install --no-audit --no-fund
fi

exec npm run dev
