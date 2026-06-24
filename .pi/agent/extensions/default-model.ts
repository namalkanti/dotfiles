import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";

const DEFAULT_PROVIDER = "ollama";
const DEFAULT_MODEL = "gemma4:12b-mlx";

export default function (pi: ExtensionAPI) {
   // Resolve settings.json relative to this extension file
  const settingsPath = join(dirname(import.meta.filename), "..", "settings.json");

  pi.on("session_start", async (_event, ctx) => {
    const model = ctx.modelRegistry.find(DEFAULT_PROVIDER, DEFAULT_MODEL);
    if (!model) return;
    if (ctx.model?.provider === model.provider && ctx.model?.id === model.id) return;
    await pi.setModel(model);
   });

  pi.on("session_shutdown", async () => {
    try {
      const settings = JSON.parse(readFileSync(settingsPath, "utf-8"));
      settings.defaultProvider = DEFAULT_PROVIDER;
      settings.defaultModel = DEFAULT_MODEL;
      writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n");
    } catch {}
   });
}
