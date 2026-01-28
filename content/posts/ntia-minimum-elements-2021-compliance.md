+++
date = '2026-01-28T22:50:46+05:30'
draft = false
title = 'SBOM Compliance Series (Part 1): Understanding NTIA Minimum Elements'
categories = ['Automation', 'Tools']
tags = ['SBOM', 'GitHub', 'Monitoring', 'sbommv', 'Open Source', 'Supply Chain', 'Automation']
author = 'Vivek Sahu'
+++

In this blog, we’ll start learning about NTIA SBOM Compliance.

This post is the 1st part of an SBOM compliance series, where we’ll look at different SBOM compliance frameworks one by one and understand why they exist and what they actually expect from an SBOM.

Before diving into NTIA specifically, let’s answer a basic question: What does SBOM compliance mean ? SBOM compliance refers to regulatory or policy requirements defined by the governments or organization that specify what information an SBOM must contain. The the core motive behind SBOM compliance is **transparency in complex software systems**. Modern software is built by assembling many components: commercial software from vendors, open source libraries, and dependency mained by projects across the world. Without transparency, it becomes difficult to understand that, what software is actually being used, where it comes from, and what risks may be ontroduced through dependencies.

To get bit idea on how NTIA compliance came into existance. After one by one big software supply chain attack like SolarWind, Log4J, etc the U.S. government came into action and signed an Executive Order to bring compliance framework with a motive to bring transparency into complex software system. As government agencies itself rely on software from corporate world. Those companies, in turn, rely heavily on open-source components maintained by projects anywhere in the world. Without clear visibility into these dependency chains, it become shard to figure out risks hidden behind it.

## How NTIA minimum elements fields support the goal of transparency

### 1. Component Identity: Name, Version, Supplier

Official definition:
> Name assigned to the component by the supplier.
> Version identifier used to distinguish a specific release.
> Supplier is the name of an entity that creates, defines, and identifies components.

NTIA requires every component to declare: Name, Version and Supplier. These 3 fields together establish component identity. Without it, you cannot track vulnerabilities, compare SBOM b/w different releases, etc. Now let's map these fields to SPDX and CycloneDX SBOM.

SBOM Mapping:

- SPDX:
  - Name: `PackageName`
  - Version: `PackageVersion`
  - Supplier: `PackageSupplier`

- CycloneDX:
  - Name: `component.name`
  - Version: `component.version`
  - Supplier: `component.supplier`(`component.manufacturer` may be used as a fallback)

### 2. Other Unique Identifiers (PURL, CPE, etc.)

Official definition:
> At least one additional identifier if available (e.g., CPE, PURL, SWID).

Names and versions work well, but when it comes to uniquely identifying component across software, then their comes unique identifiers such as PURLs, CPEs. It enables mapping of existing vulnerabilities to a component.

SBOM mapping:

- SPDX
  - `ExternalRef`(type `SECURITY`) (e.g. purl, cpe23Type)

- CycloneDX
  - `component.purl`
  - `component.cpe`

### 3. Dependency Relationships (Top-Level Focus)

NTIA says:
> NTIA defines Dependency Relationship as the directional inclusion of upstream components in a primary software component. At minimum, top-level dependencies or explicit completeness declarations must be present. Full transitive depth is encouraged but not required.

What it requires is clarity at the top level:

> Which upstream components are directly included in the primary software?

This answers a fundamental question:

> What is my software immediately composed of?

From there, deeper dependency analysis can happen recursively.

Equally important, NTIA requires SBOMs to distinguish between:

- no dependencies, and
- complete or unknown or incomplete dependency data.

SBOM mapping:

- SPDX
  - Relationship entries such as `DEPENDS_ON`
  - dependency completess not supported

- CycloneDX
  - dependencies graph(`depends_on`)
  - dependency completeness via composition metadata

### 4. Author of SBOM data

Official Definition:
> Author reflects the source of the metadata, which could come from the creator of the software being described in the SBOM, the upstream component supplier, or some third-party analysis tool.

NTIA also asks a simple but critical question:

> Who created this SBOM data?

This is not about who wrote the software.
It’s about who is asserting the metadata.

That author may be:

- the software creator,
- an upstream supplier, or
- an automated SBOM generation tool.

Knowing the source of the SBOM helps consumers judge:

- how the SBOM was generated,
- how repeatable it is,
- and who to contact if issues arise.

SBOM mapping:

- SPDX
  - `CreationInfo.Creators` (Person, Organization, or Tool)

- CycloneDX
  - `metadata.authors`
  - `metadata.tools`
  - `metadata.supplier`/`metadata.manufacture`(fallback)

### 5. Creation Timestamp

The timestamp answers a basic but essential question:

> When was this snapshot of the software taken?

SBOM mapping:

- SPDX
  - `CreationInfo.Created`  

- CycloneDX
  - `metadata.timestamp`

## Summary Table

| Check ID                  | NTIA Field               | Required     | SPDX Mapping                                              | CycloneDX Mapping                                                 |
| ------------------------- | ------------------------ | ------------ | --------------------------------------------------------- | ----------------------------------------------------------------- |
| `comp_with_supplier`      | Supplier                 | Yes          | PackageSupplier (preferred), PackageOriginator (fallback) | component.supplier (preferred), component.manufacturer (fallback) |
| `comp_with_name`          | Component Name           | Yes          | PackageName                                               | component.name                                                    |
| `comp_with_version`       | Component Version        | Yes          | PackageVersion                                            | component.version                                                 |
| `comp_with_uniq_ids`      | Other Unique Identifiers | Conditional* | ExternalRef (PURL, CPE, SWID, etc.)                       | component.purl, component.cpe                                     |
| `sbom_dependencies`       | Dependency Relationship  | Yes          | Relationship (DEPENDS_ON )                      | dependencies graph                                                |
| `sbom_authors`            | Author of SBOM Data      | Yes          | CreationInfo.Creators                                     | metadata.authors / metadata.tools (fallbacks allowed)             |
| `sbom_creation_timestamp` | Creation Timestamp       | Yes          | CreationInfo.Created                                      | metadata.timestamp                                                |

## How to Evaluate Your SBOM Against NTIA Compliance

At this point, we’ve looked at **why NTIA SBOM compliance exists** and **what each required field represents**.
The next natural question is:

> How do you actually check whether your SBOM meets NTIA requirements?

This is where [sbomqs](https://github.com/interlynk-io/sbomqs) comes in.

**sbomqs** is an open-source tool designed to evaluate SBOMs, not generate them.
It focuses on two closely related aspects:

- SBOM quality scoring, and
- SBOM compliance validation

Now, let quickly check SBOM quality score:

```bash
sbomqs score samples/photon.sbom.spdx.json --profile ntia
SBOM Quality Score: 5.7/10.0	 Grade: D	Components: 38 	 EngineVersion: 4	File: samples/photon.spdx.json


+------------------------------+--------------------+-----------+--------------------------------+
|           PROFILE            |      FEATURE       |  STATUS   |              DESC              |
+------------------------------+--------------------+-----------+--------------------------------+
| NTIA Minimum Elements (2021) | comp_supplier      | 0.0/10.0  | add to 38 components           |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_name          | 10.0/10.0 | complete                       |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_version       | 9.7/10.0  | add to 1 component             |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_uniq_id       | 0.0/10.0  | add to 38 components           |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_relationships | 0.0/10.0  | primary component has no       |
|                              |                    |           | top-level relationships and    |
|                              |                    |           | nor declare relationships      |
|                              |                    |           | completeness                   |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_authors       | 10.0/10.0 | SBOM author inferred from SBOM |
|                              |                    |           | tool                           |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_timestamp     | 10.0/10.0 | complete                       |
+------------------------------+--------------------+-----------+--------------------------------+


Summary:
Required Fields : 3/7 compliant

Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```