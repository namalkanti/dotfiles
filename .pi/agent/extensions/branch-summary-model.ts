/**
 * Branch Summary Model Extension
 *
 * Uses a fixed cheaper model for /tree branch summarization instead of the
 * active session model. Compaction is intentionally untouched — it runs on
 * whatever model is active in the session.
 */

import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";

const SUMMARY_PROVIDER = "anthropic";
const SUMMARY_MODEL = "claude-haiku-4-5";

const PREAMBLE = `The user explored a different conversation branch before returning here.\nSummary of that exploration:\n\n`;

const PROMPT = `Create a structured summary of this conversation branch for context when returning later.

Use this EXACT format:

## Goal
[What was the user trying to accomplish in this branch?]

## Constraints & Preferences
- [Any constraints, preferences, or requirements mentioned]
- [Or "(none)" if none were mentioned]

## Progress
### Done
- [x] [Completed tasks/changes]

### In Progress
- [ ] [Work that was started but not finished]

### Blocked
- [Issues preventing progress, if any]

## Key Decisions
- **[Decision]**: [Brief rationale]

## Next Steps
1. [What should happen next to continue this work]

Keep each section concise. Preserve exact file paths, function names, and error messages.`;

export default function (pi: ExtensionAPI) {
	pi.on("session_before_tree", async (event, ctx) => {
		const { preparation, signal } = event;

		if (!preparation.userWantsSummary || preparation.entriesToSummarize.length === 0) return;

		const model = ctx.modelRegistry.find(SUMMARY_PROVIDER, SUMMARY_MODEL);
		if (!model) {
			ctx.ui.notify(`Branch summary: ${SUMMARY_MODEL} not found, using session model`, "warning");
			return;
		}

		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok || !auth.apiKey) {
			ctx.ui.notify(`Branch summary: auth failed for ${SUMMARY_MODEL}, using session model`, "warning");
			return;
		}

		// Extract conversation messages from session entries, skipping tool results
		// (they stay with their tool call and aren't needed for summarization)
		const messages = preparation.entriesToSummarize
			.filter((e): e is typeof e & { type: "message" } => e.type === "message")
			.filter((e) => e.message.role !== "toolResult")
			.map((e) => e.message);

		if (messages.length === 0) return;

		const conversationText = serializeConversation(convertToLlm(messages));

		const summaryMessages = [
			{
				role: "user" as const,
				content: [
					{
						type: "text" as const,
						text: `<conversation>\n${conversationText}\n</conversation>\n\n${PROMPT}`,
					},
				],
				timestamp: Date.now(),
			},
		];

		ctx.ui.notify(`Branch summary: using ${model.id}`, "info");

		try {
			const response = await complete(
				model,
				{ messages: summaryMessages },
				{ apiKey: auth.apiKey, headers: auth.headers, env: auth.env, maxTokens: 2048, signal },
			);

			const text = response.content
				.filter((c): c is { type: "text"; text: string } => c.type === "text")
				.map((c) => c.text)
				.join("\n");

			if (!text.trim()) return;

			return { summary: { summary: PREAMBLE + text } };
		} catch {
			return;
		}
	});
}
