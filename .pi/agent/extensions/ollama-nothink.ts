import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    const model = ctx.model?.id ?? "";
    if (!model.startsWith("qwen") && !model.startsWith("gemma")) return;

    return { ...event.payload, reasoning_effort: "none" };
  });
}
