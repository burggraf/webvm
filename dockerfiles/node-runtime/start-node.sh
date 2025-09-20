#!/bin/sh
set -eu

cd /home/user/app

if [ ! -f package.json ] && [ ! -f server.js ]; then
  cat <<'APP' > server.js
const http = require('node:http');

const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end('Hello from Node.js!\n');
});

server.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
APP
fi

exec node server.js
