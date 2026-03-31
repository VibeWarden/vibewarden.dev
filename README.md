# vibewarden.dev

Source for the VibeWarden website, hosted via GitHub Pages.

## Structure

```
docs/           # Product documentation (mirrors/extends repo docs)
blog/           # Blog posts (security guides, comparisons, changelogs)
static/         # Assets (logo, images, install script)
schema/v1/      # Published JSON schemas (event.json, config.json)
llms.txt        # AI-readable site summary
llms-full.txt   # Complete AI-readable setup guide
index.html      # Landing page
```

## Local development

```bash
# If using a static site generator (TBD):
npm run dev

# Or just open index.html for now
```

## Deployment

GitHub Pages from the `main` branch. Custom domain: `vibewarden.dev`.
