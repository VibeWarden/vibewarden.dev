# vibewarden.dev

Source for the VibeWarden website at <https://vibewarden.dev>.
Eleventy (11ty) build, deployed to GitHub Pages on every push to `main`.

## Structure

```
src/                # Eleventy source (.njk templates) — authoritative
docs/               # MkDocs output, passthrough-copied under /docs/
static/             # Assets (logo, images, fonts)
schema/v1/          # Published JSON schemas (event.json, config.json)
install.sh          # curl | sh install script (passthrough)
install.ps1         # PowerShell install script (passthrough)
llms.txt            # AI-readable site summary (passthrough)
llms-full.txt       # Complete AI-readable setup guide (passthrough)
sitemap.xml         # Sitemap (passthrough)
eleventy.config.ts  # Build config
```

Only files under `src/` and those listed in `eleventyConfig.addPassthroughCopy(...)` reach production. Anything else at the repo root is an orphan and will not be deployed.

## Local development

The `/start/` page uses prompt templates fetched at build time from the main
repo's latest release. These files are `.gitignore`'d. Fetch them before serving:

```bash
npm run prepare  # downloads src/_data/agent-kickoff-{dev,deploy}.txt
npm install
npm run serve    # http://localhost:8080/ with hot reload
```

`npm run prepare` can be re-run any time to refresh the templates to the latest
release. Without it, the build still completes but the `/start/` page emits an
obvious error placeholder instead of a real prompt.

## Build

```bash
npm run prepare  # fetch kickoff artifacts (required)
npm run build    # Outputs to ./dist/
```

## Deployment

GitHub Pages via `.github/workflows/deploy.yml` — `dist/` is uploaded as the Pages artifact on every push to `main`. Custom domain configured via `CNAME`.
