const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

function parseViewBox(svgText) {
  const m = svgText.match(/viewBox\s*=\s*"\s*([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s*"/i);
  if (!m) return null;
  return {
    minX: Number(m[1]),
    minY: Number(m[2]),
    width: Number(m[3]),
    height: Number(m[4]),
  };
}

function usageAndExit() {
  console.error('Usage: node tools/svg_to_png_puppeteer.cjs <input.svg> <output.png> [scale]');
  console.error('Example: node tools/svg_to_png_puppeteer.cjs ../assets/images/report/veritabani_erd.svg ../assets/images/report/veritabani_erd.png 2');
  process.exit(2);
}

(async () => {
  const [, , inputArg, outputArg, scaleArg] = process.argv;
  if (!inputArg || !outputArg) usageAndExit();

  const inputPath = path.resolve(process.cwd(), inputArg);
  const outputPath = path.resolve(process.cwd(), outputArg);
  const scale = scaleArg ? Number(scaleArg) : 2;

  if (!Number.isFinite(scale) || scale <= 0) {
    console.error('scale must be a positive number');
    process.exit(2);
  }

  const svgText = fs.readFileSync(inputPath, 'utf8');
  const vb = parseViewBox(svgText) || { minX: 0, minY: 0, width: 2000, height: 1200 };

  // Guard against absurd viewBox sizes.
  const width = Math.min(Math.ceil(vb.width), 12000);
  const height = Math.min(Math.ceil(vb.height), 12000);

  const html = `<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <style>
    html, body { margin: 0; padding: 0; background: white; }
    #root { width: ${width}px; height: ${height}px; overflow: hidden; }
    svg { display: block; }
  </style>
</head>
<body>
  <div id="root"></div>
  <script>
    const root = document.getElementById('root');
    root.innerHTML = ${JSON.stringify(svgText)};
    const svg = root.querySelector('svg');
    if (svg) {
      // Ensure a fixed size so screenshot matches viewBox.
      svg.setAttribute('width', String(${width}));
      svg.setAttribute('height', String(${height}));
      svg.style.maxWidth = 'none';
      svg.style.maxHeight = 'none';
      svg.style.background = 'white';
    }
  </script>
</body>
</html>`;

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width, height, deviceScaleFactor: scale });
    await page.setContent(html, { waitUntil: ['domcontentloaded', 'networkidle0'] });

    // Wait a tick to allow foreignObject layout.
    await new Promise((resolve) => setTimeout(resolve, 250));

    await page.screenshot({
      path: outputPath,
      type: 'png',
      fullPage: false,
      clip: { x: 0, y: 0, width, height },
      omitBackground: false,
    });

    console.log(`Wrote ${outputPath}`);
  } finally {
    await browser.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
