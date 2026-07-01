// Generate a premium Sudoku Master 2026 launcher icon (PNG) without external deps.
// Uses the built-in DEFLATE via Node's zlib. Writes assets/icon/icon.png at 1024x1024.

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const SIZE = 1024;

// Colors
function rgb(r, g, b) { return [r, g, b, 255]; }
const BG_DARK = rgb(10, 10, 26);        // #0A0A1A
const BLUE = rgb(0, 200, 255);          // #00C8FF
const PURPLE = rgb(168, 85, 247);       // #A855F7
const GOLD = rgb(255, 215, 0);          // #FFD700

function mix(c1, c2, t) {
  return [
    Math.round(c1[0] * (1 - t) + c2[0] * t),
    Math.round(c1[1] * (1 - t) + c2[1] * t),
    Math.round(c1[2] * (1 - t) + c2[2] * t),
    255,
  ];
}

function overRGBA(base, over) {
  const alpha = over[3] / 255;
  return [
    Math.round(over[0] * alpha + base[0] * (1 - alpha)),
    Math.round(over[1] * alpha + base[1] * (1 - alpha)),
    Math.round(over[2] * alpha + base[2] * (1 - alpha)),
    255,
  ];
}

function pixels() {
  const buf = new Uint8Array(SIZE * SIZE * 4);
  for (let i = 0; i < SIZE * SIZE; i++) {
    const p = i * 4;
    buf[p] = BG_DARK[0];
    buf[p + 1] = BG_DARK[1];
    buf[p + 2] = BG_DARK[2];
    buf[p + 3] = 255;
  }
  return buf;
}

function setPx(buf, x, y, c) {
  if (x < 0 || x >= SIZE || y < 0 || y >= SIZE) return;
  const p = (y * SIZE + x) * 4;
  buf[p] = c[0];
  buf[p + 1] = c[1];
  buf[p + 2] = c[2];
  buf[p + 3] = c[3];
}

function getPx(buf, x, y) {
  const p = (y * SIZE + x) * 4;
  return [buf[p], buf[p + 1], buf[p + 2], buf[p + 3]];
}

function fillRoundedRect(buf, x, y, w, h, r, colorFn) {
  for (let py = y; py < y + h; py++) {
    for (let px = x; px < x + w; px++) {
      let inside = true;
      const dx = px < x + r ? x + r - px : (px > x + w - r - 1 ? px - (x + w - r - 1) : 0);
      const dy = py < y + r ? y + r - py : (py > y + h - r - 1 ? py - (y + h - r - 1) : 0);
      if (dx > 0 && dy > 0) {
        if (dx * dx + dy * dy > r * r) inside = false;
      }
      if (inside) {
        const u = (px - x) / w;
        const v = (py - y) / h;
        const c = colorFn(u, v);
        setPx(buf, px, py, c);
      }
    }
  }
}

function drawLine(buf, x1, y1, x2, y2, thickness, color) {
  const half = thickness / 2;
  const minX = Math.min(x1, x2) - Math.ceil(half);
  const maxX = Math.max(x1, x2) + Math.ceil(half);
  const minY = Math.min(y1, y2) - Math.ceil(half);
  const maxY = Math.max(y1, y2) + Math.ceil(half);
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len2 = dx * dx + dy * dy;
  for (let py = minY; py <= maxY; py++) {
    for (let px = minX; px <= maxX; px++) {
      const t = ((px - x1) * dx + (py - y1) * dy) / len2;
      if (t < 0 || t > 1) continue;
      const projX = x1 + t * dx;
      const projY = y1 + t * dy;
      const distX = px - projX;
      const distY = py - projY;
      const dist = Math.sqrt(distX * distX + distY * distY);
      if (dist <= half) {
        setPx(buf, px, py, color);
      } else if (dist <= half + 1) {
        const alpha = 1 - (dist - half);
        const src = [color[0], color[1], color[2], Math.round(255 * alpha)];
        const base = getPx(buf, px, py);
        setPx(buf, px, py, overRGBA(base, src));
      }
    }
  }
}

function drawGlyphNine(buf, cx, cy, size, color) {
  // Chunky "9" glyph made of thick strokes
  const w = size * 0.55;
  const h = size * 0.9;
  const t = size * 0.13;
  const x = cx - w / 2;
  const y = cy - h / 2;

  // Top circle: draw a filled square with a hole
  // Outer square (rounded rectangle for the head)
  fillRoundedRect(buf, Math.round(x), Math.round(y), Math.round(w), Math.round(w),
    Math.round(w * 0.45), () => color);
  // Inner cut-out
  fillRoundedRect(
    buf,
    Math.round(x + t),
    Math.round(y + t),
    Math.round(w - 2 * t),
    Math.round(w - 2 * t),
    Math.round((w - 2 * t) * 0.45),
    () => BG_DARK
  );

  // Right vertical descender
  fillRoundedRect(
    buf,
    Math.round(x + w - t),
    Math.round(y + w * 0.5),
    Math.round(t),
    Math.round(h - w * 0.5),
    Math.round(t * 0.35),
    () => color
  );

  // Bottom hook
  fillRoundedRect(
    buf,
    Math.round(x + w * 0.15),
    Math.round(y + h - t),
    Math.round(w * 0.55),
    Math.round(t),
    Math.round(t * 0.35),
    () => color
  );
}

function build() {
  const buf = pixels();

  // Rounded gradient background tile
  fillRoundedRect(buf, 40, 40, SIZE - 80, SIZE - 80, 200, (u, v) => {
    const c1 = BLUE;
    const c2 = PURPLE;
    return mix(c1, c2, (u + v) / 2);
  });

  // Inner darker panel to hint at a Sudoku board
  const pad = 140;
  fillRoundedRect(buf, pad, pad, SIZE - pad * 2, SIZE - pad * 2, 90, () => [
    18, 18, 46, 255,
  ]);

  // Sudoku grid lines (3x3 major only for icon clarity)
  const gridStart = pad + 20;
  const gridEnd = SIZE - pad - 20;
  const gridSpan = gridEnd - gridStart;
  const thickness = 8;
  const thickColor = [BLUE[0], BLUE[1], BLUE[2], 200];
  for (let i = 1; i < 3; i++) {
    const x = gridStart + (gridSpan / 3) * i;
    drawLine(buf, Math.round(x), gridStart, Math.round(x), gridEnd, thickness, thickColor);
    const y = gridStart + (gridSpan / 3) * i;
    drawLine(buf, gridStart, Math.round(y), gridEnd, Math.round(y), thickness, thickColor);
  }

  // Big golden "9" glyph
  drawGlyphNine(buf, SIZE / 2, SIZE / 2, 520, GOLD);

  return buf;
}

// PNG encoding
function crc32Table() {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) {
      c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    }
    table[n] = c >>> 0;
  }
  return table;
}

const CRC_TABLE = crc32Table();

function crc32(buf) {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < buf.length; i++) {
    c = CRC_TABLE[(c ^ buf[i]) & 0xFF] ^ (c >>> 8);
  }
  return (c ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcInput = Buffer.concat([typeBuf, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcInput), 0);
  return Buffer.concat([len, typeBuf, data, crc]);
}

function encodePng(pixelBuf) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(SIZE, 0);
  ihdr.writeUInt32BE(SIZE, 4);
  ihdr.writeUInt8(8, 8);
  ihdr.writeUInt8(6, 9);
  ihdr.writeUInt8(0, 10);
  ihdr.writeUInt8(0, 11);
  ihdr.writeUInt8(0, 12);

  const rowStride = SIZE * 4;
  const raw = Buffer.alloc((rowStride + 1) * SIZE);
  for (let y = 0; y < SIZE; y++) {
    raw[y * (rowStride + 1)] = 0;
    Buffer.from(pixelBuf.buffer, y * rowStride, rowStride).copy(raw, y * (rowStride + 1) + 1);
  }
  const idatData = zlib.deflateSync(raw);
  const idat = chunk('IDAT', idatData);
  const iend = chunk('IEND', Buffer.alloc(0));
  const ihdrChunk = chunk('IHDR', ihdr);
  return Buffer.concat([signature, ihdrChunk, idat, iend]);
}

const outDir = path.resolve(__dirname, '..', 'assets', 'icon');
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, 'icon.png');
const pixelBuf = build();
fs.writeFileSync(outPath, encodePng(pixelBuf));
console.log(`Wrote ${outPath} (${SIZE}x${SIZE})`);
