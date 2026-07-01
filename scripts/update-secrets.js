const fs = require('fs');
const path = require('path');
const https = require('https');
const sodium = require('libsodium-wrappers');

const OWNER = 'hossin00';
const REPO = 'sudoku-master';

const token = process.env.GH_TOKEN;
if (!token) {
  console.error('GH_TOKEN env var required');
  process.exit(1);
}

const base64Path = path.resolve(__dirname, '..', 'keystore-base64.txt');
const keystoreB64 = fs.readFileSync(base64Path, 'utf8').trim();

const secrets = {
  KEYSTORE_BASE64: keystoreB64,
  STORE_PASSWORD: 'SudokuMaster2026',
  KEY_PASSWORD: 'SudokuMaster2026',
  KEY_ALIAS: 'sudokumaster',
};

function gh(method, urlPath, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = https.request(
      {
        method,
        host: 'api.github.com',
        path: urlPath,
        headers: {
          'User-Agent': 'sudokumaster-secret-updater',
          'Accept': 'application/vnd.github+json',
          'Authorization': `Bearer ${token}`,
          'X-GitHub-Api-Version': '2022-11-28',
          ...(data ? { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) } : {}),
        },
      },
      (res) => {
        let chunks = '';
        res.on('data', (c) => (chunks += c));
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve({ status: res.statusCode, body: chunks ? JSON.parse(chunks) : null });
          } else {
            reject(new Error(`HTTP ${res.statusCode} ${method} ${urlPath} -> ${chunks}`));
          }
        });
      },
    );
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

(async () => {
  await sodium.ready;
  const pk = await gh('GET', `/repos/${OWNER}/${REPO}/actions/secrets/public-key`);
  console.log(`Public key id: ${pk.body.key_id}`);

  for (const [name, value] of Object.entries(secrets)) {
    const messageBytes = Buffer.from(value, 'utf8');
    const keyBytes = Buffer.from(pk.body.key, 'base64');
    const encryptedBytes = sodium.crypto_box_seal(messageBytes, keyBytes);
    const encryptedValue = Buffer.from(encryptedBytes).toString('base64');

    await gh('PUT', `/repos/${OWNER}/${REPO}/actions/secrets/${name}`, {
      encrypted_value: encryptedValue,
      key_id: pk.body.key_id,
    });
    console.log(`Set secret: ${name} (${value.length} chars)`);
  }
})().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
