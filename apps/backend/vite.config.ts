import { defineConfig } from "vite";

export default defineConfig({
  build: {
    lib: {
      entry: "src/index.ts",
      formats: ["es"],
      fileName: "index",
    },
    rollupOptions: {
      external: [/^node:.*/],
    },
    ssr: true,
    target: "node20",
    outDir: "dist",
  },
});
