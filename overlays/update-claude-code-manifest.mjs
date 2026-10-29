// Replaces claude-code-manifest.zst.json with the release manifest for the
// given version. Renovate runs it after bumping the manifest's "version", since
// the checksums have to come from the release itself.
//
//   node overlays/update-claude-code-manifest.mjs 2.1.308
import { writeFile } from "node:fs/promises";

const version = process.argv[2];
if (!/^\d+\.\d+\.\d+$/.test(version ?? "")) {
	console.error(`usage: update-claude-code-manifest.mjs <version>`);
	process.exit(2);
}

const url = `https://downloads.claude.ai/claude-code-releases/${version}/manifest.zst.json`;
const res = await fetch(url);
if (!res.ok) {
	console.error(`${url}: ${res.status} ${res.statusText}`);
	process.exit(1);
}

const manifest = await res.json();
if (manifest.version !== version) {
	console.error(`${url} describes ${manifest.version}, not ${version}`);
	process.exit(1);
}

await writeFile(
	new URL("./claude-code-manifest.zst.json", import.meta.url),
	JSON.stringify(manifest, null, 2) + "\n",
);
