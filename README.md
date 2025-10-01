[![Netlify Status](https://api.netlify.com/api/v1/badges/be21e0f3-c745-4d90-9920-0b86b1043074/deploy-status)](https://app.netlify.com/projects/sbom-insights/deploys)

# SBOM Insights - Contributor Guide

Welcome to SBOM Insights! This guide will help you contribute to our blog about Software Bill of Materials (SBOM), supply chain security, and related topics.

## Quick Start: Add and Test a Blog Post

Want to quickly add a blog post? Follow these steps:

```bash
# 1. Clone the repository
git clone https://github.com/interlynk-io/sbom-insights.git
cd sbom-insights

# 2. Create a new post (replace with your title)
make new-post TITLE="My SBOM Journey"

# 3. Edit your post
# Open content/posts/my-sbom-journey.md in your editor
# Add your content after the front matter

# 4. Test your post locally
make serve
# Open http://localhost:1313 in your browser

# 5. When ready, build the site
make build

# 6. Create a PR with your changes
git checkout -b post/my-sbom-journey
git add .
git commit -m "Add post: My SBOM Journey"
git push origin post/my-sbom-journey
```

That's it! Your post will be reviewed and published. For more details, see the sections below.

## Table of Contents

- [Getting Started](#getting-started)
- [Adding a New Post](#adding-a-new-post)
- [Adding Author Information](#adding-author-information)
- [Categories and Tags](#categories-and-tags)
- [Local Development](#local-development)
- [Content Guidelines](#content-guidelines)
- [Submission Process](#submission-process)

## Getting Started

This site is built with [Hugo](https://gohugo.io/) using the PaperMod theme. To contribute, you'll need:

1. Git for version control
2. Hugo (optional for local preview)
3. A text editor for writing Markdown

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/interlynk-io/sbom-insights.git
cd sbom-insights

# Initialize submodules (PaperMod theme) - already done
git submodule update --init --recursive

# Install Hugo (optional, for local preview)
# On macOS
brew install hugo

# On Ubuntu/Debian
snap install hugo

# On Windows
choco install hugo-extended
```

### Using the Makefile

We provide a Makefile with helpful automation commands:

```bash
# View all available commands
make help
```

#### Available Makefile Commands

| Command             | Description                                                      | Usage                                   |
| ------------------- | ---------------------------------------------------------------- | --------------------------------------- |
| `make help`         | Display all available commands                                   | `make help`                             |
| `make serve`        | Run Hugo development server with drafts on http://localhost:1313 | `make serve`                            |
| `make build`        | Build production site with minification                          | `make build`                            |
| `make clean`        | Remove build artifacts (public/ and resources/)                  | `make clean`                            |
| `make new-post`     | Create a new blog post with automatic filename formatting        | `make new-post TITLE="Your Post Title"` |
| `make deploy`       | Build and deploy to Netlify production                           | `make deploy`                           |
| `make preview`      | Deploy a preview to Netlify                                      | `make preview`                          |
| `make update-theme` | Update PaperMod theme to latest version                          | `make update-theme`                     |
| `make check-links`  | Check for broken links in built site (requires htmltest)         | `make check-links`                      |
| `make format`       | Format all markdown files with prettier                          | `make format`                           |

#### Quick Examples

```bash
# Start writing a new post
make new-post TITLE="Understanding SBOM Formats"
make serve  # Preview at http://localhost:1313

# Ready to submit?
make format  # Clean up formatting
make check-links  # Verify all links work
make build  # Final build check

# Deploy (for maintainers)
make preview  # Test deployment
make deploy  # Production deployment
```

## Adding a New Post

### Step 1: Create a New Post File

Create a new Markdown file in the `content/posts/` directory:

```bash
# Using Hugo (recommended)
hugo new posts/your-post-title.md

# Or manually create the file
touch content/posts/your-post-title.md
```

### Step 2: Add Front Matter

Every post needs front matter at the top. Here's the template:

```markdown
+++
title = "Your Post Title"
date = 2024-01-15T10:00:00Z
draft = false
description = "A brief description of your post (150-160 characters for SEO)"
author = "Your Name"
tags = ["SBOM", "Security", "Supply Chain"]
categories = ["Best Practices"]
toc = true
tocopen = false
weight = 1
cover = {
    image = "/images/your-cover-image.jpg",
    alt = "Cover image description",
    caption = "Image caption if needed",
    relative = false
}
+++
```

#### Front Matter Fields Explained:

- **title**: The title of your post
- **date**: Publication date (ISO 8601 format)
- **draft**: Set to `true` while writing, `false` when ready to publish
- **description**: SEO meta description (150-160 characters)
- **author**: Your name (should match author data file)
- **tags**: Relevant keywords (lowercase, use existing tags when possible)
- **categories**: Main category (check existing categories first)
- **toc**: Show table of contents (true/false)
- **tocopen**: Open TOC by default (true/false)
- **weight**: Post priority (lower numbers appear first)
- **cover**: Optional cover image configuration

### Step 3: Write Your Content

After the front matter, write your post in Markdown:

````markdown
## Introduction

Start with a compelling introduction...

## Main Content

### Subsection 1

Your content here...

### Subsection 2

More content...

## Code Examples

\```json
{
"example": "code block"
}
\```

## Conclusion

Wrap up your post...
````

### Best Practices for Posts:

- Use clear, descriptive headings (H2 for main sections, H3 for subsections)
- Include code examples where relevant
- Add images to the `/static/images/` directory
- Link to authoritative sources
- Keep paragraphs concise (3-5 sentences)
- Use lists for better readability

## Adding Author Information

### Step 1: Create Author Data File

Create a YAML file in `data/authors/` directory:

```bash
mkdir -p data/authors
touch data/authors/your-name.yaml
```

### Step 2: Add Author Details

```yaml
name: "Your Full Name"
bio: "Brief bio about yourself and your expertise in SBOM/security"
email: "your.email@example.com"
company: "Your Company Name"
github: "yourusername"
linkedin: "yourusername"
twitter: "yourusername"
website: "https://yourwebsite.com"
copyright: "© 2025 Your Name" # Optional: custom copyright for your posts
```

### Step 3: Add Your Photo

Place your avatar image in `/static/images/authors/`:

```bash
cp your-photo.jpg static/images/authors/
```

Image requirements:

- Format: JPEG or PNG
- Size: 400x400px (square)
- File size: Under 100KB

## Categories and Tags

### Existing Categories

Use these primary categories for your posts:

- **Best Practices**: Implementation guides and recommendations
- **Tools & Reviews**: SBOM tool comparisons and reviews
- **Standards**: Information about SPDX, CycloneDX, etc.
- **Industry News**: Updates, regulations, and announcements
- **Case Studies**: Real-world implementations
- **Security**: Supply chain security topics
- **Tutorials**: How-to guides and walkthroughs

### Common Tags

Use relevant tags from this list (you can add new ones if needed):

- SBOM, CycloneDX, SPDX, SWID
- Supply Chain, Security, Vulnerability
- Open Source, License Compliance
- DevSecOps, CI/CD, Automation
- Docker, Kubernetes, Container Security
- Python, JavaScript, Go, Java (language-specific)
- NTIA, CISA, EU CRA (regulatory)

## Local Development

### Running the Development Server

```bash
# Start Hugo server with drafts (using Makefile)
make serve

# Or directly with Hugo
hugo server -D

# Without drafts
hugo server

# The site will be available at http://localhost:1313
```

### Building the Site

```bash
# Build the static site (using Makefile)
make build

# Or directly with Hugo
hugo --minify

# Build with drafts included
hugo -D

# Clean build artifacts
make clean

# The built site will be in the public/ directory
```

## Content Guidelines

### What We're Looking For

- **Technical Deep Dives**: Detailed explanations of SBOM concepts
- **Practical Guides**: How to implement SBOM in real projects
- **Tool Reviews**: Honest assessments of SBOM tools
- **Industry Analysis**: Trends and developments in software transparency
- **Case Studies**: Success stories and lessons learned
- **Security Research**: Vulnerability management and supply chain security

### Writing Style

- **Tone**: Professional but approachable
- **Length**: 800-2000 words typically
- **Audience**: DevOps engineers, security professionals, and technical managers
- **Format**: Use subheadings, bullet points, and code examples
- **Citations**: Link to sources and give credit

### Quality Checklist

Before submitting, ensure your post:

- [ ] Has accurate technical information
- [ ] Includes practical examples
- [ ] Is free of spelling/grammar errors
- [ ] Has proper formatting and structure
- [ ] Includes relevant tags and categories
- [ ] Has a compelling title and description
- [ ] Credits all sources and references

## Submission Process

### For External Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b post/your-post-title`
3. Add your post and any images
4. Commit your changes: `git commit -m "Add post: Your Post Title"`
5. Push to your fork: `git push origin post/your-post-title`
6. Create a Pull Request with:
   - Brief description of your post
   - Any special considerations
   - Your author information if first time

### For Team Members

1. Create a branch: `git checkout -b post/your-post-title`
2. Add your content
3. Push and create a PR for review
4. After approval, merge to main

### Review Process

All posts go through review for:

- Technical accuracy
- Writing quality
- Relevance to audience
- SEO optimization
- Code example correctness

Expect feedback within 3-5 business days.

## Additional Resources

### Markdown Help

- [Hugo Markdown Guide](https://www.markdownguide.org/tools/hugo/)
- [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/)

### Image Optimization

- Use WebP or optimized JPEG/PNG
- Recommended tools: [TinyPNG](https://tinypng.com/), [Squoosh](https://squoosh.app/)
- Maximum width: 1200px for cover images

### SEO Best Practices

- Use descriptive URLs (matching your filename)
- Write compelling meta descriptions
- Use heading hierarchy properly (H1 → H2 → H3)
- Include alt text for all images
- Internal linking to related posts

## Project Structure

```
sbom-insights/
├── content/          # Blog content
│   ├── posts/       # Blog posts
│   ├── about.md     # About page
│   └── contributors.md # Contributors page
├── data/
│   └── authors/     # Author profiles (YAML)
├── static/          # Static assets
│   └── images/      # Images
│       └── authors/ # Author avatars
├── themes/
│   └── PaperMod/    # Hugo theme
├── hugo.toml        # Hugo configuration
├── Makefile         # Build automation
├── netlify.toml     # Netlify configuration
└── CONTRIBUTING.md  # Contribution guidelines
```

## Features

- 📝 SBOM-focused content
- 👥 Multi-author support
- 🔍 Full-text search
- 📱 Responsive design
- 🌙 Dark/Light mode
- 📊 Reading time estimates
- 🏷️ Categories and tags
- 📡 RSS feed

## Topics We Cover

- SBOM Standards (CycloneDX, SPDX)
- Generation tools and techniques
- Supply chain security
- Vulnerability management
- License compliance
- Implementation best practices
- Industry regulations (NTIA, EU CRA, etc.)
- Integration with CI/CD pipelines
- Container and cloud security

## Getting Help

If you need assistance:

1. Check existing posts for examples
2. Review the [Hugo documentation](https://gohugo.io/documentation/)
3. Open an issue with your question
4. Contact the maintainers

## License and Copyright

### License

All content in SBOM Insights is licensed under [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

### Copyright

- Copyright © 2025 Interlynk.io and Contributors
- Individual authors retain copyright to their contributions
- By contributing, you grant Interlynk.io rights under CC BY 4.0 to publish and distribute your content
- Proper attribution to original authors is required for any use

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for a list of all contributors.

## Contact

- GitHub: [github.com/interlynk-io](https://github.com/interlynk-io/sbom-insights)
- LinkedIn: [linkedin.com/company/interlynk](https://linkedin.com/company/interlynk)
- Twitter: [@interlynk](https://twitter.com/interlynk)

---

Thank you for contributing to SBOM Insights! Your knowledge and expertise help build a stronger SBOM community.
