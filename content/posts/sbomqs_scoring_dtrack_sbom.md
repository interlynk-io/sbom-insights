+++
date = '2025-11-25T14:40:15+05:30'
draft = false
title = 'SBOM scoring into the Dependency-Track'
categories = ['Automation', 'Tools']
tags = ['SBOM', 'sbomqs', 'Scoring', 'Dependency-Track']
author = 'Vivek Sahu'
description = 'Score SBOM quality directly within Dependency-Track using sbomqs. Ensure your SBOMs are complete and accurate before feeding them to your SBOM platform.'
+++


![Blog header for integrating sbomqs SBOM scoring into Dependency-Track](/posts/image-37.png)

## Introduction

Hey Everyone 👋,

Today we will be discussing through a very specific practical, real-world use case, something that shows up the moment an organization starts taking software supply chain security seriously. Whether it’s because of internal security, or government push through compliance (like NTIA, BSI), or upcoming regulations like the EU CRA…

> On SBOM and SBOM Platforms

These SBOM platforms help you monitor vulnerabilities, track licenses, and keep an eye on everything happening inside your software supply chain. And one of the popular OSS SBOM platform is: **[Dependency-Track](https://github.com/DependencyTrack/dependency-track)**.

If your SBOM is incomplete, inconsistent, or missing critical metadata, the platform’s insights start falling apart. In simple terms:

**Poor SBOM** → **Poor analysis** → **Poor decisions**.

That’s why the quality of an SBOM matters just as much as generating the SBOM itself. And to measure that quality, you need a clear, objective score that tells you:

- How complete is my SBOM?
- Does it contains important fields ?
- Is it compliant with standards like NTIA, BSI, or OCT?
- And what is quality score based on pre-defined fields ?

That's exactly where **[sbomqs](https://github.com/interlynk-io/sbomqs)** comes into to measure the SBOM quality. Run simple command and get instantly score for SBOMs:

```bash

sbomqs score new-sbom.cdx.json
```

But practically organization deploy their SBOMs in the SBOM platform. So naturally, the question arises is:

> How to check SBOM quality score inside Dependency-Track Platform ?

This blog is **exactly about this use case**, on how to bring **SBOM scoring into Dependency-Track**.

So yeah, let's get started....

## Getting Started

### sbomqs

A lightweight, open-source CLI tool for measuring the quality and compliance of SBOMs. It helps you check completeness, correctness, consistency, and gives you a simple score.

sbomqs repo: <https://github.com/interlynk-io/sbomqs>

### Dependency-Track(dtrack)

A popular open-source SBOM platform used by organizations worldwide. It lets you analyze SBOMs in depth, vulnerabilities, components, licenses, risk scoring, and more.

dtrack repo: <https://github.com/DependencyTrack/dependency-track>

### How Scoring Works in sbomqs (And How to Push That Score into Dependency-Track)

Let’s walk through it step by step.

#### 1. Score an SBOM Locally (The Simple Case)

If the SBOM is already on your machine, scoring it is straightforward:

```bash
sbomqs score my-sbom.cdx.json
```

**NOTE**: For sbomqs installation, [refer](https://github.com/interlynk-io/sbomqs/blob/main/docs/getting-started.md).

#### 2. Score an SBOM That Already Lives Inside Dependency-Track

Before that, export your credentials and project info:

```bash
export DEPENDENCY_TRACK_PROJECT_ID="05cdcf2b-97ab-479c-be44-ae0d608d8863"

export DEPENDENCY_TRACK_URL="http://localhost:8081/"

export DEPENDENCY_TRACK_API_KEY="odt_WYMdgLZ8sQNEVAfTwD7C5tV55ysQI1Ps"
```

**NOTE**: To setup dtrack installation and know how to retrieve these credentials, [refer](https://github.com/interlynk-io/sbommv/blob/main/examples/setup_dependency_track.md).

Now fetch and score the SBOM inside Dependency-Track:

```bash
sbomqs dt \
  --url "${DEPENDENCY_TRACK_URL}/" \
  --api-key "${DEPENDENCY_TRACK_API_KEY}" \
  ${DEPENDENCY_TRACK_PROJECT_ID}
```

o/p:

```bash
SBOM Quality Score: 5.1/10.0	 Grade: D	Components: 70 	 EngineVersion: 2	File: /tmp/tmpfile-80139997-35ed-41b6-bf30-e3f08ba6a7ab1391393063

Industry Profile Overviews:
+--------------------------------+----------+-------+
|            PROFILE             |  SCORE   | GRADE |
+--------------------------------+----------+-------+
| Interlynk                      | 5.0/10.0 | F     |
+--------------------------------+----------+-------+
| NTIA Minimum Elements (2021)   | 5.6/10.0 | D     |
+--------------------------------+----------+-------+
| NTIA Minimum Elements (2025) - | 5.4/10.0 | D     |
| RFC                            |          |       |
+--------------------------------+----------+-------+
| Framing Third Edition          | 5.0/10.0 | F     |
| Compliance                     |          |       |
+--------------------------------+----------+-------+
| BSI TR-03183-2 v1.1            | 5.0/10.0 | F     |
+--------------------------------+----------+-------+
| OpenChain Telco v1.1           | 3.5/10.0 | F     |
+--------------------------------+----------+-------+

Category Breakdown:
+----------------+--------+-----------+-------+
|    CATEGORY    | WEIGHT |   SCORE   | GRADE |
+----------------+--------+-----------+-------+
| Identification | 12.2%  | 8.3/10.0  | B     |
+----------------+--------+-----------+-------+
| Provenance     | 14.6%  | 5.5/10.0  | D     |
+----------------+--------+-----------+-------+
| Integrity      | 18.3%  | 0.0/10.0  | F     |
+----------------+--------+-----------+-------+
| Completeness   | 14.6%  | 3.5/10.0  | F     |
+----------------+--------+-----------+-------+
| Licensing      | 18.3%  | 5.2/10.0  | D     |
+----------------+--------+-----------+-------+
| Vulnerability  | 12.2%  | 6.8/10.0  | D     |
+----------------+--------+-----------+-------+
| Structural     | 9.8%   | 10.0/10.0 | A     |
+----------------+--------+-----------+-------+

Score Breakdown:
+------------------------+--------------------------------+---------------+-------------------------------------+
|        CATEGORY        |            FEATURE             |     SCORE     |                DESC                 |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Identification (12.2%) | comp_with_name (4.9%)          | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_version (4.3%)       | 5.1/10.0      | add to 34 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_local_id (3.0%)      | 10.0/10.0     | complete                            |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Provenance (14.6%)     | sbom_creation_timestamp (2.9%) | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_authors (2.9%)            | 0.0/10.0      | add author                          |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_tool_version (2.9%)       | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_supplier (2.2%)           | 0.0/10.0      | add supplier                        |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_namespace (2.2%)          | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_lifecycle (1.5%)          | 0.0/10.0      | add lifecycle                       |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Integrity (18.3%)      | comp_with_strong_checksums     | 0.0/10.0      | add to 70 components                |
|                        | (9.1%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_weak_checksums       | 0.0/10.0      | no checksums found                  |
|                        | (7.3%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_signature (1.8%)          | 0.0/10.0      | add signature                       |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Completeness (14.6%)   | comp_with_dependencies (3.7%)  | 0.0/10.0      | add to 70 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_completeness_declared     | 0.0/10.0      | add completeness                    |
|                        | (2.2%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_primary_component (2.9%)  | 10.0/10.0     | complete                            |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_source_code (2.2%)   | 0.0/10.0      | add to 70 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_supplier (2.2%)      | 0.0/10.0      | add to 70 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_purpose (1.5%)       | 10.0/10.0     | complete                            |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Licensing (18.3%)      | comp_with_licenses (3.7%)      | 4.9/10.0      | add to 36 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_valid_licenses       | 4.7/10.0      | add to 37 components                |
|                        | (3.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_no_deprecated_licenses    | 10.0/10.0     | complete                            |
|                        | (2.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_no_restrictive_licenses   | 9.1/10.0      | review 6 components                 |
|                        | (3.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_declared_licenses    | 0.0/10.0      | add to 70 components                |
|                        | (2.7%)                         |               |                                     |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_data_license (1.8%)       | 0.0/10.0      | add data license                    |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Vulnerability (12.2%)  | comp_with_purl (12.2% OR)      | 5.0/10.0      | add to 35 components                |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | comp_with_cpe (12.2% OR)       | 8.6/10.0      | add to 10 components                |
+------------------------+--------------------------------+---------------+-------------------------------------+
| Structural (9.8%)      | sbom_spec_declared (2.9%)      | 10.0/10.0     | cyclonedx                           |
+                        +--------------------------------+---------------+-------------------------------------+
|                        | sbom_spec_version (2.9%)       | 10.0/10.0     | v1.5                                |
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

This pulls the SBOM from D-Track → scores it → prints the summary.

The o/p gives you 3 sections:

- Profile Summary Scores for Interlynk, NTIA, BSI profiles
- Interlynk Category Summary
- Interlynk Detailed Score for various categories

See the detailed o/p: <https://gist.github.com/viveksahu26/585b42cf954c4d366dd04b664641fef9>

#### 3. Push the Score Back Into Dependency-Track (As a Tag)

This is the fun part. If you want Dependency-Track to display the SBOM quality score alongside vulnerabilities, licenses, and components… just add one more flag "**tag-project-with-score**":

```bash
sbomqs dt \
  --url "${DEPENDENCY_TRACK_URL}/" \
  --api-key "${DEPENDENCY_TRACK_API_KEY}" \
  ${DEPENDENCY_TRACK_PROJECT_ID} \
  --tag-project-with-score
```

This will attach a tag like:

```bash
interlynk=5.1
```

…directly onto your D-Track project — just like this: 👇
![Dependency-Track project view showing sbomqs quality score tag](/posts/image-38.png)

`interlynk` because by default it scores for `interlynk` [categories](https://github.com/interlynk-io/sbomqs/blob/main/docs/specs/SBOMQS-2.0-SPEC.md#score-categories-with-weights).

The default scoring in sbomqs is for interlynk categories. Apart from it, if you want to attach scoring for various compliances like `ntia`, `ntia-2025`, `fsct`, `bsi`, `bsi-v2.0`, `oct-v1.1`, `interlynk`, etc we do even support it.

In order to score for compliance we call it via `profile`. For say you want to include `ntia` profile score, then `--profile=ntia`:

```bash
sbomqs dt \
 --url "${DEPENDENCY_TRACK_URL}" \
 --api-key "${DEPENDENCY_TRACK_API_KEY}" \
 ${DEPENDENCY_TRACK_PROJECT_ID} \
 --tag-project-with-score \
 --profile ntia
```

This will attach a tag like:

```bash
ntia=5.6
```

![Dependency-Track project view showing NTIA profile score tag](/posts/image-40.png)

Now, let's include **grade** for `ntia` profile, include tag `--tag-project-with-grade`

```bash
sbomqs dt \
 --url "${DEPENDENCY_TRACK_URL}" \
 --api-key "${DEPENDENCY_TRACK_API_KEY}" \
 ${DEPENDENCY_TRACK_PROJECT_ID} \
 --tag-project-with-grade \
 --profile ntia
```

This will attach a tag like:

```bash
ntia-grade=d
```

![Dependency-Track project view showing NTIA grade tag](/posts/image-41.png)

Similarly, you can include other compliance score such as `ntia-2025`, `fsct`, `bsi`, `bsi-v2.0`, `oct-v1.1`, `interlynk`.

For multiple profiles, inlclude like this: `--profile=ntia,ntia-2025,bsi`

![Dependency-Track project view showing multiple compliance profile score tags](/posts/image-42.png)

## Conclusion

With sbomqs, you can now score your SBOM, validate its quality, and push that score directly into Dependency-Track. This makes SBOM quality visible where your team already works and helps everyone make better decisions using trustworthy data.

For any feedback to improve the SBOM quality, just fill up the [form](https://forms.gle/anFSspwrk7uSfD7Q6) or raise an [issue](https://github.com/interlynk-io/sbomqs/issues/new) or even start a [discussion](https://github.com/interlynk-io/sbomqs/discussions).
