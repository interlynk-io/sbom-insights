+++
date = '2025-09-23T17:12:44+05:30'
draft = false
title = 'sbomasm Enriches Licenses Using ClearlyDefined Datasets'
categories = ['Tools', 'Quality']
tags = ['SBOM', 'sbomasm', 'License Management', 'ClearlyDefined', 'SBOM Quality', 'Open Source', 'Enrichment']
author = 'Vivek Sahu'
description = 'Enrich SBOM license data automatically using sbomasm and ClearlyDefined datasets. Fill NOASSERTION gaps and boost SBOM quality at scale.'
+++

![Blog header for sbomasm license enrichment using ClearlyDefined datasets](/posts/image-24.png)

Hey SBOM enthusiasts 👋,

These are common challenges faced by all SBOM authors. How can fields such as "NOASSERTION", "NONE" be filled at a scale ? This issue is widespread because SBOM generation tools often have gaps and limitation. I do not blame any tool for this; it is beyond their capability, as these tools are primarily design to capture the dependencies of a software. SBOM generation depends on various factors, such as the programming language, the package manager used, the type of SBOM build( source build, build time or post build) and the information provided by the software author on their site.

Let's quickly remember why we create SBOMs.

> An SBOM is meant to provides transparency across your all software dependencies. More broadly, it brings visibility to the entire software supply chain...

However, that visibility or transparency is directly proportional to the quality and completeness of the SBOM data. In short, visibility is directly proportional to SBOM quality.

**What does SBOM quality mean ?** It means that SBOM data to be accurate, complete and trustworthy . In other words, the information provided in the SBOM should be correct and comprehensive. For example, an SBOM should capture all the components present in the software, which determines the completeness.

If an SBOM is missing critical fields or contains incorrect or inaccurate values, the visibility and transparency it provides would become diminished or distorted. As a result, vendors may loose trust in it, SBOM platforms might produce flawed analysis, and ultimately, you’re left with a report that feels more like guesswork than truth.

That’s why,

> Post-processing of SBOM is so important.

To make an SBOM truly valuable and high quality, it needs to undergo process beyond intial generation. This is where augmentation and enrichment comes in; these are the steps that fills the gaps and correct missing details after the SBOM is created.

Take a real world example. Imagine your project has hundreds of components, and a few lack license information. What do you do? You could spend hours manually tracking down the license for each one — but that’s not scalable, especially with modern automation. So, the question arises, **How do you fill those fields ?**

The solution is augmentation and enrichment. Augmentation involves adding crucial information to the SBOM document and it's components provided by the SBOM authors or other trusted sources such as [ecosystm.ms](http://ecosystm.ms/), ClearlyDefined, etc. Some of the critical fields are license, copyright, download location, author, purl ID, etc. Whereas Enrichment refers to the process of adding additional values, from package manages, and external datasets, expanding beyond what’s provided during initial creation.

Okay, now we know what needs to be done to fill the gaps after SBOM generation. And then the next question comes up: **Who provides the values of these missing fields, and how can those values be trusted ?**

The answer lies in centralized, community-driven open source datasets. Projects like [ClearlyDefined](https://clearlydefined.io/) collect and curate license, copyright, download location and metadata information for thousands of open-source components. Instead of manually searching each component, enrichment tools can automatically pull data from these trusted sources and fill in the gaps. This is exactly what Interlynk augmentation tool is addressing in it's new features or latest release.

sbomasm is the augmentation tool from Interlynk. So far, it has helped SBOM authors and to add critical values or corrected exiting information and remove invalid data. These are done only when SBOM author is totally aware of the provided values. But with many missing values or unknown values especially critical fields at scale, then it becomes necessary to use the centralized database to efficiently enrich important fields details in bulk. Now, sbomasm is coming up with new feature to automatically enrich SBOMs using community data source.

## sbomasm enrichment

While mainy tools aims to enrich SBOMs with every possible piece of metadata, but here sbomasm takes a different approach. It's focus is to enrich only the important fields — such as license information. In future, sbomasm will support enrichment of other fields like copyright, download location, etc — whereever reliable, centralized datasets exists.

Currently sbomasm supports license enrichment only. By default, it enriches only those components that have missing license fields. If you want to overwrite and refresh license information for all components, you can use the --force flag.

Let's quickly proceed with hands-on:

1. Enrich the SBOM with license value for missing elements only:

```bash
sbomasm enrich --fields="license"  sbom.cdx.json -o enriched-sbom.cdx.json
```

Here is the o/p:

```bash
Fetching Components Response...
1562 / 1562 [--------------------------------------] 100.00% 37 p/s

Enriching SBOM...
1546 / 1562 [-------------------------------------->_] 98.98% ? p/s

Total: 1750, Selected: 1562, Enriched: 1546, Skipped: 16, Failed: 0
```

The o/p says,

- **Total** → total number of components in the SBOM(1750)
- **Selected** → components with missing licenses(1562)
- **Enriched** → components whose license was successfully added (1546)
- **Skipped** → components whose license couldn't be added (16 )
- **Failed** → components failed to enriched (0)

Those 16 components were skipped ? Usually because ClearlyDefined did not have license data for them, or even if license data exist, it might have non-standard(e.g., 'NOASSERTION' or 'OTHERS' licenses), or because the component lacked PURL information.

One thing to note: enrichment can take a bit of time, and that is purely intentional. By default, sbomasm process 100 components at a time to avoid overloading ClearlyDefined's servers with large payloads. You can adjust these numbers using --chunk-size flag to increase or decrease how many components are processed in each batch.

```bash
sbomasm enrich --fields="license" sbom.cdx.json -o enriched-sbom.cdx.json --chunk-size 500
```

Using a chunk size of 100(by default) took 15 seconds, while increasing it to 500 chunk size, reduced the it down to 6 second, and even increasing further to chunk size 1000, reduced it to 2 second.

For more examples, you can refer [here](https://github.com/interlynk-io/sbomasm/blob/main/docs/enrich.md).

## Wrapping it

With this new update, sbomasm now goes beyond just augmentation. It not only lets you add an extra author, correct inaccurate values, or remove unwanted fields — but also enriches your SBOM with missing licenses at scale.

In short, sbomasm empowers SBOM authors to take full control:

Edit fields when you already know the right values, and

Enrich fields when you don’t, by pulling trusted data from centralized, community-driven datasets like ClearlyDefined.

This balance of author-driven edits and dataset-driven enrichment means your SBOMs can finally be both accurate and complete — without manual busywork.

Let us know what other important field to be enriched next by filing an [issue](https://github.com/interlynk-io/sbomasm/issues/new).

If you loved this project, show the love back by starring ⭐ this [repo](https://github.com/interlynk-io/sbomasm).

Thanks to all the maintainer and contributors of [ClearlyDefined](https://www.linkedin.com/article/edit/7363550491932315648/#?lipi=urn%3Ali%3Apage%3Ad_flagship3_publishing_post_edit%3BegeK3UbTTIuZCm%2Fq42dJCg%3D%3D) projects for making this centralized-community datasets intiative, Github [Repo](https://github.com/clearlydefined/clearlydefined).

## Resources

- sbomasm: <https://github.com/interlynk-io/sbomasm>
- ClearlyDefined: <https://clearlydefined.io/>
