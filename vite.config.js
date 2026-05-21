import { defineConfig } from 'vite';

// Single-page landing — no React, no multi-page rollup config needed.
// When other pages get added later, list them under build.rollupOptions.input.
export default defineConfig({
  base: './',
});
