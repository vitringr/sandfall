import { defineConfig } from "vite";
import solid from "vite-plugin-solid";
import glsl from "vite-plugin-glsl";

export default defineConfig({
  plugins: [solid(), glsl()],
});
