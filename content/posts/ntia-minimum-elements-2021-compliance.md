+++
date = '2026-01-28T22:50:46+05:30'
draft = false
title = 'SBOM Compliance Series (Part 1): Understanding NTIA Minimum Elements'
categories = ['SBOM', 'Compliance', 'NTIA']
tags = ['SBOM', 'quality', 'scoring', 'compliance', 'ntia']
author = 'Vivek Sahu'
+++

In this blog, we’ll be discussing about NTIA minimum element SBOM Compliance.

This blog is the first part of an SBOM compliance series. The series is about covering all different SBOM compliances framework one by one and understand why they exist and what they actually expect from an SBOM and lastly to check whether your SBOM is compliant or not.

Before diving into NTIA minimum element compliance specifically, let’s understand the core of SBOM:

> What does SBOM compliance mean and it's motive ?

SBOM compliance refers to regulatory or policy requirements defined by the governments or organization that specify what information an SBOM should/must contain. The core motive behind SBOM compliance is **transparency in complex software systems**. Modern software is built by assembling many components: commercial software from vendors, open source libraries, and dependency maitained by projects across the world. Without transparency, it becomes difficult to understand, what software is actually being used, where it comes from, and what risks may be ontroduced through dependencies into your software.

Now let's get idea on how NTIA minimum element compliance came into existance. After one by one big software supply chain attack like SolarWind, Log4J, etc the U.S. Federal Government NTIA (National Telecommunications and Information Administration) came into action and signed an Executive Order to bring SBOM compliance framework with a motive to bring transparency into complex software system and hence published "minimum elements required for SBOM(Software Bill Of Materials)". As government agencies itself rely on software from corporate/private companies. Those companies, in turn, rely heavily on open-source components maintained by projects anywhere around the world. Without clear visibility into these dependency chains, it become shard to figure out risks hidden behind it.

## What are the NTIA minimum elements fields required for SBOM?

### 1. Component Identity: Name, Version, Supplier

Official definition:
> **Name** assigned to the component by the supplier.

> **Version** identifier used to distinguish a specific release.

> **Supplier** is the name of an entity that creates, defines, and identifies components.

NTIA requires every component to declare: **Name**, **Version** and **Supplier**. These 3 fields together establish component identity. Without it, you cannot know which component you are consuming, neither could track existing vulnerabilities and nor compare SBOM b/w different releases, etc. Now let's see mapping of these fields to a SPDX and CycloneDX SBOM.

**SBOM Mapping**:

- SPDX:
  - Name: `PackageName`
  - Version: `PackageVersion`
  - Supplier: `PackageSupplier`

- CycloneDX:
  - Name: `component.name`
  - Version: `component.version`
  - Supplier: `component.supplier`(`component.manufacturer` may be used as a fallback)

### 2. Other Unique Identifiers (PURL, CPE, SWID, etc.)

Official definition:
> At least one additional identifier if available (e.g., CPE, PURL, SWID).

Names and versions work well, but when it comes to uniquely identifying component across software world, then their comes unique identifiers such as PURLs, CPEs. It enables mapping of existing vulnerabilities to a component.

**SBOM mapping**:

- SPDX
  - `ExternalRef`(type `SECURITY`) (e.g. purl, cpe23Type)

- CycloneDX
  - `component.purl`
  - `component.cpe`

### 3. Dependency Relationships (Top-Level Focus)

Official definition:
> NTIA defines Dependency Relationship as the directional inclusion of upstream components in a primary software component. At minimum, top-level dependencies or explicit completeness declarations must be present. Full transitive depth is encouraged but not required.

NTIA requires that an SBOM declare the upstream dependency relationships of the *primary (top-level) component*.

- At a minimum, the SBOM must list the primary component's direct dependencies
- or declare completeness if no dependencies exist.

**SBOM mapping**:

- SPDX
  - Relationship entries such as `DEPENDS_ON`
  - dependency completess not supported

- CycloneDX
  - dependencies graph(`depends_on`)
  - dependency completeness via composition metadata

It helps to identify what all direct and transitive dependencies your software consumes. And it plays an important role in software supply chain.

### 4. Author of SBOM data

Official Definition:
> Author reflects the source of the metadata, which could come from the creator of the software being described in the SBOM, the upstream component supplier, or some third-party analysis tool.

**SBOM mapping**:

- SPDX
  - `CreationInfo.Creators` (Person, Organization, or Tool)

- CycloneDX
  - `metadata.authors`
  - `metadata.tools`
  - `metadata.supplier`/`metadata.manufacture`(fallback)

### 5. Creation Timestamp

> It represent the timestamp of the creation of the SBOM.

**SBOM mapping**:

- SPDX
  - `CreationInfo.Created`  

- CycloneDX
  - `metadata.timestamp`

## NTIA minimum field summary table

| Check ID                  | NTIA Field               | Required     | SPDX Mapping                                              | CycloneDX Mapping                                                 |
| ------------------------- | ------------------------ | ------------ | --------------------------------------------------------- | ----------------------------------------------------------------- |
| `comp_with_supplier`      | Supplier                 | Yes          | [PackageSupplier](https://spdx.github.io/spdx-spec/v2.3/package-information/#75-package-supplier-field) (preferred), [PackageOriginator](https://spdx.github.io/spdx-spec/v2.3/package-information/#76-package-originator-field) (fallback) | [component.supplier](https://cyclonedx.org/docs/1.6/json/#components_items_supplier) (preferred), [component.manufacturer](https://cyclonedx.org/docs/1.6/json/#components_items_manufacturer) (fallback) |
| `comp_with_name`          | Component Name           | Yes          | [PackageName](https://spdx.github.io/spdx-spec/v2.3/package-information/#71-package-name-field)                                               | [component.name](https://cyclonedx.org/docs/1.6/json/#components_items_name)                                                    |
| `comp_with_version`       | Component Version        | Yes          | [PackageVersion](https://spdx.github.io/spdx-spec/v2.3/package-information/#73-package-version-field)                                            | [component.version](https://cyclonedx.org/docs/1.6/json/#components_items_version)                                                 |
| `comp_with_uniq_ids`      | Other Unique Identifiers | Conditional* | [ExternalRef](https://spdx.github.io/spdx-spec/v2.3/package-information/#721-external-reference-field) (PURL, CPE, SWID, etc.)                       | [component.purl](https://cyclonedx.org/docs/1.6/json/#components_items_purl), [component.cpe](https://cyclonedx.org/docs/1.6/json/#components_items_cpe)                                     |
| `sbom_dependencies`       | Dependency Relationship  | Yes          | [Relationship](https://spdx.github.io/spdx-spec/v2.3/relationships-between-SPDX-elements/#111-relationship-field) (DEPENDS_ON )                      | [dependencies](https://cyclonedx.org/docs/1.6/json/#dependencies_items_dependsOn) graph(depends_on)                                                |
| `sbom_authors`            | Author of SBOM Data      | Yes          | [CreationInfo.Creators](https://spdx.github.io/spdx-spec/v2.3/document-creation-information/#68-creator-field)                                     | [metadata.authors](https://cyclonedx.org/docs/1.6/json/#metadata_authors) / [metadata.tools](https://cyclonedx.org/docs/1.6/json/#metadata_tools) (fallbacks allowed)             |
| `sbom_creation_timestamp` | Creation Timestamp       | Yes          | [CreationInfo.Created](https://spdx.github.io/spdx-spec/v2.3/document-creation-information/#69-created-field)                                      | [metadata.timestamp](https://cyclonedx.org/docs/1.6/json/#metadata_timestamp)                                                |

## How to evaluate your SBOM against NTIA minimum element compliance

At this point, we’ve looked at **why NTIA SBOM compliance exists** and **what each required field represents**.
The next natural question is:

> How do you actually check whether your SBOM meets NTIA requirements?

This is where [sbomqs](https://github.com/interlynk-io/sbomqs) comes in.

**sbomqs** is an open-source tool designed to evaluate SBOMs after SBOM is generated.
It focuses on two closely related aspects:

- SBOM quality scoring, and
- SBOM compliance validation

Now, let quickly check SBOM quality score:

```bash
sbomqs score samples/photon.sbom.spdx.json --profile ntia
```

And o/p is:

```bash
SBOM Quality Score: 5.7/10.0	 Grade: D	Components: 38 	 EngineVersion: 5	File: samples/photon.spdx.json


+------------------------------+--------------------+-----------+--------------------------------+
|           PROFILE            |      FEATURE       |  STATUS   |              DESC              |
+------------------------------+--------------------+-----------+--------------------------------+
| NTIA Minimum Elements (2021) | comp_supplier      | 0.0/10.0  | supplier or manufacturer       |
|                              |                    |           | information missing for all 38 |
|                              |                    |           | components                     |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_name          | 10.0/10.0 | name declared for all          |
|                              |                    |           | components                     |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_version       | 9.7/10.0  | version declared for 37 of 38  |
|                              |                    |           | components                     |
+                              +--------------------+-----------+--------------------------------+
|                              | comp_uniq_id       | 0.0/10.0  | unique identifier missing for  |
|                              |                    |           | all 38 components              |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_relationships | 0.0/10.0  | primary component declares     |
|                              |                    |           | no direct dependencies and     |
|                              |                    |           | does not declare relationship  |
|                              |                    |           | completeness                   |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_authors       | 10.0/10.0 | SBOM author inferred from SBOM |
|                              |                    |           | generation tool                |
+                              +--------------------+-----------+--------------------------------+
|                              | sbom_timestamp     | 10.0/10.0 | SBOM creation timestamp        |
|                              |                    |           | declared                       |
+------------------------------+--------------------+-----------+--------------------------------+


Summary:
Required Fields : 3/7 compliant

Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```

where, `profile` represent specific compliance such as `ntia`, `fsct`, `bsi`, etc. In future we will also support profiling beyong compliance, which will more specifically based on a use cases.

The above o/p shows overall quality of an SBOM against NTIA minimum elements in a summarized way.

And similarly run below command to check compliance in detailed.

```bash
sbomqs compliance --ntia samples/photon.spdx.json
NTIA Report
Compliance score by Interlynk Score:3.3 RequiredScore:6.6 OptionalScore:0.0 for samples/photon.spdx.json
* indicates optional fields
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+
|             ELEMENT ID              | SECTION ID |     NTIA MINIMUM ELEMENTS     |                              RESULT                              | SCORE |
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+
| Automation Support                  |        1.1 | Machine-Readable Formats      | spdx, json                                                       |  10.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        1.2 | SBOM generation tool declared | tern-b8e13d1780cd3a02204226bba3d0772d95da24a0                    |  10.0 |
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+
| Required Document-level             |        2.1 | Author                        | SBOM author inferred from SBOM tool:                             |  10.0 |
|                                     |            |                               | tern-b8e13d1780cd3a02204226bba3d0772d95da24a0                    |       |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.2 | Timestamp                     | 2023-01-12T22:06:03Z                                             |  10.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.3 | Dependencies                  | primary component has no                                         |   0.0 |
|                                     |            |                               | top-level relationships and                                      |       |
|                                     |            |                               | nor declare relationships                                        |       |
|                                     |            |                               | completeness                                                     |       |
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+
| ad1f1c6f4fef...ad7fdeff-            |        2.4 | Package Name                  | ad1f1c6f4fef6e6208ebc53e701bf9937f4e05dce5f601b20c35d8a0ad7fdeff |  10.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.6 | Package Supplier              | supplier not declared                                            |   0.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.7 | Package Version               |                                                                  |   0.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.8 | Other Uniq IDs                | no unique identifier declared                                    |   0.0 |
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+
| bash-4.4.18-4.ph3                   |        2.4 | Package Name                  | bash                                                             |  10.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.6 | Package Supplier              | supplier not declared                                            |   0.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.7 | Package Version               | 4.4.18-4.ph3                                                     |  10.0 |
+                                     +------------+-------------------------------+------------------------------------------------------------------+-------+
|                                     |        2.8 | Other Uniq IDs                | no unique identifier declared                                    |   0.0 |
+-------------------------------------+------------+-------------------------------+------------------------------------------------------------------+-------+

...
continue remaining components
```

The compliance evaluate in detailed for each component and NTIA fields for each components. So, it gives you clear idea about how complete your SBOM is with compare to SBOM compliance required fields. You exactly know what's missing and what's not. 

This makes it easy to see:

- how complete each component’s data is,
- which required fields are present,
- which fields are missing or incomplete, and
- how closely the SBOM aligns with NTIA compliance expectations.

## Conclusion and what's next

In this post, we have discussed SBOM compliance and its core motivation:bringing transparency to complex software systems. We discuss at how compliance frameworks like NTIA Minimum Elements are designed to support this goal by focusing on essentials fields like, component identity, dependency relationships, authorship, and time context, NTIA makes SBOMs usable and trustworthy, without demanding exhaustive detail.

Then we discussed about these fields sigificance and mappings into SPDX and CycloneDX SBOM, and this a real industry usecase to deal with field into your SBOMs. Then we discussed on checking whether your SBOM si compliant or not using sbomqs tool which helps you to evaluate SBOMs against NTIA expectations by checking both quality and compliance, making it easier to identify missing information, inferred data, and areas for improvement.

In the next post of this series, we’ll move beyond minimum elements and look at **Framing Software Component Transparency** (FSCT), a framework that builds on NTIA concepts and goes deeper into how software components are described, related, and contextualized.