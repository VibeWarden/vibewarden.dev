# vibewarden.dev — Website Project

## What this is

The public website for VibeWarden at https://vibewarden.dev.
Serves the landing page, product documentation, blog, install scripts, and JSON schemas.

## Related repo

The product source code is at https://github.com/vibewarden/vibewarden.
Documentation source (Markdown) lives in that repo under `docs/`.
The docs are built with MkDocs Material and deployed here under `/docs/`.

## Brand

- **Name:** VibeWarden
- **Text mark:** \V/
- **Tagline:** Security sidecar for vibe-coded apps.
- **Slogan:** You vibe, we warden. Security is no longer your burden.
- **Colors:** Purple #7C3AED → Cyan #06B6D4
- **Logo:** `static/logo.png` (mark), `static/logo-text.png` (with wordmark)

## Structure

```
index.html          # Landing page
docs/               # MkDocs Material output (deployed from main repo)
blog/               # Blog posts
static/             # Assets (logo, images, install scripts)
schema/v1/          # Published JSON schemas
llms.txt            # AI-readable site summary
llms-full.txt       # Complete AI-readable setup guide
CNAME               # Custom domain: vibewarden.dev
```

## Deployment

GitHub Pages from the `main` branch. Push to main = live.

## Tech decisions

- **No framework** for the landing page — plain HTML/CSS/JS. Fast, no build step.
- **MkDocs Material** for docs (built in the vibewarden repo, output copied here).
- **Blog:** Static HTML or a lightweight generator (TBD).

## Style rules

- Mobile-first responsive design
- Dark mode support (prefers-color-scheme)
- Brand colors only — no random palette
- System fonts (no web font loading)
- Minimal JavaScript — the site should work without JS
- Accessible (WCAG AA minimum)
- Fast (< 1s FCP, < 100KB total page weight for landing)
