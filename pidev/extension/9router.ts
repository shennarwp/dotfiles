/**
 * 9router provider extension for pi.
 *
 * Registers a `9router` provider that discovers its model list from the
 * gateway's OpenAI-compatible `/v1/models` endpoint instead of a static
 * models.json. Worth it because the gateway's catalog is not static: it is
 * whatever accounts are configured on that box, and it carries per-model
 * metadata (vision, reasoning, context window, output limit) that a
 * hand-written models.json entry cannot keep in sync.
 *
 * The `oc-free/*` models are NOT in /v1/models, so they stay in models.json
 * (see ../models.json). This provider only covers `9router`.
 *
 * Endpoint and key come from the environment:
 *   NINEROUTER_URL   e.g. http://9router.m9.home.arpa   (per-host, see repo/dotfiles/)
 *   NINEROUTER_KEY   dashboard -> Keys; falls back to /login 9router
 *
 * Try it without installing:
 *   pi -e ./pidev/extension/9router.ts
 */

import {
	type Credential,
	createProvider,
	envApiKeyAuth,
	type Model,
	type ProviderModel,
	type RefreshModelsContext,
} from "@earendil-works/pi-ai";
// The streaming implementations live on the compat entrypoint; see
// examples/extensions/custom-provider-gitlab-duo in the pi repo.
import { openAICompletionsApi } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "9router";
const PROVIDER_NAME = "9Router";

/** Fallbacks for when NINEROUTER_URL is unset or the catalog omits a field. */
const DEFAULT_BASE_URL = "http://127.0.0.1:8080";
const DEFAULT_CONTEXT_WINDOW = 128_000;
const DEFAULT_MAX_TOKENS = 16_384;

interface GatewayModel {
	id: string;
	context_length?: number;
	max_completion_tokens?: number;
	capabilities?: {
		vision?: boolean;
		reasoning?: boolean;
		imageInput?: boolean;
	};
}

function baseUrl(): string {
	// Read at call time, not module load: the extension factory may run before
	// the shell has finished exporting the per-host value.
	const configured = process.env.NINEROUTER_URL?.trim();
	return (configured || DEFAULT_BASE_URL).replace(/\/+$/, "");
}

function toModel(entry: GatewayModel): Model<"openai-completions"> {
	const capabilities = entry.capabilities ?? {};
	const vision = Boolean(capabilities.vision || capabilities.imageInput);
	const contextWindow = entry.context_length;
	const maxTokens = entry.max_completion_tokens;
	return {
		id: entry.id,
		name: entry.id,
		api: "openai-completions",
		provider: PROVIDER_ID,
		baseUrl: `${baseUrl()}/v1`,
		input: vision ? ["text", "image"] : ["text"],
		// Pricing is not published by the gateway; report tokens at no cost
		// rather than inventing numbers that would skew /session totals.
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		reasoning: Boolean(capabilities.reasoning),
		contextWindow:
			typeof contextWindow === "number" && contextWindow > 0 ? contextWindow : DEFAULT_CONTEXT_WINDOW,
		maxTokens: typeof maxTokens === "number" && maxTokens > 0 ? maxTokens : DEFAULT_MAX_TOKENS,
	};
}

/** Fetch the gateway catalog. createProvider retains the previous list on throw. */
async function fetchModels(context: RefreshModelsContext): Promise<readonly ProviderModel<"openai-completions">[]> {
	if (!context.allowNetwork) return [];

	const credential = context.credential;
	const key = credential?.type === "api_key" ? credential.key : undefined;
	const headers: Record<string, string> = {};
	if (key) headers.Authorization = `Bearer ${key}`;

	const response = await fetch(`${baseUrl()}/v1/models`, {
		headers,
		signal: context.signal,
	});
	if (!response.ok) {
		throw new Error(`9router catalog fetch failed: ${response.status} ${response.statusText}`);
	}

	const payload = (await response.json()) as { data?: GatewayModel[] };
	const entries = Array.isArray(payload.data) ? payload.data : [];
	const models = entries.filter((entry) => typeof entry?.id === "string").map(toModel);
	if (models.length === 0) {
		throw new Error("9router returned an empty model list");
	}
	return models;
}

export default function (pi: ExtensionAPI) {
	pi.registerProvider(
		createProvider({
			id: PROVIDER_ID,
			name: PROVIDER_NAME,
			baseUrl: `${baseUrl()}/v1`,
			auth: {
				apiKey: envApiKeyAuth("9router API key", ["NINEROUTER_KEY"]),
			},
			// No static baseline: the gateway catalog is authoritative and the
			// previous list is kept when a refresh fails.
			models: [],
			fetchModels,
			api: openAICompletionsApi(),
		}),
	);
}
