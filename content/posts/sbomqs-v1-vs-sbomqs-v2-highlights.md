+++
date = '2025-11-29T14:40:15+05:30'
draft = false
title = 'sbomqs:v1.x.x Vs sbomqs:v2.x.x: What Changed?'
categories = ['sbomqs', 'scoring', 'sbom']
tags = ['SBOM', 'sbomqs', 'sbom', 'scoring']
author = 'Vivek Sahu'
description = 'Compare sbomqs v1 and v2 scoring models. See what changed in the new release, from separated compliance checks to a cleaner quality scoring approach.'
+++


## Overview

![alt text](/posts/image-36.png)

Hello Everyone 👋,

We have released [sbomqs:2.0](https://github.com/interlynk-io/sbomqs/releases/tag/v2.0.1) last week. This post is about major changes b/w **sbomqs:1.x.x** and **sbomqs:2.0.x**. Let's understand, what exactly changed in sbomqs 2.0, and how it is different from the older 1.x scoring model?

If you’ve been using sbomqs for a while, you know that 1.x scoring bundled everything together in a summarized way:

```bash
$ sbomqs score samples/photon.spdx.json --legacy

SBOM Quality by Interlynk Score:6.0	components:38	samples/photon.spdx.json
+-----------------------+--------------------------------+-----------+--------------------------------+
|       CATEGORY        |            FEATURE             |   SCORE   |              DESC              |
+-----------------------+--------------------------------+-----------+--------------------------------+
| NTIA-minimum-elements | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 10.0/10.0 | 38/38 have unique ID's         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+-----------------------+--------------------------------+-----------+--------------------------------+
| bsi-v1.1              | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 0.0/10.0  | 0/38 have unique ID's          |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_licenses             | 9.5/10.0  | 36/38 have compliant licenses  |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_checksums_sha256     | 0.3/10.0  | 1/38 have checksums            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_uri      |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_hash     | 0.0/10.0  | 0/38 have source code hash     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_uri       | 10.0/10.0 | 38/38 have executable URI      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_dependencies         | 0.5/10.0  | 2/38 have dependencies         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | spec_with_version_compliant    | 10.0/10.0 | provided sbom spec: spdx, and  |
|                       |                                |           | version: SPDX-2.3 is supported |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_uri                  | 10.0/10.0 | doc has URI                    |
+-----------------------+--------------------------------+-----------+--------------------------------+
| bsi-v2.0              | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 0.0/10.0  | 0/38 have unique ID's          |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_associated_license   | 0.0/10.0  | 0/38 have compliant licenses   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_concluded_license    | 0.0/10.0  | 0/38 have compliant licenses   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_declared_license     | 9.5/10.0  | 36/38 have compliant licenses  |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_uri      |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_hash     | 0.0/10.0  | 0/38 have source code hash     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_uri       | 10.0/10.0 | 38/38 have executable URI      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_hash      | 0.3/10.0  | 1/38 have checksums            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_dependencies         | 0.5/10.0  | 2/38 have dependencies         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | spec_with_version_compliant    | 10.0/10.0 | provided sbom spec: spdx, and  |
|                       |                                |           | version: SPDX-2.3 is supported |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_build_process             |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_uri                  | 10.0/10.0 | doc has URI                    |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_bomlinks             | 0.0/10.0  | no bom links found             |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_vuln                 | 10.0/10.0 | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_signature            | 0.0/10.0  | No signature or public key     |
|                       |                                |           | provided!                      |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Semantic              | sbom_required_fields           | 10.0/10.0 | Doc Fields:true Pkg            |
|                       |                                |           | Fields:true                    |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_licenses             | 9.5/10.0  | 36/38 have licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_checksums            | 0.3/10.0  | 1/38 have checksums            |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Quality               | comp_valid_licenses            | 2.9/10.0  | 11/38 components with valid    |
|                       |                                |           | license                        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_primary_purpose      | 0.0/10.0  | 0/38 components have primary   |
|                       |                                |           | purpose specified              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_deprecated_licenses  | 10.0/10.0 | 0/38 components have           |
|                       |                                |           | deprecated licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_restrictive_licenses | 10.0/10.0 | 0/38 components have           |
|                       |                                |           | restricted licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_any_vuln_lookup_id   | 0.0/10.0  | 0/38 components have any       |
|                       |                                |           | lookup id                      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_multi_vuln_lookup_id | 0.0/10.0  | 0/38 components have multiple  |
|                       |                                |           | lookup id                      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_creator_and_version  | 10.0/10.0 | 1/1 tools have creator and     |
|                       |                                |           | version                        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_primary_component    | 10.0/10.0 | primary component found        |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Sharing               | sbom_sharable                  | 0.0/10.0  | doc has a sharable license     |
|                       |                                |           | free 0 :: of 1                 |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Structural            | sbom_spec                      | 10.0/10.0 | provided sbom is in a          |
|                       |                                |           | supported sbom format of       |
|                       |                                |           | spdx,cyclonedx                 |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_spec_version              | 10.0/10.0 | provided sbom should be in     |
|                       |                                |           | supported spec version for     |
|                       |                                |           | spec:SPDX-2.3 and versions:    |
|                       |                                |           | SPDX-2.1,SPDX-2.2,SPDX-2.3     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_file_format               | 10.0/10.0 | provided sbom should be in     |
|                       |                                |           | supported file format for      |
|                       |                                |           | spec: json and version:        |
|                       |                                |           | json,yaml,rdf,tag-value        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_parsable                  | 10.0/10.0 | provided sbom is parsable      |
+-----------------------+--------------------------------+-----------+--------------------------------+

```

The o/p contains:

- categories, as well as
- compliances

There was 2 issues in it:

- Need to include more categories.
- Detach compliance scoring from default scoring categories.

## 🚀 What’s New in sbomqs 2.0?

### 1 Addition of New Categories

In **sbomqs:1.x.x** scoring model, default categories were 4(**Structural**, **Semantic**, **Quality** and **Sharing**), which is now increased to 7 in sbomqs:2.0:

**7 categories:**

1. Identification
2. Provenance
3. Integrity
4. Completeness
5. Licensing & Compliance Metadata
6. Vulnerability Traceability
7. Structural

These categories are also known as "Interlynk Categories". On scoring for interlynk categories, represents **comprehensive SBOM quality score**.

### 2. Default Scoring Is Now Separate From Compliance Scoring

In 1.x, the default scoring includes **4 category + popular compliances**. Basically the default category included compliances as it's categories, as a result it impacts the score.

- Structural category
- Quality category
- Semantic category
- Sharing category
- NTIA-minimum-elements
- BSI v1.1
- BSI v2.0

Basically: *everything thrown into one bucket in default scoring*.

In **2.0**, **decoupled** compliances scoring from it. Therefore, Compliance scoring is now handled via **Profiles** separately. Supported profiles are:

- ntia(NTIA-minimum-elements)
- bsi-v1.1
- bsi-v2.0
- oct
- interlynk
- ntia-2025
- fsct(coming soon)
- (auto-ISAC coming soon)

You can score these profiles using a flag `--profile`.

**Examples**:

```bash
sbomqs score --profile ntia sbom.json
sbomqs score --profile bsi-v2.0 sbom.json
sbomqs score --profile ntia,bsi-v2.0 sbom.json
```

### 3. Introducing Weighted Categories (with custom overrides)

sbomqs 2.0 now lets you answer a fundamental question:

> “What matters more to you in an SBOM?”

Maybe you care more about:

- integrity (hashes)
- licensing
- provenance
- vulnerability traceability
- completenesss
- structural

In 1.x, category weights were fixed, due to which all categories and features were getting same importance.

In 2.0, every category has a default weight and you can override them to make respective categories and features more importance as per your use-cases.

### 4. Grades

sbomqs produces scores in the range of 0.0 to 10.0. Grades allow for quick classification and consumption.

| **Grade** | **Color**               | **Score Range** | **Meaning**      | **Recommended Action**                      |
| --------- | ----------------------- | --------------- | ---------------- | -------------------------------------------- |
| **A**     | Green (#2ECC71)         | **9.0 – 10.0**  | **Excellent**    | Ready for production use                    |
| **B**     | Light Green (#58D68D)   | **8.0 – 8.9**   | **Good**         | Minor improvements recommended              |
| **C**     | Yellow (#F4D03F)        | **7.0 – 7.9**   | **Acceptable**   | Review and enhance key missing elements     |
| **D**     | Orange (#E67E22)        | **5.0 – 6.9**   | **Poor**         | Significant improvements required           |
| **F**     | Red (#E74C3C)           | **< 5.0**       | **Bad**          | Not suitable for use, major rework needed   |

### 5. A Modern Detailed Output

**sbomqs 1.x result** Showed:

- massive tables
- duplicate information across categories
- NTIA + BSI + Quality + Semantic all mixed together

**sbomqs 2.0 result** shows:

Contains 3 sections:

- **Profile Summary Scores** for Interlynk, NTIA, BSI profiles
- **Interlynk Category Score** Summary
- **Interlynk Category Detailed** Score.

### 6. Side-by-Side Output Comparison: sbomqs 1.x vs 2.0

#### 6.1 Example: sbomqs 1.x Output

```bash
$ sbomqs score samples/photon.spdx.json --legacy

SBOM Quality by Interlynk Score:6.0	components:38	samples/photon.spdx.json
+-----------------------+--------------------------------+-----------+--------------------------------+
|       CATEGORY        |            FEATURE             |   SCORE   |              DESC              |
+-----------------------+--------------------------------+-----------+--------------------------------+
| NTIA-minimum-elements | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 10.0/10.0 | 38/38 have unique ID's         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+-----------------------+--------------------------------+-----------+--------------------------------+
| bsi-v1.1              | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 0.0/10.0  | 0/38 have unique ID's          |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_licenses             | 9.5/10.0  | 36/38 have compliant licenses  |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_checksums_sha256     | 0.3/10.0  | 1/38 have checksums            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_uri      |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_hash     | 0.0/10.0  | 0/38 have source code hash     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_uri       | 10.0/10.0 | 38/38 have executable URI      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_dependencies         | 0.5/10.0  | 2/38 have dependencies         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | spec_with_version_compliant    | 10.0/10.0 | provided sbom spec: spdx, and  |
|                       |                                |           | version: SPDX-2.3 is supported |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_uri                  | 10.0/10.0 | doc has URI                    |
+-----------------------+--------------------------------+-----------+--------------------------------+
| bsi-v2.0              | comp_with_name                 | 10.0/10.0 | 38/38 have names               |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_version              | 9.7/10.0  | 37/38 have versions            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_uniq_ids             | 0.0/10.0  | 0/38 have unique ID's          |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_supplier             | 0.0/10.0  | 0/38 have supplier names       |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_associated_license   | 0.0/10.0  | 0/38 have compliant licenses   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_concluded_license    | 0.0/10.0  | 0/38 have compliant licenses   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_declared_license     | 9.5/10.0  | 36/38 have compliant licenses  |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_uri      |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_source_code_hash     | 0.0/10.0  | 0/38 have source code hash     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_uri       | 10.0/10.0 | 38/38 have executable URI      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_executable_hash      | 0.3/10.0  | 1/38 have checksums            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_dependencies         | 0.5/10.0  | 2/38 have dependencies         |
+                       +--------------------------------+-----------+--------------------------------+
|                       | spec_with_version_compliant    | 10.0/10.0 | provided sbom spec: spdx, and  |
|                       |                                |           | version: SPDX-2.3 is supported |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_creation_timestamp        | 10.0/10.0 | doc has creation timestamp     |
|                       |                                |           | 2023-01-12T22:06:03Z           |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_authors                   | 10.0/10.0 | doc has 1 authors              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_build_process             |  -        | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_uri                  | 10.0/10.0 | doc has URI                    |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_dependencies              | 10.0/10.0 | primary comp has 1             |
|                       |                                |           | dependencies                   |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_bomlinks             | 0.0/10.0  | no bom links found             |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_vuln                 | 10.0/10.0 | no-deterministic-field in spdx |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_signature            | 0.0/10.0  | No signature or public key     |
|                       |                                |           | provided!                      |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Semantic              | sbom_required_fields           | 10.0/10.0 | Doc Fields:true Pkg            |
|                       |                                |           | Fields:true                    |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_licenses             | 9.5/10.0  | 36/38 have licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_checksums            | 0.3/10.0  | 1/38 have checksums            |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Quality               | comp_valid_licenses            | 2.9/10.0  | 11/38 components with valid    |
|                       |                                |           | license                        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_primary_purpose      | 0.0/10.0  | 0/38 components have primary   |
|                       |                                |           | purpose specified              |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_deprecated_licenses  | 10.0/10.0 | 0/38 components have           |
|                       |                                |           | deprecated licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_restrictive_licenses | 10.0/10.0 | 0/38 components have           |
|                       |                                |           | restricted licenses            |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_any_vuln_lookup_id   | 0.0/10.0  | 0/38 components have any       |
|                       |                                |           | lookup id                      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | comp_with_multi_vuln_lookup_id | 0.0/10.0  | 0/38 components have multiple  |
|                       |                                |           | lookup id                      |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_creator_and_version  | 10.0/10.0 | 1/1 tools have creator and     |
|                       |                                |           | version                        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_with_primary_component    | 10.0/10.0 | primary component found        |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Sharing               | sbom_sharable                  | 0.0/10.0  | doc has a sharable license     |
|                       |                                |           | free 0 :: of 1                 |
+-----------------------+--------------------------------+-----------+--------------------------------+
| Structural            | sbom_spec                      | 10.0/10.0 | provided sbom is in a          |
|                       |                                |           | supported sbom format of       |
|                       |                                |           | spdx,cyclonedx                 |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_spec_version              | 10.0/10.0 | provided sbom should be in     |
|                       |                                |           | supported spec version for     |
|                       |                                |           | spec:SPDX-2.3 and versions:    |
|                       |                                |           | SPDX-2.1,SPDX-2.2,SPDX-2.3     |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_file_format               | 10.0/10.0 | provided sbom should be in     |
|                       |                                |           | supported file format for      |
|                       |                                |           | spec: json and version:        |
|                       |                                |           | json,yaml,rdf,tag-value        |
+                       +--------------------------------+-----------+--------------------------------+
|                       | sbom_parsable                  | 10.0/10.0 | provided sbom is parsable      |
+-----------------------+--------------------------------+-----------+--------------------------------+
```

#### 6.2 Example: sbomqs 2.0 Output

```bash
$ sbomqs score samples/photon.spdx.json     

SBOM Quality Score: 4.8/10.0	 Grade: F	Components: 38 	 EngineVersion: 2	File: samples/photon.spdx.json

Profile Summary Scores:
+------------------------------+----------+-------+
|           PROFILE            |  SCORE   | GRADE |
+------------------------------+----------+-------+
| Interlynk Profile            | 4.5/10.0 | F     |
+------------------------------+----------+-------+
| NTIA Minimum Elements (2021) | 7.1/10.0 | C     |
+------------------------------+----------+-------+
| BSI TR-03183-2 v1.1          | 6.7/10.0 | D     |
+------------------------------+----------+-------+

Category Summary:
+----------------+--------+-----------+-------+
|    CATEGORY    | WEIGHT |   SCORE   | GRADE |
+----------------+--------+-----------+-------+
| Identification | 12.2%  | 9.9/10.0  | A     |
+----------------+--------+-----------+-------+
| Provenance     | 14.6%  | 7.3/10.0  | C     |
+----------------+--------+-----------+-------+
| Integrity      | 18.3%  | 4.1/10.0  | F     |
+----------------+--------+-----------+-------+
| Completeness   | 14.6%  | 2.5/10.0  | F     |
+----------------+--------+-----------+-------+
| Licensing      | 18.3%  | 2.4/10.0  | F     |
+----------------+--------+-----------+-------+
| Vulnerability  | 12.2%  | 0.0/10.0  | F     |
+----------------+--------+-----------+-------+
| Structural     | 9.8%   | 10.0/10.0 | A     |
+----------------+--------+-----------+-------+

Interlynk Detailed Score:
+------------------------+--------------------------------+---------------+-------------------------------------+
|        CATEGORY        |            FEATURE             |     SCORE     |                DESC                 |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Identification (12.2%) | comp_with_name (4.9%)          | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_version (4.3%)       | 9.7/10.0      | add to 1 component                  |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_identifiers (3.0%)   | 10.0/10.0     | complete                            |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Provenance (14.6%)     | sbom_creation_timestamp (2.9%) | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_authors (2.9%)            | 0.0/10.0      | add author                          |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_tool_version (2.9%)       | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_supplier (2.2%)           | 0.0/10.0      | N/A (SPDX)                          |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_namespace (2.2%)          | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_lifecycle (1.5%)          | 0.0/10.0      | N/A (SPDX)                          |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Integrity (18.3%)      | comp_with_strong_checksums     | 0.3/10.0      | add to 37 components                |
|                        | (9.1%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_weak_checksums       | 10.0/10.0     | complete                            |
|                        | (7.3%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_signature (1.8%)          | 0.0/10.0      | add signature                       |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Completeness (14.6%)   | comp_with_dependencies (3.7%)  | 0.5/10.0      | add to 36 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_completeness_declared     | 0.0/10.0      | N/A (SPDX)                          |
|                        | (2.2%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_primary_component (2.9%)  | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_source_code (2.2%)   | 0.0/10.0      | add to 38 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_supplier (2.2%)      | 0.0/10.0      | add to 38 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_purpose (1.5%)       | 0.0/10.0      | add to 38 components                |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Licensing (18.3%)      | comp_with_licenses (3.7%)      | 0.0/10.0      | add to 38 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_valid_licenses       | 0.0/10.0      | add to 38 components                |
|                        | (3.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_no_deprecated_licenses    | 0.0/10.0      | add concluded licenses first        |
|                        | (2.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_no_restrictive_licenses   | 0.0/10.0      | add concluded licenses first        |
|                        | (3.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_declared_licenses    | 9.5/10.0      | add to 2 components                 |
|                        | (2.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_data_license (1.8%)       | 10.0/10.0     | complete                            |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Vulnerability (12.2%)  | comp_with_purl (12.2% OR)      | 0.0/10.0      | add to 38 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_cpe (12.2% OR)       | 0.0/10.0      | add to 38 components                |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Structural (9.8%)      | sbom_spec_declared (2.9%)      | 10.0/10.0     | spdx                                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_spec_version (2.9%)       | 10.0/10.0     | SPDX-2.3                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_file_format (2.0%)        | 10.0/10.0     | json                                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_schema_valid (2.0%)       | 10.0/10.0     | complete                            |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Component Quality      | comp_eol_eos                   | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_malicious                 | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_vuln_sev_critical         | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_kev                       | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_purl_valid                | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_cpe_valid                 | Coming Soon.. | N/A                                 |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | NOTE: Register Interest for    |               | https://forms.gle/WVoB3DrX9NKnzfhV8 |
|                        | Component Analysis             |               |                                     |
+------------------------+--------------------------------+---------------+-------------------------------------+


Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```

#### 6.3 Profile Scoring: Running NTIA in sbomqs 2.0

```bash
$ sbomqs score --profile ntia samples/photon.spdx.json

SBOM Quality Score: 7.1/10.0	 Grade: C	Components: 38 	 EngineVersion: 2	File: samples/photon.spdx.json


+------------------------------+---------------------+-----------+----------------------+
|           PROFILE            |       FEATURE       |  STATUS   |         DESC         |
+------------------------------+---------------------+-----------+----------------------+
| NTIA Minimum Elements (2021) | sbom_machine_format | 10.0/10.0 | complete             |
+                              +---------------------+-----------+----------------------+
|                              | comp_name           | 10.0/10.0 | complete             |
+                              +---------------------+-----------+----------------------+
|                              | comp_version        | 9.7/10.0  | add to 1 component   |
+                              +---------------------+-----------+----------------------+
|                              | comp_uniq_id        | 0.0/10.0  | add to 38 components |
+                              +---------------------+-----------+----------------------+
|                              | sbom_dependencies   | 10.0/10.0 | complete             |
+                              +---------------------+-----------+----------------------+
|                              | sbom_creator        | 0.0/10.0  | add authors          |
+                              +---------------------+-----------+----------------------+
|                              | sbom_timestamp      | 10.0/10.0 | complete             |
+------------------------------+---------------------+-----------+----------------------+


Love to hear your feedback https://forms.gle/anFSspwrk7uSfD7Q6
```

## Conclusion

sbomqs 2.0 is more than an upgrade, it’s a rethinking of how SBOM quality should be measured.

With:

- separated quality & compliance,
- weighted categories,
- profiles,
- grades,
- profile-based scoring,
- cleaner outputs,

…it gives teams a structured, reliable way to judge the trustworthiness of an SBOM, whether for internal quality checks or regulatory compliance.

If you’ve been using sbomqs 1.x, upgrading to 2.0 gives you a scoring system that’s far more accurate, interpretable, and future-proof.

For **sbomqs:2.0** spec refer [here](https://github.com/interlynk-io/sbomqs/blob/main/docs/specs/SBOMQS-2.0-SPEC.md).

For any feedback to improve the SBOM quality, just fill up the [form](https://forms.gle/anFSspwrk7uSfD7Q6) or raise an [issue](https://github.com/interlynk-io/sbomqs/issues/new) or even start a [discussion](https://github.com/interlynk-io/sbomqs/discussions).
