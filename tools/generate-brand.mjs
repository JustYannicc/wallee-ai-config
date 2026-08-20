#!/usr/bin/env node

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const SIZE = 64;
const BAYER_4 = [
  [0, 8, 2, 10],
  [12, 4, 14, 6],
  [3, 11, 1, 9],
  [15, 7, 13, 5],
];
const PALETTE = {
  leaf: "#667a3d",
  olive: "#34452b",
  rust: "#b85c38",
  cream: "#e8dfc4",
  charcoal: "#17201c",
  brown: "#8a694d",
};

const grid = Array.from({ length: SIZE }, () => Array(SIZE).fill(null));
const ellipseValue = (x, y, cx, cy, rx, ry) =>
  ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2;
const ellipse = (x, y, cx, cy, rx, ry) => ellipseValue(x, y, cx, cy, rx, ry) <= 1;

function polygon(points, x, y) {
  const px = x + 0.5;
  const py = y + 0.5;
  let inside = false;
  for (let index = 0, previous = points.length - 1;
    index < points.length;
    previous = index, index += 1) {
    const [xi, yi] = points[index];
    const [xj, yj] = points[previous];
    const crosses = (yi > py) !== (yj > py)
      && px < ((xj - xi) * (py - yi)) / (yj - yi) + xi;
    if (crosses) inside = !inside;
  }
  return inside;
}

function paint(color, mask, coverage) {
  for (let y = 0; y < SIZE; y += 1) {
    for (let x = 0; x < SIZE; x += 1) {
      if (!mask(x, y)) continue;
      const requested = typeof coverage === "function" ? coverage(x, y) : coverage;
      const amount = Math.max(0, Math.min(16, Math.round(requested)));
      if (BAYER_4[y % 4][x % 4] < amount) grid[y][x] = color;
    }
  }
}

// A long raised tail is the common tailorbird's strongest silhouette cue.
paint(PALETTE.olive,
  (x, y) => polygon([[18, 45], [19, 8], [27, 10], [31, 43]], x, y),
  (x, y) => 11 + Math.round((y / SIZE) * 3));
paint(PALETTE.leaf,
  (x, y) => polygon([[22, 42], [22, 11], [26, 12], [28, 41]], x, y), 9);

// Plump toy body, kept visibly dithered rather than filled solid.
paint(PALETTE.leaf,
  (x, y) => ellipse(x, y, 31, 42, 17, 16),
  (x, y) => ellipseValue(x, y, 31, 42, 17, 16) > 0.78 ? 10 : 14);
paint(PALETTE.cream,
  (x, y) => ellipse(x, y, 37, 44, 11, 13),
  (x, y) => ellipseValue(x, y, 37, 44, 11, 13) > 0.76 ? 9 : 13);
paint(PALETTE.olive,
  (x, y) => polygon([[16, 36], [29, 31], [38, 40], [29, 51], [16, 47]], x, y), 13);
paint(PALETTE.leaf,
  (x, y) => polygon([[19, 36], [29, 34], [34, 40], [25, 45], [18, 43]], x, y), 8);

// Oversized head, rust crown, pale throat, and glossy eye.
paint(PALETTE.leaf,
  (x, y) => ellipse(x, y, 40, 24, 15, 14),
  (x, y) => ellipseValue(x, y, 40, 24, 15, 14) > 0.78 ? 10 : 14);
paint(PALETTE.rust,
  (x, y) => ellipse(x, y, 40, 24, 15, 14) && y <= 19 + Math.max(0, 43 - x) * 0.08,
  14);
paint(PALETTE.cream,
  (x, y) => ellipse(x, y, 43, 28, 10, 8) && y >= 24, 12);
paint(PALETTE.charcoal, (x, y) => ellipse(x, y, 47, 23, 3.2, 3.2), 16);
paint(PALETTE.cream, (x, y) => ellipse(x, y, 46, 22, 1.1, 1.1), 16);

// Fine straight bill and simple passerine feet.
paint(PALETTE.charcoal,
  (x, y) => polygon([[53, 23], [63, 25], [53, 27]], x, y), 15);
paint(PALETTE.brown,
  (x, y) => (x >= 25 && x <= 27 && y >= 54 && y <= 59)
    || (x >= 36 && x <= 38 && y >= 54 && y <= 59), 12);
paint(PALETTE.brown,
  (x, y) => polygon([[20, 59], [28, 57], [32, 60], [20, 61]], x, y)
    || polygon([[33, 59], [39, 57], [45, 60], [33, 61]], x, y), 12);

const cellsByColor = new Map(Object.values(PALETTE).map((color) => [color, []]));
for (let y = 0; y < SIZE; y += 1) {
  for (let x = 0; x < SIZE; x += 1) {
    const color = grid[y][x];
    if (color) cellsByColor.get(color).push({ x, y });
  }
}

const birdPaths = [...cellsByColor.entries()]
  .filter(([, cells]) => cells.length > 0)
  .map(([color, cells]) => {
    const path = cells.map(({ x, y }) => `M${x} ${y}h1v1h-1z`).join("");
    return `  <path fill="${color}" d="${path}" />`;
  })
  .join("\n");

const birdSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${SIZE} ${SIZE}" role="img" aria-labelledby="title description" shape-rendering="crispEdges">
  <title id="title">Tailorbird dither mark</title>
  <desc id="description">A transparent toy-like common tailorbird with a rust crown, green back, pale underside, and long upright tail, rendered entirely from ordered-dither cells.</desc>
${birdPaths}
</svg>
`;

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const wordmarkPath = resolve(projectRoot, "assets/wallee-ai-config-wordmark.txt");
const rawWordmarkRows = readFileSync(wordmarkPath, "utf8").replace(/\n+$/, "").split("\n");
const wordmarkColumns = Math.max(...rawWordmarkRows.map((row) => [...row].length));
const wordmarkRows = rawWordmarkRows.map((row) => row.padEnd(wordmarkColumns));
if (wordmarkRows.length !== 6 || wordmarkRows.some((row) => row.length === 0)
  || wordmarkRows.some((row) => [...row].length !== wordmarkColumns)) {
  throw new Error("The ANSI Shadow wordmark must contain exactly six nonempty rows.");
}
const fontSize = 11;
const rowHeight = 13;
const wordmarkWidth = Math.ceil(wordmarkColumns * 6.7 + 24);
const wordmarkHeight = wordmarkRows.length * rowHeight + 18;
const rowColors = ["#b85c38", "#a9633b", "#8e6c3e", "#727641", "#567b40", "#34452b"];
const escapedRows = wordmarkRows.map((row) => row.replaceAll("&", "&amp;").replaceAll("<", "&lt;"));
const wordmarkText = escapedRows.map((row, index) =>
  `  <text x="12" y="${16 + index * rowHeight}" fill="${rowColors[index]}">${row}</text>`).join("\n");
const wordmarkSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${wordmarkWidth}" height="${wordmarkHeight}" viewBox="0 0 ${wordmarkWidth} ${wordmarkHeight}" role="img" aria-labelledby="title description" xml:space="preserve">
  <title id="title">Wallee AI Config</title>
  <desc id="description">Wallee AI Config rendered as a six-line ANSI Shadow wordmark.</desc>
  <style>text { font-family: Menlo, Monaco, Consolas, monospace; font-size: ${fontSize}px; font-weight: 700; font-variant-ligatures: none; }</style>
${wordmarkText}
</svg>
`;

const outputs = [
  [resolve(projectRoot, "assets/tailorbird-mark.svg"), birdSvg],
  [resolve(projectRoot, "assets/wallee-ai-config-wordmark.svg"), wordmarkSvg],
];

if (process.argv.includes("--check")) {
  for (const [path, expected] of outputs) {
    if (readFileSync(path, "utf8") !== expected) {
      throw new Error(`Generated asset is stale: ${path}`);
    }
  }
  console.log("Generated brand assets are up to date.");
} else {
  for (const [path, value] of outputs) {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, value);
  }
  console.log(`Generated ${outputs.map(([path]) => path).join(" and ")}`);
}
