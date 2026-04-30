import type { UserConfig } from "@11ty/eleventy";

export default function (eleventyConfig: UserConfig) {
  // Filter: safely embed a string as a JSON literal inside a <script> tag.
  // Usage in nunjucks: {{ someString | jsonStringify | safe }}
  eleventyConfig.addFilter("jsonStringify", (value: unknown) =>
    JSON.stringify(value)
  );

  // Passthrough copies — files outside src/ that go to dist/ as-is
  eleventyConfig.addPassthroughCopy({ "static": "static" });
  eleventyConfig.addPassthroughCopy({ "docs": "docs" });
  eleventyConfig.addPassthroughCopy({ "schema": "schema" });
  eleventyConfig.addPassthroughCopy({ "CNAME": "CNAME" });
  eleventyConfig.addPassthroughCopy({ "robots.txt": "robots.txt" });
  eleventyConfig.addPassthroughCopy({ "sitemap.xml": "sitemap.xml" });
  eleventyConfig.addPassthroughCopy({ "llms.txt": "llms.txt" });
  eleventyConfig.addPassthroughCopy({ "llms-full.txt": "llms-full.txt" });
  eleventyConfig.addPassthroughCopy({ ".nojekyll": ".nojekyll" });
  eleventyConfig.addPassthroughCopy({ "install.sh": "install.sh" });
  eleventyConfig.addPassthroughCopy({ "install.ps1": "install.ps1" });

  // Watch the shared stylesheet for dev server reload
  eleventyConfig.addWatchTarget("static/styles.css");
}

export const config = {
  dir: {
    input: "src",
    output: "dist",
    includes: "_includes",
    data: "_data",
  },
  templateFormats: ["njk"],
  htmlTemplateEngine: "njk",
};
