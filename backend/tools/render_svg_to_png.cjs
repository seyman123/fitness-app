const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

function usageAndExit() {
  console.error('Usage: node tools/render_svg_to_png.cjs <input.svg> <output.png> [widthPx]');
  process.exit(2);
}

const [, , inputArg, outputArg, widthArg] = process.argv;
if (!inputArg || !outputArg) usageAndExit();

const inputPath = path.resolve(process.cwd(), inputArg);
const outputPath = path.resolve(process.cwd(), outputArg);
const widthPx = widthArg ? Number(widthArg) : 2400;

if (!Number.isFinite(widthPx) || widthPx <= 0) {
  console.error('widthPx must be a positive number');
  process.exit(2);
}

const svg = fs.readFileSync(inputPath, 'utf8');

const resvg = new Resvg(svg, {
  fitTo: {
    mode: 'width',
    value: widthPx,
  },
  background: 'white',
});

const rendered = resvg.render();
const pngData = rendered.asPng();

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, pngData);

console.log(`Wrote ${outputPath}`);
