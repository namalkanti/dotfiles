/**
 * Jev Decision Tool Extension
 *
 * Exposes TypeSafe Jev 1.13 via OpenRouter Decisions API (`/api/alpha/decisions`).
 * Provides fast, calibrated probabilities and structured choices (noul, choice, score).
 */

import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const OPENROUTER_DECISIONS_URL = "https://openrouter.ai/api/alpha/decisions";
const JEV_MODEL = "typesafe/jev-1.13";

const JevDecideParams = Type.Object({
	state: Type.Union([Type.String(), Type.Record(Type.String(), Type.Unknown())], {
		description: "The context, code, prompt, or object state to evaluate.",
	}),
	question: Type.String({
		description: "The question or instruction to evaluate against state.",
	}),
	type: Type.Optional(
		StringEnum(["choice", "noul", "score"] as const, {
			description: "Question type: 'choice' (pick an option), 'noul' (yes/no boolean), or 'score' (rubric). Defaults to 'choice'.",
		}),
	),
	criteria: Type.Record(Type.String(), Type.String(), {
		description: "Mapping of outcome options/labels to descriptions/criteria.",
	}),
});

interface JevAnswer {
	type: "choice" | "noul" | "score";
	choice?: string;
	noul?: boolean;
	score?: number;
	probabilities?: Record<string, number>;
	confidence?: number;
}

interface JevResponse {
	model?: string;
	answers?: Record<string, JevAnswer>;
	usage?: {
		input_tokens: number;
		output_tokens: number;
		cost: number;
	};
	error?: {
		message: string;
		code?: number;
	};
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "jev_decide",
		label: "Jev Decide",
		description:
			"Submit a fast, calibrated structured decision or classification query to TypeSafe Jev 1.13 via OpenRouter.",
		parameters: JevDecideParams,
		async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
			const apiKey = process.env.OPENROUTER_API_KEY;
			if (!apiKey) {
				throw new Error("OPENROUTER_API_KEY environment variable is not set.");
			}

			const questionType = params.type ?? "choice";
			const questionKey = "decision";

			const payload = {
				model: JEV_MODEL,
				state: params.state,
				questions: {
					[questionKey]: {
						type: questionType,
						instructions: params.question,
						criteria: params.criteria,
					},
				},
			};

			const response = await fetch(OPENROUTER_DECISIONS_URL, {
				method: "POST",
				headers: {
					Authorization: `Bearer ${apiKey}`,
					"Content-Type": "application/json",
				},
				body: JSON.stringify(payload),
				signal,
			});

			if (!response.ok) {
				const errorText = await response.text();
				throw new Error(`OpenRouter Decisions API error (${response.status}): ${errorText}`);
			}

			const data = (await response.json()) as JevResponse;
			if (data.error) {
				throw new Error(`Jev error: ${data.error.message}`);
			}

			const answer = data.answers?.[questionKey];
			if (!answer) {
				throw new Error("Jev did not return an answer for the question.");
			}

			const formattedOutput = {
				decision: answer.choice ?? answer.noul ?? answer.score,
				type: answer.type,
				confidence: answer.confidence,
				probabilities: answer.probabilities,
				usage: data.usage,
			};

			return {
				content: [
					{
						type: "text",
						text: JSON.stringify(formattedOutput, null, 2),
					},
				],
				details: formattedOutput,
			};
		},
	});
}
