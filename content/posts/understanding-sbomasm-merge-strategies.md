+++
date = '2026-06-01T10:00:00+05:30'
draft = false
title = 'Understanding SBOM Merge Strategies: A Complete Guide'
categories = ['Tools', 'Best Practices']
tags = ['SBOM', 'sbomasm', 'Merge Strategies', 'CycloneDX', 'SPDX', 'SBOM Assembly', 'Hierarchical', 'Flat Merge', 'Augment Merge']
author = 'Vivek Sahu'
description = 'Master SBOM merge strategies: hierarchical, flat, assembly, and augment merge. Learn when to use each approach for combining SBOMs effectively with hands-on sbomasm examples.'
+++

Hey SBOM enthusiasts 👋,

If your organization is dealing with multiple SBOMs and you're wondering how to combine them into a single **Unified SBOM Document**, you're not alone. Merging SBOMs sounds simple in theory, just combine the files, but in practice, it's not that straightforward.

One of the challenges is that those SBOMs can come from very different sources: platform-specific builds, multi-service architectures, microservices, or scan results that need enriching. Each source calls for a different way of merging. Without the right strategy, you end up with duplicate components, broken dependency chains, or SBOMs that simply don't validate.

Understanding when and how to use each strategy is essential for anyone working on SBOMs in the software supply chain transparency.

In this post, we'll first explore the different **merge strategies** that apply to any SBOM tool, then show you how **sbomasm** brings these strategies to life with practical, hands-on examples.

But before we dive into the mechanics of merging, let's step back and ask: **why bother creating a single unified SBOM at all ?**, whether you are combining platform-specific builds, stitching together microservices, or layering scan results onto a final SBOM, the end goal is the same, a single document that accurately represents your entire product. And that unified view matters more than you might think.

## Why Single Unified SBOM Matters ?

Let's understand the importance of single unified SBOM:

### Complete Visibility

A single SBOM gives you a **complete view** of your entire product. But a product isn't just one thing—it's made up of different components, each with its own role and uniqueness. When you have everything in one document, you bring every component from all services, platforms, and build stages into one place. This gives you clear visibility across everything and becomes your single source of truth that answers: "What are all the components in my product?"

### Faster Security Response

A single SBOM gives you **faster security response**. When a critical vulnerability drops (think Log4j, Spring4Shell), security teams can scan everything in a single pass instead of checking 20 separate SBOMs. One query, one answer. This directly reduces mean-time-to-remediate (MTTR).

### Simplified Compliance

A single SBOM gives you **simplified compliance**. Regulators and enterprise customers get one artifact to review—not a ZIP file of 15 fragmented SBOMs. One unified SBOM satisfies **NTIA minimum elements**, **FDA cybersecurity guidance**, and **EU Cyber Resilience Act** requirements cleanly.

### Accurate License Inventory

A single SBOM gives you an **accurate license inventory**. The true license footprint of your product is visible in one place, not scattered across multiple files. When a component appears in three separate SBOMs with different license expressions, merging surfaces conflicts and obligations that fragmented files hide.
  
### Easier Distribution

A single SBOM gives you **easier distribution**. Customers, auditors, and government agencies get one artifact they can ingest into Dependency-Track, OWASP DefectDojo, Interlynk platform, or their internal compliance pipeline. One unified SBOM is the standard deliverable.

### Consistent Versioning

A single SBOM gives you **consistent versioning**. When you ship v2.3.0, the SBOM represents v2.3.0. One version for your entire product release, not a collection of unrelated files with different serial numbers.

Each of these benefits: visibility, security, compliance, licensing, distribution, and versioning depends on one thing: bringing multiple SBOMs together into a single document. But when does this actually happen? In what situations do you find yourself with multiple SBOMs that need merging in the first place?

## Why Merge SBOMs?

So you know why a unified SBOM matters. But when do you actually find yourself needing to merge? Here are the common situations where multiple SBOMs appear and need combining:

- **Platform-specific builds**: Your CI generates separate SBOMs for Linux and Windows builds of the same software. Same product, different artifacts.
- **Multi-service applications**: You deploy a microservices platform where each service has its own build pipeline and its own SBOM. Now you need one view of the entire system.
- **Scan result enrichment**: You generated a base SBOM, then ran a vulnerability scan that produced another SBOM with CVE data. You need to combine them.
- **Vendor integrations**: You built your application and have your internal SBOM, but you also received SBOMs from third-party vendors you depend on.
- **CI/CD artifacts**: Your pipeline generates SBOMs at different stages—build, test, release—and you need to consolidate them into the final deliverable.

Each scenario calls for a different approach, and that's where merge strategies come in.

## The Four Merge Strategies

Those scenarios: platform builds, microservices, scan results, vendor integrations, each need a different way of combining SBOMs. There are four distinct merge strategies, and picking the right one depends on what you're trying to achieve:

- Hierarchical
- Flat
- Assembly
- Augment

Let's discuss each one by one before we see how sbomasm implements them.

## 1. Hierarchical Merge

**Concept**: Each input SBOM becomes a self-contained sub-tree under a new root, preserving the complete component hierarchy.

### Visual Overview

```text
Input SBOMs:
┌─────────────────────┐    ┌─────────────────────┐
│ SBOM A: Frontend    │    │ SBOM B: Backend     │
│ ├── frontend (root) │    │ ├── backend (root)  │
│ │   ├── react       │    │ │   ├── express     │
│ │   ├── axios       │    │ │   ├── mongoose    │
│ │   └── nginx       │    │ │   └── jwt         │
└─────────────────────┘    └─────────────────────┘

Output (Hierarchical):
Final SBOM
├── New Root (MyApp v1.0.0)
│   ├── SBOM A Root (frontend)  <-- AS SUB-COMPONENT
│   │   ├── react               <-- Nested under frontend
│   │   ├── axios               <-- Nested under frontend
│   │   └── nginx               <-- Nested under frontend
│   └── SBOM B Root (backend)   <-- AS SUB-COMPONENT
│       ├── express             <-- Nested under backend
│       ├── mongoose            <-- Nested under backend
│       └── jwt                 <-- Nested under backend
```

### When to Use

| Scenario | Why Hierarchical? |
|----------|-------------------|
| Microservices platform | Each service becomes a sub-component, maintaining service-level relationships |
| Platform-specific builds (same primary) | Linux + Windows builds of same software—combined into **one sub-component** under the final SBOM because they share the same primary component (components from both platforms deduplicated under that single sub-component) |
| Container + Application | Base image components nested separately from app components |
| Multi-module projects | Maven/Gradle multi-module where each module is distinct |
| Different teams' components | Services from different teams that compose a platform |

### Real-World Example: Kubernetes Microservices Platform

Imagine you have an e-commerce platform running on Kubernetes with four microservices:

1. **Frontend** (React + nginx)
   - Components: react, react-router-dom, axios, nginx

2. **API Gateway** (Node.js Express)
   - Components: express, helmet, cors, jsonwebtoken

3. **Payment Service** (Go)
   - Components: stripe-go, paypal-sdk, gorilla-mux

4. **Order Service** (Java Spring Boot)
   - Components: spring-boot, hibernate, kafka-client

**Hierarchical merge creates:**

```text
ecommerce-platform v1.0.0 (Application)
├── frontend v2.1.0 (Sub-component)
│   ├── react v18.2.0
│   ├── react-router-dom v6.14.0
│   ├── axios v1.4.0
│   └── nginx v1.25.0
├── api-gateway v1.5.0 (Sub-component)
│   ├── express v4.18.2
│   ├── helmet v7.0.0
│   ├── cors v2.8.5
│   └── jsonwebtoken v9.0.0
├── payment-service v3.0.0 (Sub-component)
│   ├── stripe-go v74.0.0
│   ├── paypal-sdk v1.0.0
│   └── gorilla-mux v1.8.0
└── order-service v2.2.0 (Sub-component)
    ├── spring-boot v3.1.0
    ├── hibernate v6.2.0
    └── kafka-client v3.4.0
```

### Real-World Example: Platform-Specific Builds with Same Primary

You build `cs.template` for multiple platforms, each with different dependencies:

1. **Linux Python SBOM**
   - Primary: `cs.template` v2026.2.3.0.dev5
   - Components: idna, multidict, propcache, urllib3, yarl

2. **Windows Python SBOM**
   - Primary: `cs.template` v2026.2.3.0.dev5
   - Components: idna, multidict, propcache, urllib3, yarl (plus Windows-specific deps)

3. **JavaScript SBOM**
   - Primary: `cs-template-components-base` v0.1.0
   - Components: buffer, base64-js, ieee754, react-highlight-words

4. **Another Service: cs.foo**
   - Primary: `cs.foo` v0.1.0
   - Components: numpy (shared with cs.template)

**Hierarchical merge produces:**

```text
cs.template v1.0.0 (Application)            <-- New root
├── cs.template v2026.2.3.0.dev5             <-- Linux + Win32 merged
│   ├── idna v3.11
│   ├── multidict v6.7.1
│   ├── propcache v0.5.2
│   ├── urllib3 v2.7.0
│   ├── yarl v1.24.2
│   └── pywin32 v311        <-- Windows-only (if present)
├── cs-template-components-base v0.1.0       <-- JS sub-component
│   ├── buffer v6.0.3
│   ├── base64-js v1.5.1
│   ├── ieee754 v1.2.1
│   └── react-highlight-words v0.21.0
└── cs.foo v0.1.0                          <-- Independent service
    └── numpy v2.4.2      <-- Shared dependency, deduplicated globally
```

SBOMs sharing the same primary component (name + version) are automatically merged into one sub-component. Shared dependencies across different primaries are deduplicated globally.

**Key Characteristics**:

- ✅ Preserves complete hierarchy from each SBOM
- ✅ Each service's dependencies are nested within that service
- ✅ Multiple SBOMs with the **same** primary component merge into one sub-component
- ✅ Best for combining SBOMs of **different** software components

### How Dependencies Are Handled

- Each input SBOM's **primary component** becomes a direct dependency of the new root SBOM
- All original dependency relationships from input SBOMs are **preserved as-is**
- Dependencies remain nested under their respective primary components

## 2. Flat Merge

But what if you're not combining different services—you're combining the **same** software built for different platforms? You don't need to preserve separate hierarchies; you just want one clean list of components. That's where flat merge comes in.

**Concept**: Everything flattened to a single level. Duplicates removed. Simplest structure.

### Visual Overview

```text
Input SBOMs (Platform Variants):
┌──────────────────────────────┐    ┌──────────────────────────────┐
│ SBOM A: MyApp (Linux)        │    │ SBOM B: MyApp (Windows)      │
│ ├── MyApp v1.0.0             │    │ ├── MyApp v1.0.0             │
│ │   ├── idna v3.11           │    │ │   ├── idna v3.11           │
│ │   ├── urllib3 v2.7.0       │    │ │   ├── urllib3 v2.7.0       │
│ │   └── yarl v1.24.2         │    │ │   └── yarl v1.24.2         │
└──────────────────────────────┘    └──────────────────────────────┘

Output (Flat):
Final SBOM
├── New Root (MyApp v1.0.0)
│   ├── idna v3.11          <-- FLAT (deduplicated)
│   ├── urllib3 v2.7.0      <-- FLAT (deduplicated)
│   └── yarl v1.24.2        <-- FLAT (deduplicated)
```

### When to Use

| Scenario | Why Flat? |
|----------|-----------|
| Platform-specific builds | Same software for Linux + Windows—**all primaries and components flattened** to the same level, no nesting (deduplication still applies, but no platform grouping) |
| License/Compliance Inventory | Just need a list of all components for legal review |
| Simple BOM | Quick inventory without relationship complexity |
| Large-scale aggregation | When you don't care about which component came from where |

### Real-World Example: Multi-Platform Python Application

You have the same Python application built for Linux and Windows:

- **Linux SBOM**: cs.template v2026.2.3.0 with Python libs (idna, multidict, yarl)
- **Windows SBOM**: cs.template v2026.2.3.0 with same Python libs

**Flat merge creates:**

```text
cs.template v2026.2.3.0 (Application)
├── idna v3.11        <-- From both SBOMs, deduplicated
├── multidict v6.7.1  <-- From both SBOMs, deduplicated
├── propcache v0.5.2  <-- From both SBOMs, deduplicated
├── urllib3 v2.7.0    <-- From both SBOMs, deduplicated
└── yarl v1.24.2      <-- From both SBOMs, deduplicated
```

**Key Characteristics**:

- ✅ Simplest possible structure
- ✅ Deduplicates components automatically
- ✅ All components at the same level
- ✅ Best for merging SBOMs of the **same** software for different platforms

### How Dependencies Are Handled

- Each input SBOM's **primary component** becomes a direct dependency of the new root SBOM
- Original dependencies from input SBOMs are **preserved as-is** in the dependencies section
- No nesting—everything is at the same level in the final SBOM

## 3. Assembly Merge

Flat merge works well for the same software across platforms, but what if you're combining **different** products that are related but independent? You want each product to retain its identity, but you don't need the full nesting of hierarchical. That's where assembly merge fits.

**Concept**: Primary components become sub-components of the new root, but all other components stay at the top level. A middle ground between hierarchical and flat.

### Visual Overview

```text
Input SBOMs:
┌─────────────────────┐    ┌─────────────────────┐
│ SBOM A: Tool A      │    │ SBOM B: Tool B      │
│ ├── tool-a (root)   │    │ ├── tool-b (root)   │
│ │   ├── dep1        │    │ │   ├── dep3        │
│ │   └── dep2        │    │ │   └── dep4        │
└─────────────────────┘    └─────────────────────┘

Output (Assembly):
Final SBOM
├── New Root (Tool Suite v1.0.0)
│   ├── tool-a (Sub-component)  <-- Primary as sub-component
│   └── tool-b (Sub-component)  <-- Primary as sub-component
├── dep1      <-- TOP LEVEL
├── dep2      <-- TOP LEVEL
├── dep3      <-- TOP LEVEL
└── dep4      <-- TOP LEVEL
```

### When to Use

| Scenario | Why Assembly? |
|----------|---------------|
| Product Suite | Combining independent products—keeps each product distinct (unlike hierarchical which nests all dependencies) |
| Library Collection | Creating a bundle of related libraries |
| Plugin System | Main app + plugins where plugins are first-class |
| Distribution Package | OS package that bundles multiple independent tools |

**Key Characteristics**:

- ✅ Primary components are nested under the new root
- ✅ All other components are flat (top-level)
- ✅ Good balance between hierarchy and flatness
- ✅ Best for bundling **related but independent** products

### Real-World Example: Developer Tool Suite

Imagine you're shipping a development toolkit that includes:

- **Docker Desktop** (container runtime)
- **VS Code** (editor)
- **Postman** (API testing)

Each is an independent product with its own SBOM.

**Assembly merge creates:**

```text
dev-toolkit v1.0.0 (Application)
├── docker-desktop v4.25.0 (Sub-component)
├── vscode v1.85.0 (Sub-component)
├── postman v10.20.0 (Sub-component)
├── docker-engine       <-- TOP LEVEL
├── docker-compose      <-- TOP LEVEL
├── electron            <-- TOP LEVEL
├── nodejs              <-- TOP LEVEL
└── shared-libs         <-- TOP LEVEL
```

Each tool keeps its identity as a sub-component, but all their dependencies are at the top level. You can see what tools are in the suite (the sub-components), but you don't need the deep nesting of each tool's internal dependency tree.

### How Dependencies Are Handled

- Original dependencies from input SBOMs remain **unchanged** in the final SBOM
- Primary components are nested under the new root, but their dependency relationships stay intact

## 4. Augment Merge

The three merge strategies we've covered so far—hierarchical, flat, and assembly—all combine multiple SBOMs into a new one. But what if you don't want a new SBOM? What if you just want to add more information to your existing SBOM—like vulnerability scan results or license data? That's when you use augment merge.

**Concept**: Enriches the primary SBOM with data from external sources or its own vulnerability data or license scan data. This is fundamentally different from the other strategies.

### Visual Overview

```text
Other Merges:  NEW ROOT <-- SBOM A + SBOM B + SBOM C
Augment Merge: PRIMARY <-- PRIMARY + (vulnerability scan results) + (license scan data)
```

**Think**: "Update/Enrich" not "Combine/Assemble"

### How It Works

1. **Component Matching**: Components are matched between primary and secondary SBOMs using:
   - Name
   - Version
   - PURL
   - CPE

2. **Two Modes**:
   - `if-missing-or-empty` (default): Only fills fields that are empty/missing in primary
   - `overwrite`: Replaces primary fields with secondary values

3. **What Gets Merged**:
   - Description, Author, Publisher, Group
   - Scope, Copyright
   - PackageURL, CPE, SWID
   - Supplier, Licenses, Hashes
   - ExternalReferences, Properties

### When to Use

| Scenario | Example |
|----------|---------|
| Add vulnerability scan results | Enrich base SBOM with Trivy/Grype scan results |
| Add license scan data | Enrich with FOSSology or ScanCode license data |
| Merge vendor SBOM | Combine internal SBOM with vendor-provided SBOM |
| Progressive enhancement | Multiple passes with different data sources |

### Real-World Example: Enriching with Vulnerability Scan

You have a base SBOM and want to add vulnerability data from a security scan:

```text
Input:
- base-sbom.cdx.json (your application SBOM)
- vuln-scan.cdx.json (scan results with CVEs)

Augment Merge Output:
base-sbom.cdx.json (ENRICHED)
├── Same components as before
├── Same dependencies as before
└── NEW: vulnerabilities section with CVE data
```

**Key Characteristics**:

- ❌ Does NOT create a new root
- ✅ Preserves the primary SBOM's identity and version
- ✅ Merges matching components, adds non-matching ones
- ✅ Best for **enriching** existing SBOMs with additional data

### How Dependencies Are Handled

- Only includes dependencies involving **added or merged components**
- Dependencies from the secondary SBOMs are **filtered** to include only those relevant to merged components
- Invalid dependency references (pointing to non-existent components) are automatically filtered out
- All dependency references are validated against the primary SBOM

## sbomasm: Bringing Strategies to Life

Now that we've walked through all four merge strategies conceptually—when to use each and how dependencies flow—let's put them into practice. Here's how sbomasm implements each strategy.

**sbomasm** is a command-line tool from Interlynk that makes SBOM assembly, editing, and enrichment straightforward. It supports both CycloneDX and SPDX formats, and implements all four merge strategies we've discussed.

### Strategy Flags in sbomasm

| Strategy | sbomasm Flag | Creates New Root? |
|----------|-------------|------------------|
| Hierarchical | `-m` (default) | ✅ Yes |
| Flat | `-f` | ✅ Yes |
| Assembly | `-a` | ✅ Yes |
| Augment | `--augmentMerge` | ❌ No |

## Hands-On with sbomasm

### Hierarchical Merge: Kubernetes Microservices

Remember our e-commerce platform with four microservices? Here's how to create a unified SBOM:

```bash
sbomasm assemble \
  -n "ecommerce-platform" \
  -v "1.0.0" \
  -t application \
  frontend-svc.cdx.json \
  api-gateway.cdx.json \
  payment-svc.cdx.json \
  order-svc.cdx.json \
  -o ecommerce-platform.cdx.json
```

**Result**: Each service becomes a sub-component with its dependencies nested underneath.

### Flat Merge: Multi-Platform Python Application

Merging platform-specific builds of the same Python application:

```bash
sbomasm assemble --flat-merge \
  -n "cs.template" \
  -v "2026.2.3.0" \
  -t application \
  cs.template.linux.python_sbom.cdx.json \
  cs.template.win32.python_sbom.cdx.json \
  -o cs.template.unified.cdx.json
```

**Result**: Single SBOM with deduplicated Python libraries (idna, multidict, yarl, etc.).

### Assembly Merge: Security Toolkit

Creating a security toolkit SBOM:

```bash
sbomasm assemble --assembly-merge \
  -n "security-toolkit" \
  -v "1.0.0" \
  -t application \
  cosign.json \
  syft.json \
  grype.json \
  trivy.json \
  -o security-toolkit.cdx.json
```

**Result**: Each tool is a sub-component; all dependencies are at top level with original relationships preserved.

### Augment Merge: Adding Scan Results

Enriching your base SBOM with vulnerability scan data:

```bash
sbomasm assemble --augmentMerge \
  --primary base-sbom.cdx.json \
  vuln-scan-results.cdx.json \
  -o enriched-sbom.cdx.json
```

**Note**: No `-n/-v/-t` flags needed — the primary SBOM's identity is preserved.

## Summary

| Strategy | Creates New Root? | Use When | sbomasm Flag |
|----------|------------------|----------|--------------|
| **Hierarchical** | Yes | Merging SBOMs of **different** components (microservices) | `-m` |
| **Flat** | Yes | Merging SBOMs of the **same** software (platform variants) | `-f` |
| **Assembly** | Yes | Bundling **related but independent** products | `-a` |
| **Augment** | No | **Enriching** an existing SBOM with scan/vendor data | `--augmentMerge` |

## Choosing Your Strategy

Picking the right merge strategy comes down to one question: **what are you trying to achieve?**

- **Different services/platforms** that need to stay distinct? --> Hierarchical
- **Same software, different builds** that should combine into one list? --> Flat
- **Independent products** bundled together? --> Assembly
- **Add data** to an existing SBOM? --> Augment

Start with your goal, and the strategy follows.

## Wrapping Up

If you started this post wondering how to combine multiple SBOMs into one unified document, you now have four different approaches—and you know exactly when to use each. Whether you're bringing together microservices, platform builds, product suites, or enriching with scan data, there's a merge strategy that fits.

The key is matching your goal to the right approach. Start there, and sbomasm handles the rest.

Ready to try it? Grab sbomasm from GitHub and start merging.

## Resources

- sbomasm GitHub: <https://github.com/interlynk-io/sbomasm>
- Documentation: <https://github.com/interlynk-io/sbomasm/tree/main/docs>
- CycloneDX Spec: <https://cyclonedx.org/specification/overview/>
- SPDX Spec: <https://spdx.dev/specifications/>

If you loved this project, show the love back by starring ⭐ the [repo](https://github.com/interlynk-io/sbomasm).

Have questions or need help with a specific use case? File an [issue](https://github.com/interlynk-io/sbomasm/issues/new), we'd love to help!