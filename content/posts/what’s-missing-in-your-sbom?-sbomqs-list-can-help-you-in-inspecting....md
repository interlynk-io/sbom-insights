+++
date = '2025-09-23T15:19:04+05:30'
draft = false
title = 'What’s Missing in Your Sbom? Sbomqs List Can Help You in Inspecting...'
categories = ['Quality', 'Compliance', 'Tools']
tags = ['SBOM', 'sbomqs', 'Compliance', 'SBOM Quality', 'Validation', 'NTIA', 'BSI', 'Component Analysis']
+++

![alt text](/posts/image-8.png)

Hey there 👋 SBOM practitioners, compliance engineers, and open-source watchers!

If you've been working with SBOMs lately—whether you're producing them or consuming them—you’ve probably noticed how quickly they’ve gone from “nice to have” to absolutely essential. I hope now your getting comfortable on working with SBOMs and familiar with software supply chain security terminologies.

We all are well-known about the wake-up call on SBOMs,

- First one was SolarWinds attack(and later on log4j attack) and
- US Executive Order 14028 by Biden Govt.

And since then, the communities started stepping into this complex world wired with complex software( in form of dependencies) to secure software supply chain security from software supply chain attacks. Next step towards it taken by big organization like OpenSSF and countries by showing up their interest towards it, which resulted into various SBOM guidelines, SBOM related tools, SBOM compliances, SBOM platforms, SCA tools, etc were born.

Since 2021, If we look at present, it’s not just the U.S. leading the charge. From Germany’s BSI to the EU’s CRA, to sector-specific initiatives like OpenChain and FSCT, SBOM compliance frameworks are showing up everywhere—each with its own take on what “good” looks like.

As more of these frameworks take shape, one thing becomes clear:

> It’s no longer enough to just generate an SBOM—you have to make sure it meets compliance expectations.

This is where things get real.

## SBOM Compliance: It’s Getting Real 🔍

One thing is clear in the coming future,

> compliance is no longer optional—it’s the baseline.

Recently Europiun Union can confirmed to make CRA implemented from year 2026. Indian government SEBI organization demanding to filfil their compliances.

Let's take a look at the compliance framework worldwide by countries:

🇺🇸 NTIA Minimum Elements Defined by the U.S. Department of Commerce post-Executive Order 14028, this framework outlines the minimum fields every SBOM should include—author, timestamp, supplier, license info, dependency graph, and more.

🇩🇪 BSI TR-03183-2 Germany’s Federal Office for Information Security (BSI) released one of the most detailed and technical SBOM frameworks to date. It’s not just about structure—it digs into data completeness, consistency, and traceability. And it’s already in version 2.0.

🌐 FSCT (Framing Software Component Transparency) This initiative brings a more global, vendor-neutral view of what “transparency” looks like in SBOMs. It’s about policy and visibility—especially relevant for procurement and risk teams.

📶 OpenChain Telco Born from the telecom sector, this profile maps software transparency back to licensing and open-source usage—core concerns for high-availability infrastructure.

🇪🇺 Cyber Resilience Act (CRA) Still evolving, but already clear in direction: the CRA expects vendors to produce, maintain, and distribute SBOMs as part of software lifecycle accountability. This isn't advisory—it's regulatory.

## Validating SBOMs Against Real-World Compliance ✅

So now that we know what these compliance frameworks demand, the next step is figuring out:

> “Does my SBOM meet these specific requirements?”

That’s where sbomqs comes into play.

It was built exactly for this moment—when having an SBOM isn’t enough, and you need a way to test it against actual compliance rules.

### Enter sbomqs compliance

The sbomqs compliance command allows you to check that any SBOM against these SBOMs global compliance standards with a single command— which gives you the clear, structured report of what’s: ✅ present and what’s ❌ missing by scoring each field out of 10.

What's exactly problem solved by sbomqs compliance command:

- No more guesswork.
- No more opening SBOMs in a text editor.
- No more wondering if it’s “good enough."

Let's have a hands-on:

```bash
# Check BSI compliance in  table view
$ sbomqs compliance --bsi samples/sbomqs-spdx-syft.json

# Evaluate NTIA compliance with JSON output
sbomqs compliance --ntia --json  samples/sbomqs-spdx-syft.json

# Run FSCT compliance in table view
sbomqs compliance --fsct   samples/sbomqs-spdx-syft.json
```

The compliance commands takes a SBOMs and matches against each field present in the compliance framework, i.e NTIA, etc. If it is present, it score as 10, else 0 score.

With just one command, you get a compliance scorecard tailored to the framework you’re working with.

But that’s when a user hit us with a critical insight:

> “Okay, great—I know my SBOM fails the license check...But which components are the problem?And how do I find them without digging through raw JSON?”

And that’s where things got interesting.

### Real-World Problem: "How Do I See Which Components Are Missing What?" 🤔

Running a compliance check gives you the what —

...but what about the where ?

That question came from a user who was validating their SBOM against the BSI TR-03183-2 framework. Everything looked great — until it didin't.

Their SBOM failed the comp_valid_licenses,

And their reaction?

> “Okay… it’s failing. But why?Which components are missing license info?How many are valid? How many aren’t? I can’t just fix this blind—I need to know what to fix.”

And just like that, it became clear:

✅ Scoring is helpful.

🚫 But it’s not enough.

To actually improve your SBOM, you need visibility. You need the ability to break it down field by field, component by component, and see where things fall short. Which field is missing, how many of components missing the field and who are they ?

That’s exactly why we built the next major feature in sbomqs:

### Introducing sbomqs list – Feature-Level Auditing for SBOMs and it's components 🔍

So how do you go from knowing your SBOM failed… to knowing why it failed?

That's exactly what the "sbomqs list" command is designed to solve.

Born directly from real-world user feedback, sbomqs list gives you a way to query your SBOM—on the basis of the feature. Currently we support one feature at a time.

For a particular feature, it doesn’t just tell you if something’s missing—it shows you which components have it, which don’t.

Let’s take a look:

Need to see which components have valid licenses?

```bash
$ sbomqs list --feature=comp_valid_licenses samples/sbomqs-spdx-syft.json
```

The above command will show all the components that contains valid licenses in a SBOM file sbomqs-spdx-syft.json.

2. Want to find the ones that don’t?

```bash
$ sbomqs list --feature=comp_valid_licenses  --missing  samples/sbomqs-spdx-syft.json
```

The above command will show all the components that doesn't contains valid licenses in a SBOM file sbomqs-spdx-syft.json.

**NOTE**:

If your use-case is see multiple features and multiple SBOMs files, something like as shown below. It's a future work, if you curious one about it, you can raise an issue or comment it. This would help to prioterize it.

```bash
#  how many components include both license info and a supplier feature
$ sbomqs list --feature="comp_with_supplier,comp_with_licenses" samples/sbomqs-spdx-syft.json

# show  both license info and a supplier feature for multiple SBOMs?
$ sbomqs list --feature="comp_with_supplier,comp_valid_licenses" samples/*.json
```

### Supported Feature Categories

Currently we support following fields or say features:
**Component-Level Features**

- comp_with_name
- comp_with_version
- comp_with_supplier
- comp_valid_licenses
- comp_with_primary_purpose
- comp_with_restrictive_licenses
- comp_with_checksums
- comp_with_licenses
- comp_with_uniq_ids
- comp_with_any_vuln_lookup_id
- comp_with_deprecated_licenses
- comp_with_multi_vuln_lookup_id

**SBOM-Level Features:**

- sbom_creation_timestamp
- sbom_authors
- sbom_with_creator_and_version
- sbom_with_primary_component
- sbom_dependencies
- sbom_sharable
- sbom_parsable
- sbom_spec
- sbom_spec_file_format
- sbom_spec_version

You can customize your output using flags like:

- `--missing` → show what’s not there
- `--json` → get JSON format results
- `--basic` → shows only numbers in one line.
- `--detailed` → detailed information in table view

### Putting It All Together 🔄

No more guessing. No more scrolling through raw JSON. Just focused, fast, field-level visibility.

1. ✅ Run a compliance check against NTIA, BSI, FSCT, or OpenChain using sbomqs compliance
2. 🚫 Identify which requirements fail—license info, supplier fields, unique IDs, etc.
3. 🔍 Use sbomqs list to drill down into which components are missing those fields or feature.
4. 🛠️ According the suggestion, you can further Update or regenerate your SBOM with clean, compliant data to meet the compliace standards.

This closes the loop between scoring and improving—something most tools don’t offer.

And that’s exactly what sbomqs is built to meet—head-on.

With sbomqs compliance + sbomqs list, you can:

- ✔️ Score against real-world standards
- 🔍 Inspect every component and field
- ⚡ Fix what matters—fast, and at scale

## 🚀 Try it out:

- 🔗 sbomqs GitHub [Repository](https://github.com/interlynk-io/sbomqs)
- 📄 Compliance [Reference](https://github.com/interlynk-io/sbomqs/blob/main/Compliance.md)

Have feedback? Feature ideas? Real-world pain points? 👉 Open an [issue](https://github.com/interlynk-io/sbomqs/issues), we’re building this with the community, for the community.

Because here’s the thing:

> Security doesn’t scale without visibility. Start using sbomqs list today—and give your SBOMs the inspection they deserve.
