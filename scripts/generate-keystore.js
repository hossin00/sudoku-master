#!/usr/bin/env node
/**
 * Generates a PKCS12 keystore for Android release signing using node-forge.
 * No JDK / keytool required.
 */

const fs = require('fs');
const path = require('path');
const forge = require('node-forge');

const KEY_ALIAS = process.env.KEY_ALIAS || 'sudokumaster';
const STORE_PASSWORD = process.env.STORE_PASSWORD || 'SudokuMaster2026';
const KEY_PASSWORD = process.env.KEY_PASSWORD || 'SudokuMaster2026';

const root = path.resolve(__dirname, '..');
const keystorePath = path.join(root, 'android', 'app', 'keystore.jks');
const keyPropsPath = path.join(root, 'android', 'key.properties');
const base64OutPath = path.join(root, 'keystore-base64.txt');

console.log('Generating 2048-bit RSA key pair...');
const keys = forge.pki.rsa.generateKeyPair(2048);

console.log('Creating self-signed certificate (25 years)...');
const cert = forge.pki.createCertificate();
cert.publicKey = keys.publicKey;
cert.serialNumber = '01' + forge.util.bytesToHex(forge.random.getBytesSync(7));
cert.validity.notBefore = new Date();
cert.validity.notAfter = new Date();
cert.validity.notAfter.setFullYear(cert.validity.notBefore.getFullYear() + 25);

const subjectAttrs = [
  { name: 'commonName', value: 'Sudoku Master' },
  { name: 'organizationName', value: 'Sudoku Master' },
  { name: 'organizationalUnitName', value: 'Mobile' },
  { name: 'localityName', value: 'Algiers' },
  { name: 'stateOrProvinceName', value: 'Algiers' },
  { name: 'countryName', value: 'DZ' },
];
cert.setSubject(subjectAttrs);
cert.setIssuer(subjectAttrs);
cert.sign(keys.privateKey, forge.md.sha256.create());

console.log('Packaging PKCS12 keystore...');
const p12Asn1 = forge.pkcs12.toPkcs12Asn1(
  keys.privateKey,
  [cert],
  STORE_PASSWORD,
  {
    friendlyName: KEY_ALIAS,
    algorithm: '3des',
  }
);
const p12Der = forge.asn1.toDer(p12Asn1).getBytes();
const p12Buffer = Buffer.from(p12Der, 'binary');

fs.mkdirSync(path.dirname(keystorePath), { recursive: true });
fs.writeFileSync(keystorePath, p12Buffer);
console.log(`Wrote ${keystorePath} (${p12Buffer.length} bytes)`);

const keyProps = [
  `storePassword=${STORE_PASSWORD}`,
  `keyPassword=${KEY_PASSWORD}`,
  `keyAlias=${KEY_ALIAS}`,
  `storeFile=keystore.jks`,
  '',
].join('\n');
fs.writeFileSync(keyPropsPath, keyProps);
console.log(`Wrote ${keyPropsPath}`);

const base64 = p12Buffer.toString('base64');
fs.writeFileSync(base64OutPath, base64);
console.log(`Wrote ${base64OutPath} (${base64.length} chars)`);
console.log('');
console.log('GitHub Secrets to add:');
console.log(`  KEYSTORE_BASE64   = contents of keystore-base64.txt`);
console.log(`  STORE_PASSWORD    = ${STORE_PASSWORD}`);
console.log(`  KEY_PASSWORD      = ${KEY_PASSWORD}`);
console.log(`  KEY_ALIAS         = ${KEY_ALIAS}`);
