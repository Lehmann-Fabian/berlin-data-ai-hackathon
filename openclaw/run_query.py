// index.ts
import { definePluginEntry } from "openclaw/plugin-sdk/plugin-entry";
import { Type } from "@sinclair/typebox";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export default definePluginEntry({
  id: "movie-tools",
  name: "Movie Tools",
  description: "Movie-related lookup tool + CLI",
  register(api) {
    api.registerTool(
      {
        name: "movie_lookup",
        description: "Run predefined movie queries and return structured results",
        parameters: Type.Object({
          intent: Type.Union([
            Type.Literal("streaming"),
            Type.Literal("rating"),
            Type.Literal("showtimes"),
          ]),
          title: Type.String(),
          location: Type.Optional(Type.String()),
        }),
        async execute(_id, params) {
          // Keep the deterministic logic here, not in the prompt.
          let query: string;

          switch (params.intent) {
            case "streaming":
              query = `streaming availability for ${params.title}`;
              break;
            case "rating":
              query = `ratings for ${params.title}`;
              break;
            case "showtimes":
              query = `showtimes for ${params.title} in ${params.location ?? "current location"}`;
              break;
          }

          // Example: call your own CLI
          const { stdout } = await execFileAsync("my-movie-cli", ["query", query], {
            env: process.env,
          });

          return {
            content: [
              {
                type: "text",
                text: stdout.trim(),
              },
            ],
          };
        },
      },
      { optional: true },
    );

    api.registerCli((cli) => {
      cli
        .command("movie <intent> <title>")
        .option("--location <location>")
        .action(async (intent, title, opts) => {
          console.log({ intent, title, location: opts.location });
        });
    });
  },
});