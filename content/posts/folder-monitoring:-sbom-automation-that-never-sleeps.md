+++
date = '2025-09-23T14:40:15+05:30'
draft = false
title = 'Folder Monitoring: Sbom Automation That Never Sleeps'
categories = ['Automation', 'Tools']
tags = ['SBOM', 'Automation', 'sbommv', 'Monitoring', 'CI/CD', 'Dependency-Track', 'DevOps']
author = 'Vivek Sahu'
+++

![alt text](/posts/image-7.png)

## Introduction

In our previous post(GitHub Releases are where SBOM's goto die), we tackled a growing pain in modern software security: SBOMs stuck in GitHub Releases. We showed how sbommv streamlines the manual mess—automating the movement of SBOMs from GitHub or local folders directly into SBOM platforms like Dependency-Track, Interlynk(next blog will show demo on this).

We covered:

- 🔄 Pulling SBOMs straight from GitHub via API or releases
- 🧳 Uploading pre-existing SBOMs from local folders
- 🔍 Using dry-run mode to validate before uploading

And transferring those fetched SBOMs to dependency-track platform smoothly and seamlessly. That was the start. But it still required you to trigger the command each time, especially when input adapter or input system(source of SBOMs) is folder.

Now we’re taking it a step further, **SBOM automation that doesn’t wait for you when SBOMs are present in the folders.**

## Introducing: Folder Monitoring 📁⚡

Imagine a workflow where you don’t even have to run a command when source of SBOM is a folder(i.e input system/adapter is folder). SBOMs just shown up in a folder—maybe from your CI pipeline, a nightly build job, or a dev tool—and sbommv running in the daemon mode, instantly detects it, validates it, convert it to CycloneDX spec and ships them off to SBOM platforms.

![alt text](/posts/image.png)

In theory, SBOM automation should “just work.” But in reality, users are still asking [this](https://github.com/DependencyTrack/dependency-track/discussions/4256):

> “Is there a tool that can automate SBOM uploads to Dependency-Track outside of CI?”

> “We generate SBOMs for different modules in CI, but once deployed on a customer site—where there’s no internet—we need a way to update their local Dependency-Track install automatically when new SBOMs show up.”

That’s not a one-off question—it’s a pattern. Products deployed on-premise, CI pipelines that export SBOMs, Air-gapped environments, and teams stuck manually syncing SBOMs post-deployment.

Now, you don’t have to, if SBOM source is folder.

**NOTE**: This automatically fetching or triggering SBOMs, in technically sbommv running in the background, i.e daemon mode is only for folder input adapter.

## Meet Folder Monitoring

With sbommv's new folder monitoring mode, all you have to do is drop the SBOM in a watched folder—

- ✖️ no scripts,
- ✖️ no re-runs,
- ✖️ no manual uploads.

sbommv running in the background i.e. in daemon mode automatically detects it, validates it, and ships it off to your local Dependency-Track, Interlynk, or other SBOM platforms.

It’s like turning your file system into an event-driven pipeline:

- Your CI drops a new SBOM → 📂 Folder event triggered
- sbommv running in daemon mode auto-detects → ✅ Validates
- Convert the SPDX spec into CycloneDX spec, especially for Dependency-Track system
- Automatically uploaded → 🔁 Project updated in Dependency-Track

No human in the loop. No risk of missing uploads.

Here’s what a real-world setup looks like. Let's switch on to some hands-on work.

### 1️⃣ Monitoring a Local Folder (Flat Structure)

Let’s start with the simplest case: watch a single-level folder named  demo, and upload any SBOM that shows up there.

```bash
$ mkdir demo

$ sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
-d
```

Once started, sbommv enters daemon mode—actively listening for events in demo directory.

Now, let's drop an SBOM in demo (or use sbommv to fetch one and drop it to folder):

```bash
# fetch SBOM from input adapter github and save it to output adapter folder 
$ sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--output-adapter=folder \
--out-folder-path=demo

2025-04-08T21:45:06.651+0530	INFO	logger/log.go:102	wrote	{"path": "demo/3c62fca7-28d9-4b68-903f-e471b2e4619c.sbom.json"}
2025-04-08T21:45:06.651+0530	INFO	logger/log.go:102	wrote	{"sboms": 1, "success": 1, "failed": 0}
```

Immediately, the following happens: detects SBOM and uploaded it to dependency track

![alt text](/posts/image-3.png)

Let's check dependency-track platform, whether SBOM is uploaded or not? Yeah, it's uploaded...

![alt text](/posts/image-1.png)

![alt text](/posts/image-2.png)

Let's understand what happens:

- Ran sbommv in daemon mode, monitoring folder
- Drop a SBOM with the help of sbommv from fetching it from github to demo folder
- 📂 Event triggered: CREATE & WRITE → demo/<SBOM-FILE>.json
- ✅ Detected as SBOM
- 🚀 Uploaded to Dependency-Track

### 2️⃣ Deep Monitoring: Sub-directories Included

Need to monitor sub-folders too? Add one flag --in-folder-recursive=true

```bash
$ mkdir  -p  demo/again 

$ sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--in-folder-recursive=true \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
-d
```

Now, let's drop an SBOM in demo (or use sbommv to fetch one and drop it to folder):

```bash
$ sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--output-adapter=folder \
--out-folder-path=demo/again
```

![alt text](/posts/image-4.png)

Immediately, the following logs appeared: detects SBOM and skip uploading  to dependency track. This is because same SBOM is trying to get uploaded in same project. Will talk about this in next section.

![alt text](/posts/image-5.png)

Each nested directory is auto-watched. Each SBOM is independently tracked and uploaded as it's added.

Let's understand what happens:

- Ran sbommv in daemon mode, monitoring folder
- Drop a SBOM with the help of sbommv from fetching it from github to demo/again folder
- 📂 Event triggered: CREATE & WRITE → demo/<SBOM-FILE>.json
- ✅ Detected as SBOM
- 🚀 Skipped uploading to Dependency-Track

The SBOM overwrite is controllable via sbommv overwrite flag. Let's see in next section.

### 3️⃣ Controlling Overwrites

By default, sbommv does not upload a new SBOM if a project with the same name and version already exists in Dependency-Track. This avoids unnecessary updates.

But here’s the twist:

Dependency-Track itself always overwrites SBOMs when they’re uploaded—even if they're identical.

To give you more control, sbommv introduces the `--overwrite` flag:

- **Default Behavior** (--overwrite=false): Uploads are skipped if the SBOM’s primary component name + version matches one already uploaded. This avoids duplicate uploads.
- **Overwrite Option** (--overwrite=true): Forces upload every time—even if the SBOM already exists. Useful for rebuilds or when updating SBOM content while keeping the same component name/version.

This flag is handled entirely by sbommv, works with any adapter, and ensures you stay in control of what gets updated.

```bash
$ sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--overwrite \
-d
```

Try out it again, and you will see that this time it's uploaded instead of being skipped.

### 4️⃣ Preview Everything with Dry-Run 🧪

Not ready to go live yet? You can simulate it all with --dry-run:

```bash
$ sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--in-folder-recursive=true \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
-d \
--dry-run
```

![alt text](/posts/image-6.png)

This outputs:

- 👁️ SBOMs detected in preview mode
- 📝 For Input adapter preview mode it shows:  Format, spec version, and file names
- 📦 And for Output adapter preview mode shows: Project names & versions that would be created
- 📊 Total count

It’s just to see what's there in the input adapter and what's going to be uploaded in a preview mode, before executing command in actual.

Let’s recap what happens under the hood when a new SBOM shows up in the watched folder:

1. 📂 Event Triggered – CREATE + WRITE
2. 🕵️ File Validated – Only valid SBOMs are picked up
3. 🔄 Format Upgraded – E.g., SPDX 2.2 → SPDX 2.3 → CycloneDX
4. 📤 Project Created/Updated in DTrack
5. ✅ Upload Complete – You’re done

You’ll see clean logs showing every step—what was detected, what was uploaded, what was skipped, and what was ignored.

## Why This Matters

> SBOMs are no longer one-time artifacts. They evolve with every commit, build, patch and new version. 

Real-time folder monitoring brings SBOM automation closer to how modern dev and DevSecOps teams actually work.

It:

- ✔️ Keeps security platforms updated in sync with software changes
- ✔️ Removes the lag between SBOM generation and analysis
- ✔️ Enables hands-off, always-on SBOM pipelines

No more missed uploads. No more backlogs.

## What’s Next?

Now that folder monitoring is live, we’re already looking ahead:

- Interlynk Platform demo: blog on using Interlynk as a destination system covering both sbommv use-cases.
- ☁️ S3 Bucket Integration:  as input as well as output system for source as well as destination.
- ☁️ S3 Bucket Monitoring – Watch S3 for incoming SBOMs and upload automatically

We’re just getting warmed up.

Stay tuned for hands-on guides with Interlynk Platform + folder monitoring workflows. Want early access?  

⭐ Star the repo: https://github.com/interlynk-io/sbommv and drop us a message for your use s like integration your SBOM source systems or SBOM platform system, will love to integrate them.
