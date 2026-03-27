+++
date = '2026-03-27T10:00:00+05:30'
draft = false
title = 'sbomqs now supports BSI TR-03183 v2.1: What changed and how to score your SBOM'
categories = ['Compliance', 'Quality', 'Tools']
tags = ['SBOM', 'sbomqs', 'BSI', 'Compliance', 'CRA', 'Standards', 'Security', 'SBOM Quality']
author = 'Vivek Sahu'
description = 'sbomqs now supports BSI TR-03183-2 v2.1 compliance scoring. Learn what changed from v2.0, and how to score your SBOM against the latest BSI standard using sbomqs.'
+++

Hey SBOM community,

Good news, [sbomqs](https://github.com/interlynk-io/sbomqs) now supports **BSI TR-03183-2 v2.1** compliance scoring.

If you've been following BSI compliance, you already know: BSI doesn't sit still. It has been one of the most consistent SBOM compliance frameworks that kept on evolving. Since its first publication in 2023, BSI has released a new version roughly every year, and each version has brought real, meaningful improvements to how SBOMs are expected to be structured.

We already support BSI v1.1 and BSI v2.0 in sbomqs for both SPDX and CycloneDX. Now, with v2.1 being the most recent and the one that must be used for compliance, we've added full scoring support for CycloneDX spec SBOM only. Currently we don't support SPDX:3.0.1 which is required format for bsi:v2.1.

> If you want a deep dive into every BSI v2.1 field what it means, what it maps to in SPDX and CycloneDX, check out our compliance series blog on [BSI v2.1](https://sbom-insights.dev/posts/bsi-tr-03183-v2.1-compliance/). This post focuses on what changed and how to use sbomqs to score your SBOM against it.

## What is BSI TR-03183?

**BSI TR-03183** is a Technical Guideline published by Germany's Federal Office for Information Security (Bundesamt für Sicherheit in der Informationstechnik). Part 2 focuses specifically on Software Bill of Materials (SBOM): what an SBOM must contain, how it should be structured, and which formats are acceptable.

The reason BSI matters so much right now is the **EU Cyber Resilience Act (CRA)**. The CRA requires manufacturers of products with digital components to continuously handle vulnerabilities and provide transparent information about their products. BSI TR-03183 is closely aligned with CRA requirements, making it the go-to SBOM standard for organizations selling software products in the European market.

> If you're selling software in Europe, BSI compliance is increasingly becoming a requirement, not a nice-to-have.

## BSI Version History

| Version | Date       | Key Changes                                                                 |
| ------- | ---------- | --------------------------------------------------------------------------- |
| 1.0     | 2023-07-12 | First publication                                                           |
| 1.1     | 2023-11-28 | Translated to English; updated requirements for creator, version, licence  |
| 2.0.0   | 2024-09-20 | Added new required fields (filename, executable, archive, structured); updated CycloneDX min to 1.5, SPDX min to 2.2.1 |
| 2.1.0   | 2025-08-20 | Updated CycloneDX min to 1.6, SPDX min to 3.0.1; introduced logical and identified components; overhauled licence terminology; added format field mapping tables |

Each version has made the standard more complete and practical. And there's a clear rule: you must always use the most recent version for new SBOMs. The only exception is the immediately preceding version, which can be used for up to six months after a new version is published.

So BSI v2.1 is now the required version. Let's look at what changed.

## What Changed from BSI v2.0 to BSI v2.1?

### 1. Format version bumps and SPDX v2 is no longer allowed

| Format     | BSI v2.0 Minimum | BSI v2.1 Minimum |
| ---------- | ---------------- | ---------------- |
| CycloneDX  | 1.5              | **1.6**          |
| SPDX       | 2.2.1            | **3.0.1**        |

The SPDX change is the bigger one. BSI v2.1 requires SPDX 3.0.1 or higher. sbomqs does not yet support SPDX 3.0.1, so if you score an SPDX v2 SBOM against `bsi-v2.1`, sbomqs does not hard fail it, instead it performs a best-effort check against the fields that SPDX v2 does support. Fields that BSI v2.1 expects but don't exist in SPDX v2 will simply not be checkable. If you want accurate SPDX v2 scoring against BSI, use the `bsi-v1.1` profile, it is built specifically for SPDX v2. Or use `bsi-v2.0`, which is very close to v2.1 in field requirements and supports SPDX v2 field mappings for BSI v2.0 fields.

### 2. New Component Concepts Introduced

Before v2.1, BSI defined every component as a single executable or archive file. That left two situations unclear: how to represent an abstract product (like an application made of many files), and how to handle dependencies that sit *outside* your delivery boundary.

v2.1 solves this by introducing two new component roles alongside the existing fully described component:

**Logical Component**: An abstract representation of a product, framework, or application, not a physical file. For example: a PHP application running inside a container. Without a logical component, your SBOM is just a pile of files with no concept of "this is my app." A logical component names that unit and can carry a BOM reference pointing to its own SBOM. Because there is no physical file, it requires no filename, hash, or executable/archive/structured properties, just creator, name, version, dependencies, licence fields, unique identifiers, and URL of **security.txt**.

**Identified Component**: A physical file that exists *outside* your scope of delivery, something your software depends on but you didn't ship. You don't need to fully describe it, just identify it so consumers can unambiguously chain SBOMs. Minimum fields: creator, name, version, and other unique identifiers (PURL or CPE).

BSI v2.1 gives a clear priority order for deciding how much to record:

```text
1. Referenced component: 3 fields + pointer to another BOM
2. Identified component: 4 fields (at scope boundary)
3. Fully described component: all fields (inside your delivery)
```

Before v2.1, there was no guidance on how to handle components at the boundary of your delivery. Now BSI explicitly tells you: identify them, don't fully describe them.

### 3. Licence Terminology Clarified

BSI v2.1 now explicitly defines three categories of licence information, using their own terms instead of SPDX/CycloneDX terminology:

- **Original licences**: Licences assigned by the creator of the component. Maps to "declared licences" in SPDX/CycloneDX.
- **Distribution licences**: Licences under which the component can be used by a licensee. Maps to "concluded licences" in SPDX/CycloneDX.
- **Effective licence**: The licence under which this specific SBOM creator is using the component.

The reason for this: the terms "declared" and "concluded" are used differently across SPDX and CycloneDX, creating confusion. BSI v2.1 sidesteps that by using its own precise terminology.

### 4. Licence Field Tier Changes

v2.1 re-organises how licence fields are structured across the three tiers. Two licence fields from v2.0 are gone, and three new BSI-specific terms replace them:

| v2.0 Field | v2.0 Tier | v2.1 Replacement | v2.1 Tier |
|-----------|----------|-----------------|---------|
| Associated licences | Required | **Distribution licences** (renamed) | Required |
| Concluded licences | Additional | — (removed) | — |
| Declared licences | Optional | **Original licences** (renamed) | **Additional** |
| — | — | **Effective licence** (new) | Optional |

The key promotion: "Declared licences" was optional in v2.0. In v2.1, the same concept, renamed "Original licences", is now **additional**, meaning it must be declared whenever the data exists.

"Concluded licences" (additional in v2.0) is removed from v2.1 entirely. Its role is absorbed into the BSI-defined "Distribution licences" concept.

All other additional fields (SBOM-URI, Source code URI, URI of deployable form, Other unique identifiers) **remain additional**, their tier is unchanged.

### 5. New Optional Fields

v2.1 adds two new optional fields that weren't in v2.0 at all:

- **Effective licence**: the licence the SBOM creator actually uses the component under
- **URL of security.txt**: points to the component creator's `security.txt` (RFC 9116)

The third optional field, **hash value of source code**, was already optional in v2.0 and remains so in v2.1.

## sbomqs v2.1 Support

### New Profile: `bsi-v2.1`

sbomqs now has a dedicated `bsi-v2.1` profile. And importantly, the default `bsi` alias now points to `bsi-v2.1`. So if you've been running `--profile bsi`, you're already scoring against v2.1.

All three BSI profiles are still available:

```bash
sbomqs score samples/sbom_cdx.json --profile bsi-v1.1
sbomqs score samples/sbom_cdx.json --profile bsi-v2.0
sbomqs score samples/sbom_cdx.json --profile bsi-v2.1
```

To score your SBOM across all three BSI versions at once:

```bash
sbomqs score testdata/bsi/cdx/validFullyCompliantBsiV21.cdx16.json --profile bsi-v2.1
```

This is useful to see exactly what additional fields are needed to move from v2.0 to v2.1 compliance.

### Scoring against BSI v2.1

```bash
sbomqs score samples/sbom_cdx.json --profile bsi-v2.1
```

The output gives you a feature-by-feature scorecard:

```bash
SBOM Quality Score: 10.0/10.0	 Grade: A	Components: 2 	 EngineVersion: 6	File: testdata/bsi/cdx/validFullyCompliantBsiV21.cdx16.json


+---------------------+---------------------------+------------------------+--------------------------------+
|       PROFILE       |          FEATURE          |         STATUS         |              DESC              |
+---------------------+---------------------------+------------------------+--------------------------------+
| BSI TR-03183-2 v2.1 | sbom_spec_version         | 10.0/10.0              | CycloneDX 1.6 meets minimum    |
|                     |                           |                        | version 1.6                    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_creator              | 10.0/10.0              | SBOM creator contact(email)    |
|                     |                           |                        | provided via authors           |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_timestamp            | 10.0/10.0              | SBOM creation timestamp is     |
|                     |                           |                        | valid and RFC3339-compliant.   |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_creator              | 10.0/10.0              | creator contact (email or URL) |
|                     |                           |                        | declared for all components    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_name                 | 10.0/10.0              | component name declared for    |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_version              | 10.0/10.0              | component version declared for |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_filename             | 10.0/10.0              | filename declared for all      |
|                     |                           |                        | components                     |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_depth                | 10.0/10.0              | Dependencies are recursively   |
|                     |                           |                        | declared and structurally      |
|                     |                           |                        | complete.                      |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_distribution_license | 10.0/10.0              | distribution licence           |
|                     |                           |                        | (concluded) declared for all   |
|                     |                           |                        | components                     |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_hash                 | 10.0/10.0              | deployable component hash      |
|                     |                           |                        | declared for all components    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_executable_prop      | 10.0/10.0              | executable property declared   |
|                     |                           |                        | for all components             |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_archive_prop         | 10.0/10.0              | archive property declared for  |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_structured_prop      | 10.0/10.0              | structured property declared   |
|                     |                           |                        | for all components             |
+                     +---------------------------+------------------------+--------------------------------+
|                     | sbom_uri                  | 10.0/10.0 (additional) | SBOM-URI is declared           |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_source_code_url      | 10.0/10.0 (additional) | source code URI declared for   |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_download_url         | 10.0/10.0 (additional) | deployable form URI declared   |
|                     |                           |                        | for all components             |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_other_identifiers    | 10.0/10.0 (additional) | unique identifiers             |
|                     |                           |                        | (CPE/SWID/purl) declared for   |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_original_licenses    | 10.0/10.0 (additional) | original licence (declared)    |
|                     |                           |                        | declared for all components    |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_effective_license    | 10.0/10.0 (optional)   | effective licence declared for |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_source_hash          | 10.0/10.0 (optional)   | source code hash declared for  |
|                     |                           |                        | all components                 |
+                     +---------------------------+------------------------+--------------------------------+
|                     | comp_security_txt_url     | 10.0/10.0 (optional)   | security.txt URL declared for  |
|                     |                           |                        | all components                 |
+---------------------+---------------------------+------------------------+--------------------------------+


Summary:
Required Fields   : 13/13 compliant
Additional Fields : 5/5 compliant
Optional Fields   : 3/3 present

Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```

Each row tells you exactly which field is missing and for how many components, so you know precisely what to fix.

The summary at the bottom breaks it down into required, additional, and optional fields, matching the three tiers BSI v2.1 uses.

### Detailed Component-Level check

Once you know the overall gaps, use the compliance command to drill down component by component:

```bash
sbomqs compliance --bsi-v21 testdata/bsi/cdx/validFullyCompliantBsiV21.cdx16.json
```

This gives you a full table showing the compliance status of each field for every single component, so you know exactly which components are missing which fields.

### A Note on SPDX v2 SBOMs

If you run an SPDX v2 SBOM against `bsi-v2.1`, sbomqs will return a hard fail on the format version check and mark all field checks as N/A. This is by design — BSI v2.1 does not accept SPDX v2. You need to either upgrade to SPDX 3.0.1 or use CycloneDX 1.6.

BSI v2.1 requires SPDX 3.0.1 as the minimum, but sbomqs does not yet support SPDX 3.0.1. If you run an SPDX v2 SBOM against `bsi-v2.1`, sbomqs performs a best-effort check, it checks the fields that SPDX v2 does expose, and skips the ones it cannot map. There is no hard fail. For accurate SPDX v2 results, use `bsi-v1.1` (built for SPDX v2) or `bsi-v2.0` (very similar field set to v2.1, with SPDX v2 field mappings).

## Conclusion

BSI v2.1 is a meaningful step forward from v2.0. The format bumps, the new component concepts, the promoted fields, and the clearer licence terminology all make the standard more precise and practical to implement.

The fields themselves were largely in v2.0. But v2.1 tightens the format requirements, promotes "Declared licences" from optional to additional (renaming it "Original licences"), removes the ambiguity around how to handle components at the boundary of your delivery, and adds clearer licence terminology throughout.

With sbomqs, you don't need to manually check all of this. Just run a command, read the output, and you'll know exactly where your SBOM stands against BSI v2.1.

If you love sbomqs, show your support by starring the [repository](https://github.com/interlynk-io/sbomqs/) ⭐.

That's all for today. Keep learning and keep growing...

Before signing off, if you'd like to see the complete analysis of your SBOM, try our community version of the Interlynk Platform. Visit [interlynk.io](https://www.interlynk.io/) and [sign up](https://app.interlynk.io/auth).

## External Resources

- [sbomqs](https://github.com/interlynk-io/sbomqs) GitHub repository
- sbomqs compliance [readme](https://github.com/interlynk-io/sbomqs/blob/main/Compliance.md)
- [BSI TR-03183-2 v2.1.0](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Publications/TechGuidelines/TR03183/BSI-TR-03183-2_v2_1_0.pdf) official document
- [BSI TR-03183 overview](https://www.bsi.bund.de/dok/TR-03183-en) on BSI website
- Previous post: [sbomqs Scoring Support for BSI 1.1 and BSI 2.0](/posts/sbomqs-scoring-support-for-bsi-1.1-and-bsi-2.0-in-a-summarized-way/)
- Interlynk [community-tier](https://www.interlynk.io/community-tier)
