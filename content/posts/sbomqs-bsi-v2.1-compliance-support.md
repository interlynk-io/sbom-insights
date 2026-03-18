+++
date = '2026-03-18T10:00:00+05:30'
draft = false
title = 'sbomqs Now Supports BSI TR-03183 v2.1: What Changed and How to Score Your SBOM'
categories = ['Compliance', 'Quality', 'Tools']
tags = ['SBOM', 'sbomqs', 'BSI', 'Compliance', 'CRA', 'Standards', 'Security', 'SBOM Quality']
author = 'Vivek Sahu'
description = 'sbomqs now supports BSI TR-03183-2 v2.1 compliance scoring. Understand what changed from v2.0, walk through the required fields, and evaluate your SBOM against the latest BSI standard.'
+++

Hey SBOM community,

Good news  [sbomqs](https://github.com/interlynk-io/sbomqs) now supports **BSI TR-03183-2 v2.1** compliance scoring.

If you've been following BSI compliance, you already know: BSI doesn't sit still. It has been one of the most consistently evolving SBOM compliance frameworks out there. Since its first publication in 2023, BSI has released a new version roughly every year  and each version has brought real, meaningful improvements to how SBOMs are expected to be structured and declared.

We already supported BSI v1.1 and BSI v2.0 in sbomqs. Now, with v2.1 being the most recent and the one that must be used for compliance, we've added full scoring support for it too.

So in this post, let's go through:

- A quick recap on what BSI is and why it keeps evolving
- What changed from BSI v2.0 to BSI v2.1
- The data fields BSI v2.1 expects from your SBOM
- And finally, how to score your SBOM against BSI v2.1 using sbomqs

Let's get started.

## What is BSI TR-03183?

**BSI TR-03183** is a Technical Guideline published by Germany's Federal Office for Information Security (Bundesamt für Sicherheit in der Informationstechnik). Part 2 of this guideline specifically focuses on Software Bill of Materials (SBOM)  what an SBOM must contain, how it should be structured, and which formats are acceptable.

The reason BSI matters so much right now is the **EU Cyber Resilience Act (CRA)**. The CRA is a market access regulation for the EU that requires manufacturers of products with digital components to continuously handle vulnerabilities and provide transparent information about their products. BSI TR-03183 is closely aligned with CRA requirements, making it the go-to SBOM standard for organizations selling software products in the European market.

In short:

> If you're selling software in Europe, BSI compliance is increasingly becoming a requirement not a nice-to-have.

## BSI Version History: A Compliance That Keeps Getting Better

One thing that stands out about BSI is that it keeps improving. Here's the version timeline:

| Version | Date       | Key Changes                                                                 |
| ------- | ---------- | --------------------------------------------------------------------------- |
| 1.0     | 2023-07-12 | First publication                                                           |
| 1.1     | 2023-11-28 | Translated to English; updated requirements for creator, version, licence  |
| 2.0.0   | 2024-09-20 | Added new required fields (filename, executable, archive, structured); updated CycloneDX min to 1.5, SPDX min to 2.2.1 |
| 2.1.0   | 2025-08-20 | Updated CycloneDX min to 1.6, SPDX min to 3.0.1; introduced logical and identified components; restructured data fields; added mapping section |

Each version has made the standard more complete and practical. And there's a clear rule: you must always use the most recent version for new SBOMs. The only exception is the immediately preceding version, which can be used for up to six months after a new version is published.

So BSI v2.1 is now the required version. Let's look at what it changed.

## What Changed from BSI v2.0 to BSI v2.1?

BSI v2.1 is not a ground-up rewrite. The required fields mostly stay the same. But there are meaningful clarifications and improvements that make the standard cleaner and more practical to implement. Here's what changed:

### 1. Format Version Bumps

BSI v2.1 raises the minimum supported SBOM format versions:

| Format     | BSI v2.0 Minimum | BSI v2.1 Minimum |
| ---------- | ---------------- | ---------------- |
| CycloneDX  | 1.5              | **1.6**          |
| SPDX       | 2.2.1            | **3.0.1**        |

This matters because both CycloneDX 1.6 and SPDX 3.0.1 brought significant improvements in how components, relationships, and licence information are expressed. The new minimum versions ensure BSI-compliant SBOMs can leverage those improvements.

### 2. New Component Concepts Introduced

BSI v2.1 introduces two new, clearly defined component types that were previously ambiguous:

**Logical Component**: An abstract level that groups multiple components together. For example, an installed operating system or application framework. A logical component is useful for linking to another SBOM (via BOM reference) rather than listing every single file inside it. For logical components, only a subset of fields is required: creator, name, version, dependencies, distribution licences, other unique identifiers, original licences, effective licence, and URL of **security.txt**.

**Identified Component**: A component that only needs to be *identified*, not fully described. This happens when a component is at the boundary of the scope of delivery  you need to list it to properly chain two SBOMs together, but you don't need to provide all required fields for it. The minimum fields for an identified component are: creator, name, version, and other unique identifiers.

This is a big quality-of-life improvement. Before v2.1, it was unclear how to handle components at the boundary of your software's scope. Now BSI explicitly tells you: just identify them, don't fully describe them.

### 3. Licence Terminology Clarified

BSI v2.1 now explicitly defines three categories of licence information, using their own terms instead of SPDX/CycloneDX terminology:

- **Original licences**: Licences assigned by the creator of the component. Maps to "declared licences" in SPDX/CycloneDX.
- **Distribution licences**: Licences under which the component can be used by a licensee. Maps to "concluded licences" in SPDX/CycloneDX.
- **Effective licence**: The licence under which the component is used specifically by the SBOM creator (i.e. the downstream consumer).

The reason for this: the terms "declared" and "concluded" are used differently across SPDX and CycloneDX, creating confusion. BSI v2.1 sidesteps that confusion by using its own precise terminology.

### 4. Restructured Data Fields

The data fields section is now cleanly organized into five buckets:

- Required data fields for the SBOM itself
- Required data fields for each component
- Additional data fields for the SBOM itself
- Additional data fields for each component
- Optional data fields for each component

This restructuring makes it much easier to understand what's mandatory, what must be present if available, and what's truly optional.

## BSI v2.1 Required Fields: A Complete Walkthrough

Now let's go through all the fields BSI v2.1 expects. I'll keep it simple and practical.

### Fields Required for the SBOM Itself

These two fields must always be present in every BSI-compliant SBOM.

#### 1. Creator of the SBOM

> The email address of the entity that created the SBOM. If no email address is available, this MUST be a URL  e.g. the creator's homepage or the project's web page.

This tells consumers *who* produced the SBOM, so they know who to contact if something is wrong or incomplete.

**SPDX mapping**: `CreationInfo.createdBy` (Person or Organization with email or URL)

**CycloneDX mapping**: `metadata.manufacturer.contact.email` or `metadata.manufacturer.url`

#### 2. Timestamp

> Date and time of the SBOM data compilation. UTC ("Zulu" time) is recommended.

This tells consumers *when* the SBOM was produced, which helps in determining whether the SBOM is current.

**SPDX mapping**: `CreationInfo.created`

**CycloneDX mapping**: `metadata.timestamp`

### Fields Required for Each Component

These fields must be present for every component that is *fully described* in the SBOM (i.e. internal components and direct dependencies within the scope of delivery).

#### 3. Component Creator

> Email address of the entity that created and maintains the component. If no email, a URL of the creator's homepage or project page.

**SPDX mapping**: `software_Package.originatedBy` (Person or Organization)

**CycloneDX mapping**: `components[].manufacturer.contact.email` or `components[].manufacturer.url`

#### 4. Component Name

> Name assigned to the component by the component creator. If no name is assigned, this MUST be the actual filename.

**SPDX mapping**: `software_Package.name`

**CycloneDX mapping**: `components[].name`

#### 5. Component Version

> Identifier used by the creator to specify changes to a previously created version.

If no version exists, this MUST be the modification date of the file expressed as a date-time. BSI recommends Semantic Versioning or Calendar Versioning as the versioning scheme.

**SPDX mapping**: `software_Package.software_packageVersion`

**CycloneDX mapping**: `components[].version`

#### 6. Filename of the Component

> The actual filename of the component  NOT its file system path.

**SPDX mapping**: `software_File.name` (via `hasDistributionArtifact` relationship)

**CycloneDX mapping**: `components[].properties` with name `bsi:component:filename`

#### 7. Dependencies on Other Components

> Enumeration of all components on which this component is directly dependent. The completeness of this enumeration MUST be clearly indicated (complete, incomplete, or noAssertion).

This is a critical field. BSI doesn't just ask for the list of dependencies  it requires you to explicitly state whether the list is complete or not. If you don't know, you must say so.

**SPDX mapping**: `Relationship` with type `contains` or `dependsOn`, with `completeness` field

**CycloneDX mapping**: `dependencies[].dependsOn`, `compositions[].aggregate` (complete/incomplete/unknown)

#### 8. Distribution Licences

> Licences under which the component can be used by a licensee. Must use SPDX licence identifiers or expressions.

Licences must be referred to by their SPDX identifier. If no SPDX identifier exists, the ScanCode LicenseDB or a custom `LicenseRef-` prefix must be used.

**SPDX mapping**: `Relationship` with type `hasConcludedLicense` + `simpleLicensing_LicenseExpression`

**CycloneDX mapping**: `components[].licenses[].expression` with `acknowledgement: "concluded"`

#### 9. Hash Value of the Deployable Component

> Cryptographically secure checksum (SHA-512) of the deployed/deployable form of the component.

BSI specifically requires SHA-512. This allows consumers to verify that the component they have matches what is described in the SBOM.

**SPDX mapping**: `software_File.verifiedUsing` with algorithm `sha512`

**CycloneDX mapping**: `components[].externalReferences[type=distribution].hashes[alg=SHA-512]`

#### 10. Executable Property

> Describes whether the component is executable. Values: "executable" or "non-executable".

This property is important to identify files that may contain executable code and potentially malicious content.

**SPDX mapping**: `software_File.software_additionalPurpose`  add "executable" if the component is executable

**CycloneDX mapping**: `components[].properties` with name `bsi:component:executable`

#### 11. Archive Property

> Describes whether the component is an archive. Values: "archive" or "no archive".

Archives may contain other components inside them, which is relevant for understanding what needs to be further dissected.

**SPDX mapping**: `software_File.software_additionalPurpose`  add "archive" if applicable

**CycloneDX mapping**: `components[].properties` with name `bsi:component:archive`

#### 12. Structured Property

> Describes whether the component is a structured file  i.e. its internal metadata is still intact. Values: "structured" or "unstructured".

Structured archives (like `.zip`, `.tar`, container images, packages) retain their internal structure and can be dissected. Unstructured ones (like firmware images or statically-linked binaries) cannot.

**SPDX mapping**: `software_File.software_additionalPurpose`  add "container" if structured, "firmware" if not

**CycloneDX mapping**: `components[].properties` with name `bsi:component:structured`

### Additional Fields (Must be Present if Available)

#### 13. SBOM-URI (for the SBOM itself)

> A URI that uniquely identifies this SBOM.

**SPDX mapping**: `SpdxDocument.rootElement`

**CycloneDX mapping**: `serialNumber`

#### 14. Source Code URI (per component)

> URI pointing to the source code of the component, or its source code repository.

**SPDX mapping**: `software_SoftwareArtifact.externalRef[SourceArtifact]`

**CycloneDX mapping**: `components[].externalReferences[type=source-distribution].url`

#### 15. URI of the Deployable Form (per component)

> URI pointing directly to the downloadable/deployable form of the component.

**SPDX mapping**: `software_File.binaryArtifact`

**CycloneDX mapping**: `components[].externalReferences[type=distribution].url`

#### 16. Other Unique Identifiers (per component)

> Identifiers like CPE, PURL, or SWID that can be used to look up the component in vulnerability databases.

**SPDX mapping**: `software_Package.externalIdentifiers` (cpe22, cpe23, swid, packageURL)

**CycloneDX mapping**: `components[].cpe`, `components[].purl`, `components[].swid`

#### 17. Original Licences (per component)

> Licences assigned by the original creator of the component.

**SPDX mapping**: `Relationship` with type `hasDeclaredLicense`

**CycloneDX mapping**: `components[].licenses[].expression` with `acknowledgement: "declared"`

### Optional Fields (May be Present)

#### 18. Effective Licence (per component)

> The licence under which this specific SBOM creator is using the component.

**SPDX mapping**: `Relationship` with type `other`, comment `hasEffectiveLicense`

**CycloneDX mapping**: `components[].properties` with name `bsi:component:effectiveLicense`

#### 19. Hash Value of Source Code (per component)

> SHA-512 hash of the component's source code.

**SPDX mapping**: `software_SoftwareArtifact.verifiedUsing[sha512]`

**CycloneDX mapping**: `components[].externalReferences[type=source-distribution].hashes[alg=SHA-512]`

#### 20. URL of security.txt (per component)

> URL pointing to the component creator's `security.txt` file (per RFC 9116).

**SPDX mapping**: `software_Package.externalRef[securityOther]`

**CycloneDX mapping**: `components[].externalReferences[type=rfc-9116].url`

## BSI v2.1 Field Summary Table

| Field                              | Scope     | Type        | SPDX v3.0.1                                  | CycloneDX v1.6                                      |
| ---------------------------------- | --------- | ----------- | -------------------------------------------- | --------------------------------------------------- |
| Creator of the SBOM                | SBOM      | Required    | `CreationInfo.createdBy`                     | `metadata.manufacturer`                             |
| Timestamp                          | SBOM      | Required    | `CreationInfo.created`                       | `metadata.timestamp`                                |
| SBOM-URI                           | SBOM      | Additional  | `SpdxDocument.rootElement`                   | `serialNumber`                                      |
| Component creator                  | Component | Required    | `software_Package.originatedBy`              | `components[].manufacturer`                         |
| Component name                     | Component | Required    | `software_Package.name`                      | `components[].name`                                 |
| Component version                  | Component | Required    | `software_Package.software_packageVersion`   | `components[].version`                              |
| Filename of the component          | Component | Required    | `software_File.name` via relationship        | `components[].properties[bsi:component:filename]`   |
| Dependencies on other components   | Component | Required    | `Relationship[contains/dependsOn]`           | `dependencies[].dependsOn` + `compositions`         |
| Distribution licences              | Component | Required    | `Relationship[hasConcludedLicense]`          | `components[].licenses[acknowledgement=concluded]`  |
| Hash value of deployable component | Component | Required    | `software_File.verifiedUsing[sha512]`        | `externalReferences[distribution].hashes[SHA-512]`  |
| Executable property                | Component | Required    | `software_additionalPurpose: executable`     | `properties[bsi:component:executable]`              |
| Archive property                   | Component | Required    | `software_additionalPurpose: archive`        | `properties[bsi:component:archive]`                 |
| Structured property                | Component | Required    | `software_additionalPurpose: container/firmware` | `properties[bsi:component:structured]`          |
| Source code URI                    | Component | Additional  | `externalRef[SourceArtifact]`                | `externalReferences[source-distribution].url`       |
| URI of deployable form             | Component | Additional  | `software_File.binaryArtifact`               | `externalReferences[distribution].url`              |
| Other unique identifiers           | Component | Additional  | `externalIdentifiers[cpe/purl/swid]`         | `components[].cpe` / `purl` / `swid`                |
| Original licences                  | Component | Additional  | `Relationship[hasDeclaredLicense]`           | `components[].licenses[acknowledgement=declared]`   |
| Effective licence                  | Component | Optional    | `Relationship[other, hasEffectiveLicense]`   | `properties[bsi:component:effectiveLicense]`        |
| Hash value of source code          | Component | Optional    | `software_SoftwareArtifact.verifiedUsing`    | `externalReferences[source-distribution].hashes`    |
| URL of security.txt                | Component | Optional    | `externalRef[securityOther]`                 | `externalReferences[rfc-9116].url`                  |

## Scoring Your SBOM Against BSI v2.1 Using sbomqs

Now comes the fun part  checking whether your SBOM actually meets BSI v2.1.

This is where [sbomqs](https://github.com/interlynk-io/sbomqs) comes in. It's an open-source CLI tool that evaluates SBOMs for quality and compliance. Just run a single command and get a clear scorecard.

### Summarized Score

To get a quick, summarized score against BSI v2.1:

```bash
sbomqs score samples/sbom_cdx.json --profile bsi-v2.1
```

And the output looks like:

```bash
SBOM Quality Score: 3.2/10.0   Grade: F   Components: 38    EngineVersion: 5   File: samples/sbom_cdx.json


SBOM Quality Score: 2.8/10.0	 Grade: F	Components: 392 	 EngineVersion: 6	File: ../sbomqs-syft-sbom.cdx.json


+---------------------+---------------------------+------------------------+--------------------------------+
|       PROFILE       |          FEATURE          |         STATUS         |              DESC              |
+---------------------+---------------------------+------------------------+--------------------------------+
| BSI TR-03183-2 v2.1 | sbom_spec_version         | 10.0/10.0              | CycloneDX 1.6 meets minimum    |
|                     |                           |                        | version 1.6                    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_creator              | 0.0/10.0               | SBOM creator is missing        |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_timestamp            | 10.0/10.0              | SBOM creation timestamp is     |
|                     |                           |                        | valid and RFC3339-compliant.   |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_creator              | 0.0/10.0               | creator information missing    |
|                     |                           |                        | for all components             |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_name                 | 10.0/10.0              | component name declared for    |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_version              | 0.0/10.0               | component version missing for  |
|                     |                           |                        | 19 out of 392 components       |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_filename             | 0.0/10.0               | no components declare filename |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_depth                | 0.0/10.0               | Primary component does not     |
|                     |                           |                        | declare its dependencies.      |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_distribution_license | 0.0/10.0               | no components declare          |
|                     |                           |                        | distribution licence           |
|                     |                           |                        | (concluded)                    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_hash                 | 0.0/10.0               | no components declare          |
|                     |                           |                        | deployable component hash      |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_executable_prop      | 0.0/10.0               | no components declare          |
|                     |                           |                        | executable property            |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_archive_prop         | 0.0/10.0               | no components declare archive  |
|                     |                           |                        | property                       |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_structured_prop      | 0.0/10.0               | no components declare          |
|                     |                           |                        | structured property            |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_uri                  | 10.0/10.0 (additional) | SBOM-URI is declared           |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_source_code_url      | 0.0/10.0 (additional)  | no components declare source   |
|                     |                           |                        | code URI                       |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_download_url         | 0.0/10.0 (additional)  | no components declare          |
|                     |                           |                        | deployable form URI            |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_other_identifiers    | 9.5/10.0 (additional)  | 373/392 components             |
|                     |                           |                        | declare unique identifiers     |
|                     |                           |                        | (CPE/SWID/purl)                |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_concluded_license    | 1.4/10.0 (additional)  | 56/392 components declare      |
|                     |                           |                        | original licence (declared)    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_effective_license    | 0.0/10.0 (optional)    | no components declare          |
|                     |                           |                        | effective licence              |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_source_hash          | 0.0/10.0 (optional)    | no components declare source   |
|                     |                           |                        | code hash                      |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_security_txt_url     | 0.0/10.0 (optional)    | no components declare          |
|                     |                           |                        | security.txt URL               |
+---------------------+---------------------------+------------------------+--------------------------------+


Summary:
Required Fields   : 3/13 compliant
Additional Fields : 1/5 compliant
Optional Fields   : 0/3 present

Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```

The output gives you a feature-by-feature breakdown of exactly what's present and what's missing. For each feature, you see:

- The **STATUS** column  score out of 10.0
- The **DESC** column  exactly which fields are missing and for how many components

This makes it easy to see where your SBOM falls short against BSI v2.1, so you know exactly what to fix next.

### Detailed Compliance Check

For a detailed component-by-component breakdown, use the compliance command:

```bash
sbomqs compliance --bsi-v2.1 samples/sbom_cdx.json
```

This gives you a full table showing the compliance status of each field for every single component in the SBOM  so you know exactly which components are missing which fields.

### Score all BSI profiles

If you want to score your SBOM scores across all different BSI versions at once, you can run:

```bash
sbomqs score samples/sbom_cdx.json --profile bsi-v1.1,bsi-v2.0,bsi-v2.1
```

This is useful to see how your SBOM's compliance level has evolved, or to understand what additional fields you need to add to move from v2.0 to v2.1 compliance.

## Conclusion

BSI TR-03183-2 is one of the few SBOM compliance frameworks that keeps actively improving with every release. With v2.1, the focus was on clarity and practicality: cleaner licence terminology, better-defined component types, raised format version requirements, and a brand new field mapping section that removes all the guesswork.

The fields themselves are largely the same as v2.0. But the way they're defined, organized, and mapped to SPDX and CycloneDX formats is significantly better. If you're generating SBOMs for products sold in the EU market, BSI v2.1 is now the version you need to target.

And with sbomqs, you don't have to read the 37-page spec to figure out where your SBOM falls short. Just run a command, read the output, and you'll know exactly what to fix.

If you love sbomqs, show your support by starring the [repository](https://github.com/interlynk-io/sbomqs/) ⭐.

That's all for today. Keep learning and keep growing...

Before signing off, if you'd like to see the complete analysis of your SBOM, try our community version of the Interlynk Platform. Visit [interlynk.io](https://www.interlynk.io/) and [sign up](https://app.interlynk.io/auth).

## External Resources

- [sbomqs](https://github.com/interlynk-io/sbomqs) GitHub repository
- sbomqs compliance [readme](https://github.com/interlynk-io/sbomqs/blob/main/Compliance.md)
- [BSI TR-03183-2 v2.1.0](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Publications/TechGuidelines/TR03183/BSI-TR-03183-2.pdf) official document
- [BSI TR-03183 overview](https://www.bsi.bund.de/dok/TR-03183-en) on BSI website
- Previous post: [sbomqs Scoring Support for BSI 1.1 and BSI 2.0](/posts/sbomqs-scoring-support-for-bsi-1-1-and-bsi-2-0-in-a-summarized-way/)
- Interlynk [community-tier](https://www.interlynk.io/community-tier)
