+++
date = '2026-05-20T10:00:00+05:30'
draft = false
title = 'Component Quality in sbomqs: Moving Beyond Static Checks to Real Component Health'
categories = ['Quality', 'Security', 'Tools']
tags = ['SBOM', 'sbomqs', 'Component Quality', 'PURL', 'CPE', 'Supply Chain Security', 'sbomqs v2', 'Vulnerability Management']
author = 'Vivek Sahu'
description = 'sbomqs introduces Component Quality analysis, a new layer of SBOM validation that goes beyond checking field presence to validating components against live external data — starting with identifiers and expanding to EOL, malicious, and vulnerability intelligence.'
slug = 'component-quality-in-sbomqs-real-component-health'
+++

![Blog header for sbomqs Component Quality feature](/posts/image-comp-quality.png)

Hey SBOM community 👋

If you've been using sbomqs for a while, you know it does a solid job of telling you **what's in** your SBOM, not just that fields exist, but what values they actually hold. Names, versions, licenses, suppliers, checksums, PURLs, CPEs — every field and its corresponding value, laid out right there in your SBOM. And when something's missing? The `score` command returns a 0 score on it so you can't miss it, while the `list` command shows you exactly which components are empty and which ones have real values. It's a transparent, no-nonsense way to audit your SBOM's contents.

And all these field checks come from compliance. So far, we've been scoring SBOMs against different compliances like NTIA, BSI (v1.1, v2.0, v2.1), OCT, FSCT, and more. Every compliance has its own way of looking at transparency into your software by asking for different information(fields) like: name, version, license, PURL, CPE, copyright, dependencies, and so on. sbomqs has been doing an amazing job checking your SBOM against these compliances and scoring whether those fields are present. Compliance is still necessary and always will be.

> But here's the thing — having fields and values isn't the same as validation of it's contents.

For say, your SBOM might have a PURL and CPE for every component. The compliance check passes with flying colors and recieved scored 10/10 for both PURL/CPE. But here is the twist:

> what if that PURL doesn't actually resolve to anything?
> What if the CPE isn't in the NVD database?
> What if a component was abandoned years ago, or worse, flagged as malicious in a threat database?

That's the gap between **static analysis** (are the fields present?) and **dynamic analysis** (do those fields *mean* something in the real world?)

And that's exactly why we're introducing **Component Quality analysis** in sbomqs, a new category that brings dynamic analysis into the mix with six fields: `comp_purl_valid`, `comp_cpe_valid`, `comp_eol_eos`, `comp_malicious`, `comp_vuln_sev_critical`, and `comp_kev`. Right now we've started with the first **2 fields**: `comp_purl_valid` and `comp_cpe_valid`. Based on community feedback and demand, we'll be rolling out the rest soon. Here the feedback form: <https://forms.gle/WVoB3DrX9NKnzfhV8>

## What sbomqs has been doing: Static Analysis 📝

Let's take a step back and understand what "static" actually means in the context of SBOM quality.

**Static analysis** is the practice of examining the SBOM file itself, the data that's right there in the SBOM, without validating it to external sources, databases, or the internet. It's a self-contained audit of the document.

Everything sbomqs has done until now falls under this umbrella:

- NTIA compliance scoring: does the SBOM have author, timestamp, supplier, dependency graph?
- BSI v1.1 / v2.0 / v2.1 scoring: are the required fields present with correct values?
- FSCT, OCT, Interlynk profiles: do components have names, versions, licenses, checksums?

At the end of the day, sbomqs reads the SBOM, looks for specific fields, checks whether values exist (and sometimes whether they match expected patterns), and assigns a score. This is incredibly valuable. Static analysis ensures **structural completeness** and **compliance readiness** and that's what for sbomqs made for. If your SBOM is missing a creation timestamp or half your components don't have versions, you need to know that before you share it with anyone.

But here's the catch: **static analysis only knows what the SBOM tells it.**

## The Problem with Static Analysis 😬

An SBOM can be *structurally perfect* and still be *operationally useless*.

Imagine an SBOM where every single component has a PURL and a CPE. Static analysis gives it a perfect score: 10/10, compliance passed, gold stars all around. But what if:

- Those PURLs don't actually resolve to any package manager or repository? (They're syntactically correct but point to nowhere.)
- Those CPEs aren't in the NVD database? (No vulnerability scanner can map them to CVEs.)
- A component reached end-of-life two years ago and no longer receives security patches?
- A library was flagged as malicious in a threat intelligence database last month?
- A dependency has a critical CVE with an active exploit in the wild?

Your SBOM looks complete on paper. Your compliance checklist is green. But your *actual* supply chain risk is completely invisible. You've built a beautiful inventory of components that you can't actually look up, verify, or trust.

That's the fundamental limitation of static analysis: **it validates presence, not truth.**

## Enter Dynamic Analysis: What It Means and Why It Matters 🌍

**Dynamic analysis** is the practice of validating SBOM data against *live, external sources*. Instead of asking "is the field there?", it asks "does this field *mean* something in the real world?"

This requires reaching out to external databases, registries, and threat intelligence feeds, something that wasn't previously part of sbomqs' scope. It's more expensive (needs API calls), more complex (handles rate limits, retries, partial failures), but infinitely more powerful.

Dynamic analysis answers questions like:

- Does this PURL resolve to a real package in Maven Central, npm, PyPI, or another registry?
- Does this CPE exist in the NVD CPE dictionary?
- Is this component actively maintained, or has it been abandoned?
- Is there a known critical vulnerability affecting this exact version?
- Is this component listed in CISA's Known Exploited Vulnerabilities catalog?
- Has this package been flagged as malicious or compromised?

These aren't theoretical concerns. They're the difference between an SBOM that *looks* good and an SBOM that *is* good. Dynamic analysis closes the gap between document completeness and real-world trustworthiness.

## How Component Quality Solves the Static Problem 🔧

Component Quality analysis is sbomqs' step into the dynamic layer. Each of the six fields maps directly to a weakness in static analysis:

| Field | Static Problem It Solves | Why It Matters |
|-------|------------------------|----------------|
| `comp_purl_valid` | Static checks confirm a PURL string exists, but can't tell if it's a real package | If the PURL is fake, vulnerability scanners can't look it up. Your SCA pipeline breaks silently. |
| `comp_cpe_valid` | Static checks confirm a CPE string exists, but can't tell if it's in NVD | If the CPE isn't in NVD, you get zero CVE coverage for that component. |
| `comp_eol_eos` | Static checks can't know if a component is still maintained | EOL components don't receive security patches. You might be running vulnerable code without knowing it. |
| `comp_malicious` | Static checks can't detect if a package was later flagged as malicious | A component might have been clean when the SBOM was generated, but flagged since. Static data goes stale. |
| `comp_vuln_sev_critical` | Static checks don't know about live vulnerability disclosures | Your SBOM might have been generated before a critical CVE was published. Static scoring won't catch it. |
| `comp_kev` | Static checks can't know if a vulnerability is actively exploited in the wild | CISA KEV is a living list. A component that passed static checks yesterday might be on KEV today. |

Together, these six fields transform your SBOM from a *snapshot* into a *living health report*. They answer the questions that static analysis simply cannot.

## What We're Shipping Today 🚀

We're building this out in phases. Today, the first piece of Component Quality is live: **identifier validation**.

Here's what sbomqs checks right now when you enable component quality analysis:

| Feature | What It Answers |
|---------|---------------|
| `comp_purl_valid` | Does this PURL resolve to a real package manager or repository? |
| `comp_cpe_valid` | Is this CPE found in the NVD CPE database? |

Why start here? Because PURLs and CPEs are the **connective tissue** of your SBOM. They're what vulnerability scanners, SCA tools, and compliance platforms use to look up components downstream. If they're wrong or fake, every subsequent step: scanning, triage, reporting, becomes unreliable.

Identifier validation is the foundation. It directly solves the "fake identifier" problem we discussed above. Everything else (EOL, malicious, CVE, KEV) builds on top of having valid identifiers to look up.

And because the remaining four fields rely on external API support that is still being rolled out, they'll light up in sbomqs automatically as the Interlynk API expands, no tool upgrade needed on your side.

## How It Works Under the Hood 🔧

When you enable component quality analysis, sbomqs does something new: it sends your SBOM's components to the **Interlynk Component Quality API** (`/api/v1/doctor/check`). The API looks up those identifiers in real-world databases and returns findings.

Here's the good news: sbomqs handles all the complexity for you.

- **Smart Batching**: Large SBOMs are chunked into efficient batches (up to 5,000 components for authenticated users, 50 for unauthenticated) and sent in parallel.
- **Rate-Limit Resilience**: If the API returns HTTP 429, sbomqs retries with exponential backoff up to 3 times.
- **Graceful Degradation**: If the API is unreachable, scoring continues normally. Component Quality shows as N/A. No broken CI pipelines.

And here's something important: **Component Quality is informational only.** It does **not** affect your overall sbomqs score.

Why? Because we're intentionally separating *structural quality* (does the SBOM have the right fields?) from *component health* (are the actual packages healthy?). As the ecosystem matures and these checks become standard, we'll revisit how they factor into scoring. For now, it's an opt-in lens, use it to spot problems, not to gate releases.

## Getting Your Hands Dirty 💻

### Step 1: Get an API Key

Component Quality is **opt-in**. Grab an API key from your [Interlynk profile](https://app.interlynk.io/) under **Profile → Security Token → Personal Token**, or set it as an environment variable:

```bash
export INTERLYNK_SECURITY_TOKEN="your-api-key-here"
```

### Step 2: Enable Component Quality Analysis

```bash
sbomqs score --enable-component-analysis my-app.spdx.json
```

Pass the key inline if you prefer:

```bash
sbomqs score --enable-component-analysis --api-key "your-api-key" my-app.cdx.json
```

Or point to a custom Interlynk instance:

```bash
sbomqs score --enable-component-analysis \
  --api-url "https://api.interlynk.io" \
  --api-key "your-key" \
  my-app.spdx.json
```

### What You'll See

In the detailed score output, a new **Component Quality** section appears:

```text
+-------------------+--------------------------------+---------------+-------------------------------------+
|     CATEGORY      |            FEATURE             |     SCORE     |                DESC                 |
+-------------------+--------------------------------+---------------+-------------------------------------+
| Component Quality | comp_purl_valid                | 7.5/10.0      | 30/40 PURLs are valid               |
|                   | comp_cpe_valid                 | 2.0/10.0      | 8/40 CPEs are valid                 |
|                   | comp_eol_eos                   | Coming Soon.. | N/A                                 |
|                   | comp_malicious                 | Coming Soon.. | N/A                                 |
|                   | comp_vuln_sev_critical         | Coming Soon.. | N/A                                 |
|                   | comp_kev                       | Coming Soon.. | N/A                                 |
+-------------------+--------------------------------+---------------+-------------------------------------+
```

**A Note on Scoring:**

sbomqs only scores components that the API successfully **verified**. If a component returns no findings at all, it's marked as N/A, not as a pass or a fail. This keeps the scoring honest and avoids penalizing components that simply weren't in the check scope.

- **Verified + matching finding** = affected (failed)
- **Verified + no matching finding** = passed
- **No findings at all** = N/A (unverified)

This is intentional. We only count what we can prove.

## What's on the Roadmap 🔮

Identifier validation is just the beginning. Here's what's already defined in the Component Quality category and coming as the Interlynk API expands:

| Feature | What It Will Check |
|---------|-------------------|
| `comp_eol_eos` | Is the component end-of-life or end-of-support? |
| `comp_malicious` | Is the component flagged in threat intelligence databases? |
| `comp_vuln_sev_critical` | Does the component have critical vulnerabilities? |
| `comp_kev` | Is the component on the CISA Known Exploited Vulnerabilities catalog? |
| `comp_purl_valid` | ✅ Already live |
| `comp_cpe_valid` | ✅ Already live |

As these checks go live in the API, they'll automatically light up in sbomqs, no upgrade needed on your side. The architecture is already there; we're just waiting for the data.

## Why This Matters for Your Supply Chain 🏗️

Think about the lifecycle of an SBOM after it's generated. It gets fed into vulnerability scanners, shared with customers, audited for compliance, and used to trigger incident response.

Now imagine every one of those steps relying on a PURL that doesn't resolve, or a CPE that doesn't exist in NVD. The scanner says "not found." The audit says "unverifiable." The customer says "we can't accept this."

Component Quality catches that at the source. It's a smoke test for the *connective tissue* of your SBOM, making sure the identifiers actually *work* in the real world, and eventually, making sure the components themselves are healthy.

And because it's opt-in and informational, you can turn it on today without touching your existing score thresholds or CI gates. Use it to audit, clean up, and build confidence. Then, as the checks mature, decide how deeply you want to integrate them into your pipeline.

## Wrapping It Up 🎯

SBOM quality has come a long way. We've gone from "do you have an SBOM?" to "does your SBOM have the right fields?" and now to "are the actual components in your SBOM healthy and verifiable?"

Component Quality analysis is sbomqs' step into that third phase. It's not about replacing structural checks, it's about adding a layer of **real-world intelligence** on top of them. Presence checks tell you the field is there. Component Quality tells you if the field *means* something.

Right now, that means validating PURLs and CPEs. Soon, it will mean catching EOL packages, malicious components, and exploited vulnerabilities before they ever reach production.

So go ahead. Turn it on. See what your identifiers actually resolve to. And start treating your SBOM not just as a document, but as a **living health report** for your software supply chain.

```bash
sbomqs score --enable-component-analysis your-sbom.json
```

Interested with this feature, fill out this [form](https://forms.gle/WVoB3DrX9NKnzfhV8) and show your interest towards this feature.
Apart from that any Feedback? Ideas? Want to prioritize a specific check? Drop us an [issue](https://github.com/interlynk-io/sbomqs/issues/new). And if you like where this is headed, show some love with a ⭐ on the [sbomqs repo](https://github.com/interlynk-io/sbomqs).

For the full platform experience, compliance scoring, vulnerability detection, automated enrichment, and team collaboration, check out [Interlynk](https://app.interlynk.io).

Keep building, keep validating, and keep your supply chain trustworthy 🔒

## Resources

- Component Quality Feature Community Form: <https://forms.gle/WVoB3DrX9NKnzfhV8>
- sbomqs GitHub: <https://github.com/interlynk-io/sbomqs>
- Component Quality docs: <https://github.com/interlynk-io/sbomqs/blob/main/docs/commands/score.md>
- Interlynk Platform: <https://www.interlynk.io>
