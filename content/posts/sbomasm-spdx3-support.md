+++
date = '2026-10-21T16:30:00+05:30'
draft = false
title = "sbomasm Now Supports SPDX 3.0"
categories = ['Tools', 'Compliance', 'Standards']
tags = ['SBOM', 'sbomasm', 'SPDX 3.0', 'JSON-LD', 'SPDX', 'SBOM Editing', 'SBOM Assembly', 'Compliance']
author = 'Vivek Sahu'
description = 'sbomasm now fully supports SPDX 3.0 across assemble, edit, enrich, rm, convert, and view commands. Learn how we tackled JSON-LD parsing, CreationInfo deduplication, and schema correctness to bring next-gen SBOM support to your CLI.'
slug = 'sbomasm-spdx-3.0-support'
+++

Hey SBOM enthusiasts 👋,

If you've been tracking the SBOM standards space, by now you would have probably known that SPDX 3.0 is a big enhacement. It's not just another version bump from SPDX:2.3 to SPDX:2.4, instead it's a fundamental rethinking of how SBOM data will be modeled, serialized, and shared. With its **element-based** architecture, **JSON-LD** serialization, and **richer relationship** modeling, SPDX 3.0 is built for the scale and complexity of modern software supply chains.

But here's the thing: a standard is only as useful as the tools that support it.

That's why we're excited to announce that **sbomasm now supports SPDX 3.0** across its core commands. Whether you're **assembling**, **editing**, **enriching**, **removing**, **converting**, or **viewing** SBOMs, sbomasm handles SPDX 3.0 with the same ease it brings to SPDX 2.3 and CycloneDX.

Let's talk about what SPDX 3.0 means for you, what we built, and why it took more than just adding a new parser.

## Why SPDX 3.0 Matters

Before we dive into the tooling, let's quickly revisit why SPDX 3.0 is worth.

SPDX 2.3 has served the community well, but it was designed in an era when SBOMs were simpler documents with a major objectives of Licensing for compliance. SPDX 3.0 introduces several foundational improvements:

- **Element-based model**: Everything is an element with a unique SpdxID. Packages, files, snippets, relationships, and even the document itself are first-class elements.
- **JSON-LD serialization**: Instead of flat JSON, SPDX 3.0 uses JSON-LD with `@id` references, `@type` annotations, and shared objects like `CreationInfo`.
- **CreationInfo as a shared resource**: Rather than duplicating author/tool/timestamp metadata across every element, SPDX 3.0 centralizes it in `CreationInfo` objects that elements reference.
- **Richer relationships**: Relationships are explicit elements with their own metadata, enabling more granular dependency and provenance tracking.
- **Profile support**: Built-in extensibility for security, licensing, software, and other domains.

In short, SPDX 3.0 is designed for interoperability at scale. But that power comes with complexity and that's where sbomasm steps in.

## The Challenge: JSON-LD isn't just JSON

If you've ever opened an SPDX 3.0 file, the first thing you notice is that it doesn't look like SPDX 2.3.

In SPDX 2.3, a package looks like this:

```json
{
  "SPDXID": "SPDXRef-Package",
  "name": "lodash",
  "versionInfo": "4.17.21",
  "supplier": "Person: John Doe"
}
```

In SPDX 3.0, the same concept becomes:

```json
{
  "@id": "https://example.com/pkg/lodash/4.17.21",
  "@type": "software_Package",
  "software_name": "lodash",
  "software_version": "4.17.21",
  "software_supplier": {
    "@id": "https://example.com/org/interlynk"
  }
}
```

Notice the differences? `@id` instead of `SPDXID`, `@type` instead of implicit types, prefixed fields like `software_name` and `software_version`, and references to external objects instead of inline strings.

This means:

- You can't just `json.Unmarshal` into a struct
- References need to be resolved in a second pass
- `CreationInfo` objects are shared and referenced, not duplicated
- Field prefixes vary by profile (Core, Software, Security, etc.)
- Agents (Person, Organization, Tool) are separate elements with their own identities

For sbomasm, which needs to read, modify, and write SBOMs while keeping them valid, this meant building a completely new parsing and serialization pipeline.

## What we built: SPDX 3.0 across all commands

Here's the good news: **sbomasm now supports SPDX 3.0 end-to-end**. Let's walk through each command.

### 1. `assemble` — Merge SBOMs in SPDX 3.0

The `assemble` command brings together multiple SBOMs into a single unified document. With SPDX 3.0 support, you can now:

- Perform **hierarchical merges** where each input SBOM becomes a sub-component under a new root
- Run **flat merges** that deduplicate components across platform-specific builds
- Use **assembly merges** for bundling related products
- Apply **augment merges** to enrich existing SPDX 3.0 SBOMs with scan data or vendor SBOMs

```bash
sbomasm assemble \
  -n "my-platform" \
  -v "2.0.0" \
  -t application \
  frontend.spdx3.json \
  backend.spdx3.json \
  -o unified.spdx3.json
```

The result? A valid SPDX 3.0 JSON-LD document with proper `@type` annotations, shared `CreationInfo` references, and preserved dependency relationships.

### 2. `edit` — Modify fields in SPDX 3.0

Editing SPDX 3.0 SBOMs is where the real complexity lives. Because fields are prefixed by profile and agents are separate elements, changing an "author" or "supplier" isn't a simple string replacement—it might require creating new `Person` or `Organization` elements and updating references.

sbomasm handles this transparently:

```bash
# Update document author
sbomasm edit --author "Interlynk" --append spdx3-sbom.json -o edited.json

# Update component supplier by name and version
sbomasm edit --supplier "Interlynk" --name "nginx" --version "1.21.0" spdx3-sbom.json -o edited.json

# Add lifecycle information
sbomasm edit --lifecycle "build" spdx3-sbom.json -o edited.json
```

Under the hood, sbomasm creates the right `Agent` elements, manages `CreationInfo` references, and ensures the output passes schema validation.

### 3. `enrich` — Fill gaps with ClearlyDefined

The `enrich` command pulls license and metadata information from [ClearlyDefined](https://clearlydefined.io/) and adds it to your SBOM. Now it works for SPDX 3.0 too:

```bash
sbomasm enrich --fields="license" spdx3-sbom.json -o enriched.json
```

For SPDX 3.0, this means creating `SimpleLicensingText` elements and `Relationship` elements that link them to the correct packages—all in valid JSON-LD format.

### 4. `rm` — Remove fields and components

Sometimes subtraction is more important than addition. The `rm` command now supports SPDX 3.0 for both field removal and full component removal:

```bash
# Remove author from document
sbomasm rm --field author --scope document spdx3-sbom.json -o cleaned.json

# Remove a specific component and its dependencies
sbomasm rm --components --name "internal-tool" --version "0.1.0" spdx3-sbom.json -o cleaned.json

# Remove all components with a specific license
sbomasm rm --components --field license --value "MIT" spdx3-sbom.json -o cleaned.json
```

A key challenge here was **orphaned element cleanup**. In SPDX 3.0, removing a component might leave behind dangling `Agent` or `CreationInfo` elements that are no longer referenced. sbomasm automatically cleans these up to keep your SBOM valid.

### 5. `convert` — Cross-Format Translation

Need to convert between SPDX 2.3, SPDX 3.0, and CycloneDX? sbomasm handles it:

```bash
# Convert SPDX 3.0 into csv format
sbomasm convert --format csv complete-sbom.spdx3.json --output convert-spdx3-to-csv.csv
```

### 6. `view` — Inspect SPDX 3.0 SBOMs

The `view` command lets you inspect SBOMs in tree, flat, or JSON format. It now renders SPDX 3.0 structures just as clearly as SPDX 2.3 or CycloneDX:

```bash
sbomasm view spdx3-sbom.json
```

## Known Limitations

We're transparent about what's not there yet:

- **`securesbom`**: The SecureSBOM signing API currently returns `400: Invalid SBOM payload` for SPDX 3.0 documents. This is a server-side limitation we're tracking.
- **`dt` (Dependency-Track)**: Full SPDX 3.0 upload support depends on Dependency-Track's own parser maturity.

Everything else—assemble, edit, enrich, rm, convert, and view—is ready to go.

## Summary Table

| Command | SPDX 3.0 Support | Status |
|---------|------------------|--------|
| `assemble` | Hierarchical, Flat, Assembly, Augment | ✅ Ready |
| `edit` | Document & component field mutations | ✅ Ready |
| `enrich` | License enrichment via ClearlyDefined | ✅ Ready |
| `rm` | Field removal & component removal | ✅ Ready |
| `convert` | Cross-format translation | ✅ Ready |
| `view` | Tree, flat, JSON output | ✅ Ready |
| `securesbom` | SBOM signing | ⏳ Blocked (API) |

## Try It Out

Ready to work with SPDX 3.0? Grab the latest sbomasm:

```bash
go install github.com/interlynk-io/sbomasm@latest
```

Or download a release from [GitHub](https://github.com/interlynk-io/sbomasm/releases).

If you have SPDX 3.0 SBOMs sitting around—or if you're generating them from tools like Syft, SPDX Tools, or custom pipelines—give sbomasm a spin. We'd love to hear how it handles your real-world documents.

## Wrapping Up

SPDX 3.0 represents the future of software transparency, but futures only matter when the tools catch up. With sbomasm's SPDX 3.0 support, you can now assemble, edit, enrich, clean up, convert, and inspect SPDX 3.0 SBOMs without wrestling with JSON-LD complexity.

The underlying `spdx-zen` library handles the heavy lifting—two-pass parsing, reference resolution, agent management, and serialization—so you can focus on what matters: building accurate, shareable, compliance-ready SBOMs.

If you loved this project, show the love back by starring ⭐ the [repo](https://github.com/interlynk-io/sbomasm).

Found a bug with SPDX 3.0? Have a use case we haven't covered? File an [issue](https://github.com/interlynk-io/sbomasm/issues/new)—we'd love to help.

## Resources

- sbomasm GitHub: <https://github.com/interlynk-io/sbomasm>
- sbomasm Documentation: <https://github.com/interlynk-io/sbomasm/tree/main/docs>
- SPDX 3.0 Specification: <https://spdx.github.io/spdx-spec/v3.0.1/>
- spdx-zen Library: <https://github.com/interlynk-io/spdx-zen>