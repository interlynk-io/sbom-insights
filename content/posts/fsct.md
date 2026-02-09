+++
date = '2026-02-09T18:38:10+05:30'
draft = false
title = 'SBOM Compliance Series (Part 2): Understanding Framing Software Component Transparency (FSCT)'
categories = ['SBOM', 'Compliance', 'FSCT']
tags = ['SBOM', 'quality', 'completeness', 'compliance', 'fsct', 'declaration']
author = 'Vivek Sahu'
+++

This is the second part of our SBOM compliances series. In the [previous post](https://sbom-insights.dev/posts/ntia-minimum-elements-2021-compliance/), we discussed NTIA Minimum Elements, their motivation, and how they define a baseline for SBOM transparency. In this post, we will discuss about **Framing Software Component Transparency (FSCT)**, why it came into existence, the real-world gaps it addresses, and how it shifts the focus from minimum presence to meaningful transparency. Let's go.

In order to manage risk, cost or security, an organization first need to understand what is software made up of, what all components are being used, and how they depend on each other. In the modern software world, systems are complex because they rely on dynamic supply chains i.e. consuming open-source libraries, commercial software, and third parties dependencies maintained across the world. Without clear visibility into these dependencies(or supply chain), organizations are forced to rely on assumptions rather than facts. That's why NTIA Minimum Elements came in and introduced required set of minimum SBOM fields to ensure the basic information about each consumed component is present or declared, and with this it laids the foundation of establishing a transparency across software supply chains.

But in practice, SBOM consumers often struggled to make sense of missing information. It was difficult to understand whether a missing field meant the data was unknown, not applicable, or simply not declared. Without this missing context, it became difficult to reason about how complete an SBOM actually was and what assumptions could safely be made. This is when organizations realized they needed guidance not only on what data should exist, but also on how that data is declared, how complete it is, and how much confidence can be placed in it.

To address gaps around completeness, explicit declaration, and transparency, FSCT was created. It emerged from a multistakeholder effort led by NTIA and was later adopted by **CISA**, with the goal of improving how SBOM data is declared and understood, not achieving perfection. According to FSCT, an SBOM is a machine-readable inventory of software components, their dependencies, and the relationships between them, and it should clearly state where information is unknown or incomplete. When information is unknown, missing, or out of scope, leaving the field empty creates ambiguity. **Silence is not transparency; declaring “unknown” is**. For this reason, FSCT favors clear declarations over assumptions and treats coverage across components as a meaningful signal of transparency. If NTIA asks, “*Does this SBOM meet the minimum requirements?*”, FSCT instead asks, “*How transparent, complete, and trustworthy is this SBOM?*”, and that's why FSCT exists alongside NTIA, not instead of it.

Now, let's discuss the required elements for SBOM.

## Framing Software Component Transparency(FSCT) required elements for SBOM

### 1. SBOM Provenance(SBOM Author + SBOM Creation Timestamp)

Provenance describes the context behind who produced the SBOM and when it was produced. It establishes trust in the SBOM itself.

SBOM Author official definition:
> An SBOM must list the entity that prompted the creation of the SBOM.

It refers to the responsible entity, such as an organization, person, or supplier that caused the SBOM to be created. The tool used to generate the SBOM may be recorded as tooling metadata, but **FSCT does not consider the tool to be the SBOM author**.

SBOM Timestamp official definition:
> The Timestamp is the date and time that the SBOM was produced.

This requirement reflects FSCT’s core principle: transparency through explicit declaration. An SBOM may list components and dependencies, but without provenance, its context and trustworthiness remain unclear.

**SBOM Mapping of SBOM Authors**:

- SPDX:
  - `CreationInfo.Creators`(Person/Organization)

- CycloneDX:
  - `metadata.authors`

Any value would be considered:

- name
- email
- contact

**SBOM Mapping of SBOM Timestamp**:

- SPDX:
  - `CreationInfo.Created`

- CycloneDX:
  - `metadata.timestamp`

### 2 Primary Component (SBOM Subject)

SBOM Primary Component official definition:
> The Primary Component, or root of Dependencies, is the subject of the SBOM or the foundational Component being described in the SBOM.

The primary component represents the software that the SBOM is actually describing. It is the root of the dependency graph and serves as the reference point for understanding which components are included, how they relate to each other, and how dependency information should be interpreted.

**SBOM Mapping of SBOM Primary Component**:

- SPDX:
  - `DocumentDescribes`

- CycloneDX:
  - `metadata.component`

### 3. Component Identity(Component Name + Version)

Component Identity as the minimum information required to uniquely and consistently identify a software component.

Component Name official definition:
> The Component name should declare the commonly used public name for the Component. The Component Name is defined as the public name for a Component defined by the Originating Supplier of the Component.

Component Version official definition:
> The version string as provided by the Supplier. The Version is a supplier-defined identifier that specifies an update change in the software from a previously identified version.

FSCT treats name and version as inseparable. Declaring only one of them does not provide sufficient identity.

**Mapping of Component Name**:

- SPDX:
  - Name: `PackageName`

- CycloneDX:
  - Name: `component.name`

**Mapping of Component Version**:

- SPDX:
  - Version: `PackageVersion`

- CycloneDX:
  - Version: `component.version`

### 4. Supplier Attribution

Supplier official definition:
> The Supplier Name should be declared for all Components. Supplier Name is the entity that creates, defines, and identifies a Component.

FSCT requires supplier information to be explicitly declared for all components. When the supplier cannot be determined, it should be explicitly stated, rather than omitted. This aligns with FSCT’s principle that declaring “unknown” is preferable to leaving information absent.

**Mapping of Component Supplier**:

- SPDX:
  - Supplier: `PackageSupplier`

- CycloneDX:
  - Supplier: 
    - `component.supplier`
    - `component.manufacturer`

### 5. Unique Identification

Unique ID official definition
> At least one unique identifier should be declared for each Component listed in the SBOM. A globally unique identifier is preferred.

While component name and version establish basic identity, FSCT recognizes that they are often not sufficient on their own to uniquely identify components across ecosystems, registries, and vulnerability databases.

Accepted unique identifiers include:

- PURL (Package URL)
- CPE (Common Platform Enumeration)
- SWHID (Software Heritage Identifier)
- SWID (Software Identification Tag)
- Omnibor ID

**Mapping of Unique Identifier**:

- SPDX:
  - ExternalRef(type `SECURITY`):
    - `purl`
    - `cpe23Type`

- CycloneDX:
  - `component.purl`
  - `component.cpe`
  - `component.omniborId`
  - `component.swhid`
  - `component.swid`

### 6. Artifact Integrity (Cryptographic Hashes)

Cryptographic Hashes official definition
> Provide a hash for any Component listed in the SBOM for which the hash was provided or sufficient information is available to generate the hash. If sufficient information is not available, indicate as unknown.

**Mapping of Cryptographic Hashes**:

- SPDX:
  - `PackageChecksum`

- CycloneDX:
  - `component.hashes`

### 7. Dependency Relationships & Completeness

Dependency Relationship official definition
> Relationships and relationship completeness declared for the Primary Component and direct Dependencies.

FSCT treats dependency relationships as more than just a list of components. It requires **explicit declarations about whether dependency information is complete, incomplete, or unknown**.

The key idea is this:

> If a component appears in the dependency graph, the SBOM must clearly state whether its dependency information is complete.

Declaring “unknown”/"incomplete" is acceptable. Failing to declare completeness at all is not.

**Requirements**:

- For the Primary component:
  - its direct dependencies, must be declared(if exists) and
  - dependency completeness must be explicitly stated
(complete, incomplete, or unknown)

- For each direct dependency
  - dependency completeness must also be explicitly declared
(even if that dependency has no further dependencies)

FSCT does not require:

- full transitive dependency graphs, or
- complete knowledge of all downstream components

### 8. License Coverage

License official definition
> Minimum: Provide license information for the Primary Component.
> Recommended Practice: Provide license information for as many Components as possible.
> Aspirational Goal: Provide license information for all listed SBOM Components. Attestation of Concluded License information, i.e., license text and concluded terms and conditions, is included in the SBOM.

FSCT treats license information as a **coverage-based attribute**, not a strict per-component requirement at the minimum level. The intent is to progressively improve transparency as SBOM practices mature.

**Mapping of Licenses**:

- SPDX:
  - `PackageLicenseConcluded`
  - `PackageLicenseDeclared`

- CycloneDX:
  - `component.licenses`

### 9. Copyright Coverage

Copyright official definition
> Minimum: Provide copyright notice for the Primary Component.
> Recommended Practice: Provide copyright notice for as many Components as possible.
> Aspirational Goal: Provide copyright notice for all listed SBOM Components

Like license information, FSCT treats copyright as a **coverage-based attribute** that improves in maturity over time.

**Mapping of Licenses**:

- SPDX:
  - `PackageCopyrightText`

- CycloneDX:
  - `component.copyright`

## Framing Software Component Transparency(FSCT) field summary table

| Check ID                 | FSCT Signal                 | Type                      | SPDX Mapping                                | CycloneDX Mapping                      |
| ------------------------ | --------------------------- | ------------------------- | ------------------------------------------- | -------------------------------------- |
| `sbom_provenance`        | SBOM Provenance(SBOM Author + Timestamp)             | Baseline (binary)         | CreationInfo.Creators + CreationInfo.Created | metadata.authors + metadata.timestamp   |
| `sbom_primary_component` | Primary Component Defined   | Baseline (binary)         | DocumentDescribes                           | metadata.component                     |
| `comp_identity`          | Component Identity          | Baseline (binary)         | PackageName + PackageVersion                | component.name + component.version     |
| `supplier_attribution`   | Supplier Attribution        | Baseline (binary)         | PackageSupplier                             | component.supplier                     |
| `comp_unique_id`         | Unique Identification       | Baseline (binary)         | ExternalRef (PURL, CPE, etc.)               | component.purl, component.cpe, component.swhid, component.swid, component.omniborId          |
| `artifact_integrity`     | Artifact Integrity (Hashes) | Baseline (binary)         | PackageChecksum                             | component.hashes                       |
| `relationships_coverage` | Dependency Relationships    | Baseline (primary + deps) | Relationship (DEPENDS_ON) + composition     | dependencies + dependency completeness |
| `license_coverage`       | License Coverage            | Coverage-based            | PackageLicenseDeclared                      | component.licenses                     |
| `copyright_coverage`     | Copyright Coverage          | Coverage-based            | PackageCopyrightText                        | component.copyright                    |

## Evaluation of your SBOM against Framing Software Component Transparency(FSCT)

So far, we’ve discussed **why FSCT exists, what problems it is trying to solve**, and **what information FSCT expects an SBOM to declare**.
The next natural question is:

> How do you evaluate whether an SBOM aligns with FSCT expectations?

This is where sbomqs can help.

**sbomqs** is an open-source tool that evaluates SBOMs after they are generated. For FSCT specifically, sbomqs focuses on transparency and declaration, not just scoring.

It evaluates:

- whether required attributes are explicitly declared,
- whether coverage expectations are met (minimum, recommended, aspirational), and
- whether gaps are clearly stated instead of silently omitted.

Run a simple command to evaluate fsct:

```bash
sbomqs score samples/sbom_cdx.json --profile fsct
```

And the o/p is:

```bash
SBOM Quality Score: 4.4/10.0	 Grade: F	Components: 117 	 EngineVersion: 5	File: samples/sbom_cdx.json


+--------------------------------+------------------------+-----------+--------------------------------+
|            PROFILE             |        FEATURE         |  STATUS   |              DESC              |
+--------------------------------+------------------------+-----------+--------------------------------+
| Framing 3rd Edition Compliance | sbom_provenance        | 10.0/10.0 | SBOM provenance: creation      |
|                                |                        |           | timestamp present; author      |
|                                |                        |           | identified                     |
+                                +------------------------+-----------+--------------------------------+
|                                | sbom_primary_component | 10.0/10.0 | SBOM subject defined via       |
|                                |                        |           | primary component              |
+                                +------------------------+-----------+--------------------------------+
|                                | comp_identity          | 10.0/10.0 | component name and version     |
|                                |                        |           | declared for all components    |
+                                +------------------------+-----------+--------------------------------+
|                                | supplier_attribution   | 0.0/10.0  | supplier attribution missing   |
|                                |                        |           | for 113 components             |
+                                +------------------------+-----------+--------------------------------+
|                                | comp_unique_id         | 0.0/10.0  | unique identifier missing for  |
|                                |                        |           | 111 components                 |
+                                +------------------------+-----------+--------------------------------+
|                                | artifact_integrity     | 0.0/10.0  | cryptographic hash missing for |
|                                |                        |           | 117 components                 |
+                                +------------------------+-----------+--------------------------------+
|                                | relationships_coverage | 0.0/10.0  | dependency relationships       |
|                                |                        |           | declared (109), but dependency |
|                                |                        |           | completeness missing for       |
|                                |                        |           | primary component              |
+                                +------------------------+-----------+--------------------------------+
|                                | license_coverage       | 10.0/10.0 | license declared for all       |
|                                |                        |           | components (full coverage:     |
|                                |                        |           | aspirational)                  |
+                                +------------------------+-----------+--------------------------------+
|                                | copyright_coverage     | 0.0/10.0  | copyright missing for primary  |
|                                |                        |           | component (minimum expectation |
|                                |                        |           | not met) and all components    |
+--------------------------------+------------------------+-----------+--------------------------------+


Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6

```

FSCT evaluation is designed to clearly answer:

- What is declared?
- What is missing?
- Where are gaps explicitly identified vs silently omitted?

For many FSCT attributes:

- partial declaration does not earn partial credit,
- minimum expectations (such as primary component coverage) must be met first,
- coverage across components is treated as a transparency signal, not a pass/fail checklist.

This is why you may see:

- a low numeric score,
- but very rich descriptions explaining exactly what is present and what is missing.

This behavior is intentional. FSCT prioritizes clarity and trustworthiness of the SBOM over incremental scoring. It is not a strict regulatory compliance, but a community-driven framework designed to guide improvement by making SBOM completeness and gaps visible.

## Conclusion and what's next

In this post, we explored Framing Software Component Transparency (FSCT) and the problem it was created to solve. FSCT builds on the foundation laid by NTIA Minimum Elements, but shifts the focus from what must exist to how transparently SBOM information is declared. Its core motivation is simple: SBOMs are only useful when consumers can clearly understand what is known, what is incomplete, and what is explicitly unknown.

We discussed how FSCT defines a baseline set of attributes—such as provenance, primary component, component identity, supplier attribution, unique identification, artifact integrity, dependency relationships, and coverage-based fields like license and copyright. Rather than treating these as a checklist, FSCT frames them as signals of transparency and maturity, encouraging explicit declarations over assumptions and treating coverage across components as meaningful context.

We also saw how sbomqs evaluates FSCT alignment in practice. Instead of optimizing for partial scores, sbomqs prioritizes clear explanations that show what is present, what is missing, and where minimum expectations are not met. This makes FSCT results less about a single number and more about understanding the trustworthiness and completeness of an SBOM.

FSCT is not a rigid regulatory compliance. It is a community-driven framework designed to help organizations improve how they produce, share, and consume SBOMs—by making gaps visible and reducing ambiguity. When used together, NTIA and FSCT provide complementary perspectives: NTIA answers whether an SBOM meets minimum requirements, while FSCT answers how transparent and reliable that SBOM really is.

In the next post of this series, we’ll continue expanding beyond FSCT and look at additional SBOM frameworks like BSI, OpenChain Telco, etc.