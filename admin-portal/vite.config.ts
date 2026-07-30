import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig(({ mode }) => {
  const isServer = mode === "server";
  const targetUrl = isServer ? "https://app.cipl.me" : "http://localhost:8090";

  return {
    plugins: [react(), tailwindcss()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    server: {
      proxy: {
        "/api": {
          target: targetUrl,
          changeOrigin: true,
          secure: isServer,
        },
        "/_": {
          target: targetUrl,
          changeOrigin: true,
          secure: isServer,
        },
      },
    },
    build: {
      outDir: "../backend/pb_public",
      emptyOutDir: true,
    },
  };
});
