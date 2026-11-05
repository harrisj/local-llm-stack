import {
  type ClassifierApi,
  type ClassifierModel,
  createProvider,
} from "@earendil-works/pi-ai";
import { builtinProviders } from "@earendil-works/pi-ai/providers/all";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const classifier = (
  provider: string,
  id: string,
  name: string,
  api: ClassifierApi,
  baseUrl: string,
  inputCost: number,
): ClassifierModel<ClassifierApi> => ({
  type: "classifier",
  provider,
  id,
  name,
  api,
  baseUrl,
  input: ["text"],
  contextWindow: 4096,
  cost: { input: inputCost, output: 0, cacheRead: 0, cacheWrite: 0 },
});

export default (pi: ExtensionAPI): void => {
  const providers = builtinProviders();
  const typesafe = providers.find((p) => p.id === "typesafe");
  const cloudflare = providers.find((p) => p.id === "cloudflare-workers-ai");

  if (!typesafe?.classify || !cloudflare?.classify) {
    throw new Error("Classifier catalog requires Pi 1.3+ built-in classifiers");
  }

  // 1. Clean, explicit configuration using pure framework properties
  pi.registerProvider(
    createProvider({
      id: "inference",
      name: "Inference Cooperative",
      auth: {
        apiKey: {
          name: "Inference Coop Token",
          resolve: async ({ credential }) => ({
            auth: {
              apiKey:
                credential?.key ||
                process.env.INFERENCE_COOP_API_KEY ||
                "anonymous",
            },
            source: credential ? "configured key" : "environment",
          }),
        },
      },
      models: [
        classifier(
          "inference",
          "metis",
          "Metis (Inference Coop)",
          "typesafe-system-one",
          "https://gateway.inference.coop/v1", // 🟢 The fix: Trailing slash tells the driver exactly where the root host ends
          0.015,
        ),
      ],
      classifiers: {
        "typesafe-system-one": {
          // Re-use the native compiled execution client block completely
          classify: typesafe.classify.bind(typesafe),
        },
      },
    }),
  );

  pi.registerProvider(typesafe);
  pi.registerProvider(cloudflare);
};
