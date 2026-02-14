+++
date = '2025-09-23T16:39:52+05:30'
draft = false
title = 'Monitoring External Github Repos for SBOMs'
categories = ['Automation', 'Tools']
tags = ['SBOM', 'GitHub', 'Monitoring', 'sbommv', 'Open Source', 'Supply Chain', 'Automation']
author = 'Vivek Sahu'
description = 'Monitor external GitHub repos for new SBOM releases with sbommv daemon mode. Automatically fetch and forward SBOMs from open-source dependencies.'
+++

![Blog header for sbommv GitHub release monitoring in daemon mode](/posts/image-14.png)

**GitHub Release Monitoring: SBOM Automation for External Repos** 🚀

If you’ve been following our sbommv blog series, welcome to the fourth one—each post tackling a new challenge around SBOM automation. Here’s a quick recap of what we’ve covered so far:

- **GitHub Release Transfers**: How to fetch SBOMs from GitHub release pages and move them to systems like folders, Dependency-Track, Interlynk, or AWS S3.
- **Folder Monitoring**: Running sbommv in daemon mode to continuously watch a local folder and upload new SBOMs as they appear.
- **AWS S3 Integration**: Adding S3 as both an input and output adapter, enabling SBOM flows to and from S3 buckets.

In short, sbommv is a tool built for automation—designed to seamlessly move SBOMs across systems, with support for format conversion, metadata enrichment, and monitoring workflows like folders.

Now, we’re stepping into a real-world DevSecOps problem: keeping up with SBOMs for external open-source dependencies hosted on GitHub.

Moving one step ahead to deal with real problem,

## The Problem: Watching External Repos for SBOM Updates

As a platform or security engineer, you likely rely on external open-source components like sigstore/cosign, interlynk-io/sbomqs, etc. It's important for an company or organization to keep eye on Open Source dependencies because "**According to a survey 70-80% code are from Open Source**". When these projects cut a new release, many now publish a digital artifacts along with other artifacts such as binaries, signatures, etc known as SBOMs.

Ideally, you'd want to:

- Detect when external OSS projects cut new releases
- Fetch their latest SBOMs
- And transfer it into platforms like SBOM Platforms such as Dependency-Track, Interlynk, or even to your cloud storage AWS S3 storage, or even local folder, etc

But here’s the issue:

> GitHub doesn’t support webhooks for repositories you don’t own.

which means, there's no native way to subscribe to releases of external OSS projects.

This creates a gap:

- You want a system that keeps track of releases from key dependencies
- Automatically fetches new SBOMs when a release drops.
- Pushes them to your SBOM platform or any other o/p systems.
- Without relying on manual checks, brittle scripts, or CI workarounds

You could try building something yourself with polling and custom logic—but that leads to overhead, complexity, maintaining and duplicated effort.

That’s exactly where sbommv GitHub daemon mode comes in.

## Under the Hood: How sbommv Detects New Releases

When sbommv polls a repository in daemon mode, it looks at two key metadata fields from the latest release:

- `release_id`: A unique identifier for the release
- `published_at`: The timestamp when the release was published

These values are saved in a local cache (./sbommv/cache_dtrack_release.json). On each subsequent poll, sbommv compares the current values against the ones stored in cache:

- If the `release_id` and `published_id` match → **No new release**
- If either of them is different → **New release detected**

This lightweight comparison ensures sbommv only reacts when there’s actually something new.

To avoid edge cases where a release is published but its associated SBOMs are still being uploaded (e.g., via GitHub Actions), sbommv waits for a short, configurable delay—defaulting to 3 minutes—before attempting to fetch the SBOM assets.

This delay gives GitHub workflows enough time to finish generating and attaching the SBOMs to the release. You can customize delay time according to your workflow and time taken for your assets to released via flag `--in-github-asset-wait-delay`.

Only after confirming a new release—and giving it time to settle— sbommv proceed to download, validate, and push the SBOMs to the output system.

## SBOM Fetching Methods Supported

SBOM is fetched via GitHub, supports 3 methods:

- **API Method**(default): Fetches the SBOM from GitHub’s Dependency Graph API
- **Release Method**: Pulls SBOMs directly from the release assets.
- **Tool Method**: Clones the repo at the release commit and uses a tool (like Syft) to generate a fresh SBOM

And after fetching, it uploads the SBOMs to the respective o/p system.

## Real-World Example: Tracking sbomqs for New SBOMs

Let’s say your product uses sbomqs, and you want to keep your internal SBOM platform updated with the latest sbomqs SBOMs.

Before running the below command, one thing to keep in mind is that by default poll time is 24hrs, to customize is provide the flag --in-github-poll-interval:

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--in-github-method="release" \
--in-github-poll-interval=60s \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--daemon
```

This command does the following:

- Enters daemon mode
- Monitors the sbomqs GitHub repo every 60 seconds
- On detecting a new release, downloads SBOMs from the release page
- Waits briefly to ensure assets are ready
- Uploads them to Dependency-Track
- Updates cache to avoid re-uploading the same version

**NOTE**:

> On the first run, sbommv will treat any repository as "new" and will fetch + upload the SBOMs while caching the release metadata for future comparisons.

Similarly, you want to keep eye on multiple repos such as sbomqs and sbommv at a time, run below command:

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io" \
--in-github-include-repos=sbomqs,sbommv
--in-github-method="release" \
--in-github-poll-interval=60s \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--daemon
```

## Why This Matters

GitHub is the central hub for modern open-source. But without automation, tracking releases and managing SBOMs quickly becomes a manual, error-prone mess.

With GitHub daemon mode, you:

- Keep SBOM platforms in sync with upstream changes
- Ensure no SBOMs are missed for external dependencies
- Cut down on manual tracking or brittle custom scripts

It’s automation designed for how real-world software is built and secured.

## Resources

- GitHub Daemon design [docs](https://github.com/interlynk-io/sbommv/blob/main/docs/github_daemon.md)
- [Monitoring](https://github.com/interlynk-io/sbommv/blob/main/examples/github_dtrack_examples.md#4-continuous-monitoring-daemon-mode-github--dependencytrack) GitHub External Repos and uploading to Dependency Track
- [Monitoring](https://github.com/interlynk-io/sbommv/blob/main/examples/github_interlynk_examples.md#4-continuous-monitoring-daemon-mode-github--interlynk) GitHub External Repos and uploading to SBOM platform - Interlynk
- [Monitoring](https://github.com/interlynk-io/sbommv/blob/main/examples/github_folder_examples.md#4-continuous-monitoring-daemon-mode-github--folder) GitHub External Repos and downloading to local folder
- [Monitoring](https://github.com/interlynk-io/sbommv/blob/main/examples/github_s3_example.md#5-continuous-monitoring-daemon-mode-github--s3) GitHub External Repos and uploading to AWS S3 bucket
- Get Started with [sbommv](https://github.com/interlynk-io/sbommv/blob/main/docs/getting_started.md)
