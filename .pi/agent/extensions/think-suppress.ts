import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEEPSEEK_V4_MODEL = /^~?deepseek\/deepseek-v4-/;

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    const model = ctx.model;
    if (!model) return;

    if (
      model.provider === "ollama" &&
      (model.id.startsWith("qwen") || model.id.startsWith("gemma"))
    ) {
      return { ...event.payload, reasoning_effort: "none" };
    }

    if (
      model.provider === "openrouter" &&
      DEEPSEEK_V4_MODEL.test(model.id) &&
      ctx.thinkingLevel === "low"
    ) {
      return {
        ...event.payload,
        reasoning: { ...event.payload.reasoning, effort: "none" },
      };
    }
  });
}
