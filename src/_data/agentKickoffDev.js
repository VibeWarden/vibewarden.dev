import { readFileSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

// Resolve path relative to this file, not the cwd.
const __dirname = dirname(fileURLToPath(import.meta.url));
const artifactPath = resolve(__dirname, "agent-kickoff-dev.txt");

/**
 * Eleventy global data: the body of the agent-kickoff-dev artifact.
 *
 * Returns the prompt body — everything after the `# -----` divider line.
 * If the artifact file is missing (local dev before `npm run prepare`),
 * returns a placeholder string that makes the gap obvious.
 */
export default function () {
  let raw;
  try {
    raw = readFileSync(artifactPath, "utf8");
  } catch {
    return "# ERROR: artifact not fetched. Run `npm run prepare` first.\n# Expected: src/_data/agent-kickoff-dev.txt";
  }

  // Split on the divider line (at least 20 dashes after "# ")
  const dividerIndex = raw.search(/^# -{20,}/m);
  if (dividerIndex === -1) {
    return raw;
  }

  // Find the newline after the divider line, then skip one blank line
  const afterDivider = raw.slice(dividerIndex);
  const newlinePos = afterDivider.indexOf("\n");
  return afterDivider.slice(newlinePos + 1);
}
