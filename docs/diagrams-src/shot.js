const { chromium } = require('/opt/node-tools/node_modules/playwright');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1600, height: 1000 }, deviceScaleFactor: 2 });
  for (const f of process.argv.slice(2)) {
    await p.goto('file://' + process.cwd() + '/' + f + '.html');
    await p.waitForTimeout(300);
    const h = await p.evaluate(() => document.body.scrollHeight);
    await p.setViewportSize({ width: 1600, height: h });
    await p.screenshot({ path: f + '.png', fullPage: true });
  }
  await b.close();
})();
