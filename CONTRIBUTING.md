# Contributing to SBOM Insights

Thank you for your interest in contributing to SBOM Insights! This document provides technical details for contributors.

## Prerequisites

- Git and GitHub account
- Hugo static site generator (v0.100+)
- Text editor (VS Code, Vim, etc.)
- Basic Markdown knowledge

## Local Development Setup

### 1. Install Hugo

```bash
# macOS
brew install hugo

# Linux (Snap)
snap install hugo

# Windows (Chocolatey)
choco install hugo-extended
```

### 2. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/sbom-blog.git
cd sbom-blog
git submodule update --init --recursive
```

### 3. Run Local Server

```bash
hugo server -D
# Visit http://localhost:1313
```

## Creating Content

### New Blog Post

```bash
# Create new post
hugo new posts/your-post-title.md

# Edit the post
vim content/posts/your-post-title.md
```

### Post Front Matter

```yaml
---
title: "Your Post Title"
date: 2024-01-30
draft: false  # Set to false when ready
author: "author-id"
authors: ["author-id"]
tags: ["tag1", "tag2", "tag3"]
categories: ["Category1"]
summary: "Brief description for listings"
weight: 10  # Optional: for ordering
cover:
    image: "images/cover.jpg"  # Optional
    alt: "Cover alt text"
    caption: "Image caption"
    relative: false
---
```

### Adding Images

Place images in `static/images/posts/your-post/`:

```markdown
![Alt text](/images/posts/your-post/image.png)
```

### Code Blocks

Use syntax highlighting:

````markdown
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5"
}
```
````

### Shortcodes

Available Hugo shortcodes:

```markdown
{{< notice note >}}
This is a note
{{< /notice >}}

{{< notice warning >}}
This is a warning
{{< /notice >}}

{{< notice info >}}
This is info
{{< /notice >}}
```

## Author Profiles

### Create Author File

Create `data/authors/your-id.yaml`:

```yaml
name: "Your Full Name"
bio: "Your bio in 2-3 lines"
email: "your.email@example.com"
company: "Your Company"
github: "githubusername"
linkedin: "linkedin-profile"
twitter: "twitterhandle"
website: "https://yourwebsite.com"
```

### Link to Posts

In your post front matter:

```yaml
author: "your-id"
authors: ["your-id"]  # For multiple authors: ["id1", "id2"]
```

## Categories and Tags

### Available Categories

- Fundamentals
- Standards
- Tools
- Security
- Compliance
- Case Studies
- Best Practices
- Comparisons

### Popular Tags

- SBOM
- CycloneDX
- SPDX
- Security
- Supply Chain
- Vulnerability Management
- License Compliance
- DevSecOps
- Open Source
- Containers
- Cloud Native

## Style Guide

### Headings

- H1: Post title only (in front matter)
- H2: Main sections (`##`)
- H3: Subsections (`###`)
- H4: Rarely used (`####`)

### Lists

```markdown
- Unordered list item
  - Nested item
  - Another nested item

1. Ordered list
2. Second item
   1. Nested ordered
   2. Another nested
```

### Tables

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

### Links

```markdown
[Link text](https://example.com)
[Internal link](/posts/other-post/)
```

## Testing Your Changes

### Build Site

```bash
# Build site
hugo

# Build with drafts
hugo -D

# Check for errors
hugo --verbose
```

### Check Links

```bash
# Install link checker
npm install -g markdown-link-check

# Check links
find content -name "*.md" -exec markdown-link-check {} \;
```

## Submitting Changes

### Commit Messages

Follow conventional commits:

```bash
feat: Add new post about SBOM tools
fix: Correct typo in CycloneDX post
docs: Update contributor guidelines
style: Format code examples
refactor: Reorganize content structure
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New blog post
- [ ] Content update
- [ ] Bug fix
- [ ] Documentation

## Checklist
- [ ] Tested locally with `hugo server`
- [ ] No broken links
- [ ] Added author profile (if new author)
- [ ] Set draft: false
- [ ] Added appropriate tags and categories

## Screenshots (if applicable)
Add screenshots here
```

## Review Criteria

Your contribution will be reviewed for:

1. **Technical Accuracy**: Facts, code, and examples are correct
2. **Clarity**: Content is well-organized and easy to understand
3. **Relevance**: Topic is relevant to SBOM community
4. **Originality**: Content is original or properly attributed
5. **Formatting**: Follows style guide and Hugo conventions

## Troubleshooting

### Common Issues

**Problem**: Hugo server not starting
```bash
# Solution: Update submodules
git submodule update --init --recursive
```

**Problem**: Theme not loading
```bash
# Solution: Check theme in config
grep theme hugo.toml
# Should show: theme = 'PaperMod'
```

**Problem**: Images not showing
```bash
# Solution: Use absolute paths from static/
/images/your-image.png  # Correct
images/your-image.png   # Wrong
```

## Resources

- [Hugo Documentation](https://gohugo.io/documentation/)
- [PaperMod Theme Docs](https://github.com/adityatelange/hugo-PaperMod/wiki)
- [Markdown Guide](https://www.markdownguide.org/)
- [SBOM Standards](https://www.cisa.gov/sbom)

## Contact

- GitHub Issues: [github.com/YOUR-REPO/sbom-blog/issues](https://github.com/YOUR-REPO/sbom-blog/issues)
- Email: contributors@sbominsights.com

Thank you for contributing to SBOM Insights!