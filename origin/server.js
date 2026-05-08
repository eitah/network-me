const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim()
    ?? req.socket.remoteAddress;

  const body = JSON.stringify({
    hostname: os.hostname(),
    clientIp,
    timestamp: new Date().toISOString(),
  }, null, 2);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(body + '\n');
});

server.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
});
