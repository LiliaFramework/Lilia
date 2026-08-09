import { rm } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { build } from 'vite';

const sourceDir = path.dirname(fileURLToPath(new URL('../package.json', import.meta.url)));
const outputDir = path.resolve(sourceDir, '..');

await rm(path.join(outputDir, 'assets'), { recursive: true, force: true });
await rm(path.join(outputDir, 'index.html'), { force: true });

await build({
  configFile: path.join(sourceDir, 'vite.config.ts'),
  root: sourceDir,
  base: './',
  build: {
    outDir: outputDir,
    emptyOutDir: false,
  },
});
