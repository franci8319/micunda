// Genera icon-192.png e icon-512.png sin dependencias externas
const zlib = require('zlib');
const fs   = require('fs');
const path = require('path');

function crc32(buf) {
  let crc = 0xFFFFFFFF;
  for (const b of buf) {
    crc ^= b;
    for (let i = 0; i < 8; i++) crc = (crc >>> 1) ^ (crc & 1 ? 0xEDB88320 : 0);
  }
  return (crc ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const t = Buffer.from(type, 'ascii');
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const crcInput = Buffer.concat([t, data]);
  const crcBuf   = Buffer.alloc(4); crcBuf.writeUInt32BE(crc32(crcInput));
  return Buffer.concat([len, crcInput, crcBuf]);
}

function roundedRectPNG(size, bg, radius) {
  const [br, bg_, bb] = bg;
  const rowLen = 1 + size * 4; // filter byte + RGBA per pixel
  const raw = Buffer.alloc(size * rowLen, 0);

  for (let y = 0; y < size; y++) {
    raw[y * rowLen] = 0; // filter: None
    for (let x = 0; x < size; x++) {
      const i = y * rowLen + 1 + x * 4;
      // is point inside rounded rect?
      const cx = Math.min(x, size - 1 - x);
      const cy = Math.min(y, size - 1 - y);
      let inside = true;
      if (cx < radius && cy < radius) {
        const dx = radius - cx - 0.5;
        const dy = radius - cy - 0.5;
        inside = (dx * dx + dy * dy) <= (radius * radius);
      }
      if (inside) {
        raw[i]   = br;
        raw[i+1] = bg_;
        raw[i+2] = bb;
        raw[i+3] = 255;
      }
      // else transparent (0,0,0,0)
    }
  }

  // Draw simple car silhouette in white
  drawCar(raw, size, rowLen);

  const idat = zlib.deflateSync(raw, { level: 9 });
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8]  = 8; // bit depth
  ihdr[9]  = 6; // RGBA
  ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0))
  ]);
}

function setPixel(raw, size, rowLen, x, y, r, g, b) {
  if (x < 0 || y < 0 || x >= size || y >= size) return;
  const i = y * rowLen + 1 + x * 4;
  raw[i]   = r; raw[i+1] = g; raw[i+2] = b; raw[i+3] = 255;
}

function fillRect(raw, size, rowLen, x1, y1, w, h, r, g, b) {
  for (let dy = 0; dy < h; dy++)
    for (let dx = 0; dx < w; dx++)
      setPixel(raw, size, rowLen, x1 + dx, y1 + dy, r, g, b);
}

function drawCar(raw, size, rowLen) {
  const s = size / 192; // scale factor
  const W = 255, G = 255, B = 255;

  // Body bottom (wide rectangle)
  const bx = Math.round(28 * s), by = Math.round(110 * s);
  const bw = Math.round(136 * s), bh = Math.round(36 * s);
  fillRect(raw, size, rowLen, bx, by, bw, bh, W, G, B);

  // Cabin (narrower, on top)
  const cx = Math.round(52 * s), cy = Math.round(78 * s);
  const cw = Math.round(88 * s), ch = Math.round(34 * s);
  fillRect(raw, size, rowLen, cx, cy, cw, ch, W, G, B);

  // Left wheel
  drawCircle(raw, size, rowLen, Math.round(60 * s), Math.round(150 * s), Math.round(18 * s), W, G, B);
  // Right wheel
  drawCircle(raw, size, rowLen, Math.round(132 * s), Math.round(150 * s), Math.round(18 * s), W, G, B);
}

function drawCircle(raw, size, rowLen, cx, cy, r, rr, gg, bb) {
  for (let dy = -r; dy <= r; dy++)
    for (let dx = -r; dx <= r; dx++)
      if (dx * dx + dy * dy <= r * r)
        setPixel(raw, size, rowLen, cx + dx, cy + dy, rr, gg, bb);
}

const outDir = path.join(__dirname, '..', 'icons');
fs.mkdirSync(outDir, { recursive: true });

const blue = [26, 74, 138];
fs.writeFileSync(path.join(outDir, 'icon-192.png'), roundedRectPNG(192, blue, 42));
fs.writeFileSync(path.join(outDir, 'icon-512.png'), roundedRectPNG(512, blue, 112));
console.log('Iconos generados: icons/icon-192.png e icons/icon-512.png');
