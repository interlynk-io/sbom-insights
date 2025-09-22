---
title: "Contributors Guide"
description: "Join our community of SBOM experts and share your knowledge"
---

## Welcome Contributors!

SBOM Insights thrives on community contributions. Whether you're from our internal team or an external expert, we welcome your insights, experiences, and knowledge about Software Bill of Materials.

## Who Can Contribute?

### Internal Contributors

- Security engineers
- Software developers
- DevOps/DevSecOps practitioners
- Compliance and legal teams
- Product managers working with SBOM

### External Contributors

- Industry experts and consultants
- Researchers and academics
- Open source maintainers
- SBOM tool developers
- Anyone with SBOM implementation experience

## Types of Contributions

### Blog Posts

- Technical tutorials and how-tos
- Case studies and implementation stories
- Tool reviews and comparisons
- Best practices and lessons learned
- Industry news and analysis

### Other Contributions

- Code examples and scripts
- SBOM samples and templates
- Corrections and improvements to existing content
- Translations (coming soon)

## How to Contribute

### Step 1: Fork and Clone

```bash
# Fork the repository on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/sbom-blog.git
cd sbom-blog
```

### Step 2: Create Your Branch

```bash
git checkout -b post/your-post-title
```

### Step 3: Add Your Content

Create a new post in `content/posts/`:

```bash
hugo new posts/my-sbom-article.md
```

### Step 4: Post Format

Use this template for your post:

```markdown
---
title: "Your Article Title"
date: 2024-01-30
draft: false
author: "your-name"
authors: ["your-name"]
tags: ["relevant", "tags", "here"]
categories: ["Category"]
summary: "A brief description of your article (50-100 words)"
---

## Introduction

Your content here...

## Main Sections

Break your content into logical sections...

## Conclusion

Wrap up your key points...
```

### Step 5: Add Author Information

Create your author profile in `data/authors/your-name.yaml`:

```yaml
name: "Your Name"
bio: "Brief bio (2-3 lines)"
email: "your.email@example.com"
company: "Your Company"
github: "yourusername"
linkedin: "yourprofile"
twitter: "yourhandle"
```

### Step 6: Submit Pull Request

```bash
git add .
git commit -m "Add post: Your Article Title"
git push origin post/your-post-title
```

Then create a pull request on GitHub.

## Content Guidelines

### Technical Accuracy

- Verify all technical information
- Include version numbers for tools
- Test all code examples
- Provide references and sources

### Writing Style

- Clear and concise language
- Use headings and subheadings
- Include code examples where relevant
- Add diagrams or screenshots if helpful

### Topics We're Looking For

- SBOM generation techniques
- Integration with CI/CD pipelines
- Vulnerability management with SBOMs
- License compliance strategies
- Real-world implementation challenges
- Regulatory compliance (EU CRA, US EO)
- SBOM consumption and analysis
- Supply chain security best practices

## Review Process

1. **Initial Review**: Check for completeness and guidelines compliance
2. **Technical Review**: Verify technical accuracy
3. **Editorial Review**: Grammar, style, and formatting
4. **Publication**: Merge and deploy

Expected timeline: 5-10 business days

## Code of Conduct

### Be Respectful

- Welcome diverse perspectives
- Provide constructive feedback
- Focus on the content, not the person

### Be Inclusive

- Use inclusive language
- Consider global audience
- Avoid jargon without explanation

### Be Helpful

- Share knowledge generously
- Help other contributors
- Improve existing content

## Recognition

Contributors are recognized through:

- Author attribution on posts
- Contributors page listing
- Social media mentions
- Annual contributor recognition

## Questions?

- Open an issue on GitHub
- Email: support@interlynk.io
- Join our Discord: [coming soon]

## Legal

By contributing, you agree that:

- Your content is original or properly attributed
- You have the right to share the content
- Content is provided under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

## Get Started

Ready to contribute? Here are some ideas:

1. **First-time contributor?** Start with a tool review or tutorial
2. **Experienced with SBOMs?** Share a case study or best practices
3. **Found an error?** Submit a correction
4. **Have a question?** Open a discussion

We look forward to your contributions to the SBOM community!
