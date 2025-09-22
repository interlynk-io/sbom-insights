# SBOM Insights - Contributor Guide

Welcome to SBOM Insights! This guide will help you contribute to our blog about Software Bill of Materials (SBOM), supply chain security, and related topics.

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

# Initialize submodules (PaperMod theme)
git submodule update --init --recursive

# Install Hugo (optional, for local preview)
# On macOS
brew install hugo

# On Ubuntu/Debian
snap install hugo

# On Windows
choco install hugo-extended
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

Create a JSON file in `data/authors/` directory:

```bash
mkdir -p data/authors
touch data/authors/your-name.json
```

### Step 2: Add Author Details

```json
{
  "name": "Your Full Name",
  "bio": "Brief bio about yourself and your expertise in SBOM/security",
  "avatar": "/images/authors/your-photo.jpg",
  "social": {
    "github": "https://github.com/yourusername",
    "linkedin": "https://linkedin.com/in/yourusername",
    "twitter": "https://twitter.com/yourusername",
    "website": "https://yourwebsite.com"
  },
  "company": "Your Company Name",
  "role": "Your Job Title"
}
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
# Start Hugo server with drafts
hugo server -D

# Without drafts
hugo server

# The site will be available at http://localhost:1313
```

### Building the Site

```bash
# Build the static site
hugo

# Build with drafts included
hugo -D

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
│   └── authors/     # Author profiles (JSON)
├── static/          # Static assets
│   └── images/      # Images
│       └── authors/ # Author avatars
├── themes/
│   └── PaperMod/    # Hugo theme
├── hugo.toml        # Hugo configuration
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

## License

By contributing to SBOM Insights, you agree that your contributions will be licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Contact

- GitHub: [github.com/interlynk-io](https://github.com/interlynk-io/sbom-insights)
- LinkedIn: [linkedin.com/company/interlynk](https://linkedin.com/company/interlynk)
- Twitter: [@interlynk](https://twitter.com/interlynk)

---

Thank you for contributing to SBOM Insights! Your knowledge and expertise help build a stronger SBOM community.
