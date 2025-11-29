+++
date = '2025-11-25T14:40:15+05:30'
draft = false
title = 'SBOM scoring into the Dependency-Track '
categories = ['Automation', 'Tools']
tags = ['SBOM', 'sbomq', 'sbom', 'scoring', 'dependency-track', 'Dependency-Track', 'projects']
author = 'Vivek Sahu'
+++


![alt text](image-1.png)

## Introduction

Hey Everyone !!

Today I will be discussing through a very specific practical, real-world use case, something that shows up the moment an organization starts taking software supply chain security seriously. Whether it’s because of internal security, or government push through compliance (like NTIA, BSI), or upcoming regulations like the EU CRA…

If you work with SBOMs, chances are your team is using an SBOM platform like Dependency-Track (or a similar one). These platforms help you monitor vulnerabilities, track licenses, and keep an eye on everything happening inside your software supply chain.

All these powerful analysis, vulnerability detection, risk scoring, compliance checks is only as good as the quality of the SBOM you upload. If the SBOM is incomplete, inconsistent, or missing critical metadata, the platform’s insights start falling apart. In simple terms:

**Poor SBOM** → **Poor analysis** → **Poor decisions**.

That’s why understanding the quality of an SBOM matters just as much as generating the SBOM itself. And to measure that quality, you need a clear, objective score that tells you:

- How complete is my SBOM?
- Does it contains important fields ?
- Is it compliant with standards like NTIA, BSI, or OCT?
- And what is quality score based on pre-defined fields ?

You might already be scoring your SBOMs locally using a tool like **sbomqs**, that part is straightforward. You run a command and instantly get a score.

```bash
sbomqs score new-sbom.spdx.json
```

But your team isn’t spending time looking at raw SBOM files.  All the real action happens inside your SBOM platform such as **Dependency-Track**, dashboards, vulnerability alerts, license monitoring, and so on. So naturally, a question arises:

> What if you want your SBOM quality score inside Dependency-Track itself?

Once an SBOM is uploaded into the platform, you suddenly lose visibility into the score.

So questions like these start popping up:

- How do I push my SBOM score into Dependency-Track?
- How do I make that score visible right to the top?
- And in the future, can I also push NTIA/BSI/OCT compliance scores (thanks to upcoming sbomqs features)?

This blog is about **exactly this use case**, how to bring **SBOM scoring into Dependency-Track** so the people using the platform get the full picture.

So, yeah let's get started....

### sbomqs

A lightweight, open-source CLI tool for measuring the quality and compliance of SBOMs. It  helps you check completeness, correctness, consistency, and gives you a simple score.

sbomqs repo: <https://github.com/interlynk-io/sbomqs>

### Dependency-Track(dtrack)

A popular open-source SBOM platform used by organizations worldwide. It lets you analyze SBOMs in depth, vulnerabilities, components, licenses, risk scoring, and more.

dtrack repo: <https://github.com/DependencyTrack/dependency-track>

### How Scoring Works in sbomqs (And How to Push That Score Into Dependency-Track)

Let’s walk through it step by step.

#### 1. Score an SBOM Locally (The Simple Case)

If the SBOM is already on your machine, scoring it is straightforward:

```bash
sbomqs score my-sbom.spdx.json
```

**NOTE**: For sbomqs installation, refer [here](https://github.com/interlynk-io/sbomqs/blob/main/docs/getting-started.md).

#### 2. Score an SBOM That Already Lives Inside Dependency-Track

If your SBOM is uploaded into D-Track, sbomqs can score it directly from the platform. First, export your credentials and project info:

```bash
export DEPENDENCY_TRACK_PROJECT_ID="05cdcf2b-97ab-479c-be44-ae0d608d8863"

export DEPENDENCY_TRACK_URL="http://localhost:8081/"

export DEPENDENCY_TRACK_API_KEY="odt_WYMdgLZ8sQNEVAfTwD7C5tV55ysQI1Ps"
```

**NOTE**: To setup dtrack installation and know how to retrieve these credentials, refer [here](https://github.com/interlynk-io/sbommv/blob/main/examples/setup_dependency_track.md).

Now fetch and score the SBOM inside Dependency-Track:

```bash
sbomqs dt \
  --url "${DEPENDENCY_TRACK_URL}/" \
  --api-key "${DEPENDENCY_TRACK_API_KEY}" \
  ${DEPENDENCY_TRACK_PROJECT_ID}
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
sbomqs=5.2
```

…directly onto your D-Track project — just like this: 👇

![alt text](image.png)

## Conclusion

At the end of the day, an SBOM is only useful when its data is complete and reliable. Dependency-Track can analyze vulnerabilities and licenses, but the results only make sense if the SBOM itself is high quality.

With sbomqs, you can now score your SBOM, validate its quality, and push that score directly into Dependency-Track. This makes SBOM quality visible where your team already works and helps everyone make better decisions using trustworthy data. And this is just the start—more compliance standards like NTIA, BSI, and OCT are coming next.

For any feedback to improve the SBOM quality, just fill up the [form](https://forms.gle/anFSspwrk7uSfD7Q6) or raise an [issue](https://github.com/interlynk-io/sbomqs/issues/new) or even start a [discussion](https://github.com/interlynk-io/sbomqs/discussions).
