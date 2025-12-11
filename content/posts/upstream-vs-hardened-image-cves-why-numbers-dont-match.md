+++
date = '2025-12-11T23:10:15+05:30'
draft = false
title = 'Upstream vs Hardened Image CVEs: Why Numbers Don’t Match, And How SBOM Delta Explains the Real Reason'
categories = ['sbom', 'vulnerability']
tags = ['SBOM', 'vulnerability', 'sbomdelta', 'DevOps']
author = 'Vivek Sahu'
+++




## Introduction

Hey Everyone 👋,

Today, I’m not here to talk about SBOM scoring, compliance, NTIA , or anything as usual. Instead, I want to highlight a completely different, but very real SBOM use case.

This isn't a theoritical problem, it came straight from a Redit thread: <https://www.reddit.com/r/sysadmin/comments/1p1xegu/how_to_verify_vulnerability_deltas_between/>

Reddit question (simplified):
> I compared hardened base images with their official upstream images. Theoretically, CVEs should drop.... but scanner results don’t always match reality.

The user ran Vulnerability Scanner on both images and observed:

> - Some vulnerabilities are silently fixed via backports, but scanners **still flag them**.
> - Some vulnerabilities disappear in hardened images… but only because the **package was removed**, not patched.
> - Some CVEs looked “fixed” in hardened… but were actually new packages introduced with fresh vulnerabilities.

And the legitmate question arises is:
> “***How to objectively measure delta between a hardened image and the upstream one?***"

So let’s break down the three actual problems the Reddit user ran into:

### 1. Scanner False Positives (Backports)

First of all, if you ever noticed that many Linux distros like Ubuntu, Debian, Alpine, RHEL all apply silent backport patches without changing version numbers. And due which vulnerability scanners unable to know about that. As a result scanner shows CVEs still present but in reality it's not, and that leads to a false positive.

### 2. Package Removal/ Package Suppression

Second thing is, in order to reduce the attack surface or even non-required packages are removed from Hardened images to make it lighter in terms of size as well as CVEs. But removal of CVE in this way doesn’t mean that anything was patched.

When you see a raw CVE numbers it creates confusion, like:

- *Did CVEs drop because we reduced attack surface?*
- *Did CVE increases due to introduction a new package in hardened images?*
- *Did CVE drop due to patching?*

At the end just from CVE numbers you can't get visibility into package-level deltas, therefore CVE numbers become noise.

### 3. Raw CVE counts are misleading

When we Compare raw CVEs numbers:

```text
Upstream: 20 CVEs  
Hardened: 50 CVEs
```

then apart from number, it tells you nothing.

You still don't know:

- *How many CVEs disappeared because the package was removed?*
- *How many CVEs appeared due to new packages?*
- *How many CVEs are genuinely common?*
- *How many CVEs are false positives due to backports?*

This missing context is what causes confusion like:
> “***Why does hardened image have MORE CVEs??***”

**So… what is the correct solution?**

One of the most upvoted responses on Redit said:
> **Don’t compare scanner outputs. Compare the real package state.
> Build SBOMs, map package → CVE, detect backports, and compute the delta.**

This is exactly the right answer, so let’s unpack why it works.

## Why SBOM + Vulnerability mapping solves the problem

### 1. SBOM solves package difference: “What Packages actually changed between the Images?”

**SBOM == the real list of installed software**(components + versions + purls)

When you diff two SBOMs, you learn exactly:

**Packages removed**:

- All CVEs attached to these packages should disappear
- This explains “CVE dropped because package vanished”

**Packages added**:

- New CVEs may appear
- This explains “CVE increased because new package introduced a vulnerability”

**Packages unchanged**:

- CVEs should match 1:1 unless backports are involved

Without SBOM it would be impossible to know the package difference or package delta. And that's what SBOM gives you.

### 2. Scanner Results: “Which package has which CVE?”

Basically the vulnerability scanner results tells you about which package is associated with which CVEs.

Interesting thing is:

- SBOM doesn’t know anything about CVEs.
- Scanner doesn’t know anything about package differences.

But together…
**SBOM (packages) + Scanner (CVEs) = full context**

Now you can answer:

- CVEs lost because a package was removed
- CVEs gained because new packages appeared
- CVEs common across identical packages
- CVEs that differ because patch levels differ
- CVEs that are false positives because distro applied backports

This is the full “**delta calculatio**n” the Reddit user was searching for.

### 3. Backport Fixes(The Missing Piece)

Backports are where scanners are wrong most often. How do you detect them?

Two ways:

- Provide a backport vulnerability report file
- Connect with query vendor security tracker db

## Now let's revisit why this solution work

Once you have:

- SBOM(upstream)
- SBOM(hardened)
- CVEs(upstream)
- CVEs(hardened)
- Backport fixes (optional)

You can mathematically compute everything the Reddit user needed.

### 1. Package Difference

| Impact           | Meaning                                      |
| ---------------- | -------------------------------------------- |
| Packages removed | CVEs disappear                               |
| Packages added   | CVEs appear                                  |
| Packages common  | CVEs should match unless patch level changed |

### 2. CVE Difference

| Status             | Meaning                                             |
| ------------------ | --------------------------------------------------- |
| ONLY_UPSTREAM      | vulnerabilities eliminated (by removal or patching) |
| ONLY_HARDENED      | new vulnerabilities introduced                      |
| BOTH_SAME_SEVERITY | unchanged vulnerabilities                           |
| BOTH_DIFF_SEVERITY | patched / upgraded severity changed                 |

### 3. Backport Fixes

When:

```text
Scanner says: vulnerable  
Tracker/SBOM says: patched  
```

- This is false positive

**Is there a tool that already implement this ?** Well... there wasn't. So we built one, **sbomdelta**.

## Introducing sbomdelta

A small, practical CLI that implements the full Reddit-recommended method:

- Compares SBOM(upstream) vs SBOM(hardened)
- Maps package → CVE using your scanner output
- Detects packages removed, added, and common
- Explains CVE reduction due to package removal
- Explains CVE increase due to new packages
- Identifies common CVEs shared across images
- Supports backport-fix exceptions (optional today, real-time tracker integration later)

In other words:

> *Instead of just telling you “Hardened has 50 CVEs”*:
> **sbomdelta tells you why.**

It transforms a confusing black-box CVE count into a clear, fully explained delta:

- Which CVEs disappeared and why?
- Which CVEs appeared and why?
- Which CVEs remained, and where?
- Which CVEs were false positives?

This is the **missing observability layer between hardened and upstream images** in the scanner result, and it finally answers the exact question raised in the Reddit post.

### Hands-on with sbomdelta

Now that you understand the why, let's walk through the how using real images and our CLI tool sbomdelta. We’ll use Syft to generate SBOMs, Trivy to generate vulnerability reports, and then feed everything into sbomdelta eval. For a practical demonstration, let’s compare:

- Upstream image: ubuntu:22.04
- Hardened image: cgr.dev/chainguard/wolfi-base:latest

Chainguard images are perfect for testing because they aggressively remove packages and apply extensive hardening.

#### 1. Generate SBOMs for both Images

We'll use syft:

```bash
syft ubuntu:22.04 -o cyclonedx-json > upstream-sbom.cdx.json

syft cgr.dev/chainguard/wolfi-base:latest -o cyclonedx-json > hardened-sbom.cdx.json
```

What this gives us:

- `upstream-sbom.cdx.json` → list of ALL packages inside Ubuntu
- `hardened-sbom.cdx.json` → list of ALL packages inside Chainguard Wolfi base image

Because SBOMs represent the true, installed package inventory, this allows perfect package-level diffing.

#### 2. Generate vulnerability reports for both Images

You can scan either:

- the image directly, or
- the SBOM itself

Both are acceptable. We will scan the images to keep it simple:
We'll scan the images to keep it simple:

```bash
trivy image -q --format json --scanners vuln ubuntu:22.04 > upstream-vuln.trivy.json

trivy image -q --format json --scanners vuln cgr.dev/chainguard/wolfi-base:latest > hardened-vuln.trivy.json
```

This gives:

- `upstream-vuln.trivy.json` → CVEs for Ubuntu
- `hardened-vuln.trivy.json` → CVEs for Wolfi base

#### 3. Run sbomdelta

```bash
sbomdelta eval \
  --up-sbom=upstream-sbom.cdx.json \
  --hd-sbom=hardened-sbom.cdx.json \
  --up-vuln=upstream-vuln.trivy.json \
  --hd-vuln=hardened-vuln.trivy.json
```

And the o/p is:

```bash
=== SBOM / Vulnerability Delta Summary ===

Packages Delta:
  Removed in hardened: 2378
  Added in hardened:   81
  Common:              15

CVEs (raw counts):
  Upstream total:   26
  Hardened total:   0
  Only upstream:    26
  Only hardened:    0
  Present in both:  0
  High/Crit removed:0
  High/Crit new:    0

Affect of package delta on CVE:
  CVEs from removed packages: 26
  CVEs from added packages:   0
  CVEs on common packages:    0

=== Vulnerability Delta Detail ===
PACKAGE@VERSION                          CVE                  STATUS                 UPSTREAM   HARDENED  
--------------------------------------------------------------------------------------------------------------
coreutils@8.32-4.1ubuntu1.2              CVE-2016-2781        ONLY_UPSTREAM LOW                  
gcc-12-base@12.3.0-1ubuntu1~22.04.2      CVE-2022-27943       ONLY_UPSTREAM LOW                  
gpgv@2.2.27-3ubuntu2.4                   CVE-2022-3219        ONLY_UPSTREAM LOW                  
libgcc-s1@12.3.0-1ubuntu1~22.04.2        CVE-2022-27943       ONLY_UPSTREAM LOW                  
libgcrypt20@1.9.4-3ubuntu3               CVE-2024-2236        ONLY_UPSTREAM LOW                  
libncurses6@6.3-2ubuntu0.1               CVE-2023-50495       ONLY_UPSTREAM LOW                  
libncursesw6@6.3-2ubuntu0.1              CVE-2023-50495       ONLY_UPSTREAM LOW                  
libpam-modules-bin@1.4.0-11ubuntu2.6     CVE-2025-8941        ONLY_UPSTREAM MEDIUM               
libpam-modules@1.4.0-11ubuntu2.6         CVE-2025-8941        ONLY_UPSTREAM MEDIUM               
libpam-runtime@1.4.0-11ubuntu2.6         CVE-2025-8941        ONLY_UPSTREAM MEDIUM               
libpam0g@1.4.0-11ubuntu2.6               CVE-2025-8941        ONLY_UPSTREAM MEDIUM               
libpcre2-8-0@10.39-3ubuntu0.1            CVE-2022-41409       ONLY_UPSTREAM LOW                  
libpcre3@2:8.39-13ubuntu0.22.04.1        CVE-2017-11164       ONLY_UPSTREAM LOW                  
libssl3@3.0.2-0ubuntu1.20                CVE-2024-41996       ONLY_UPSTREAM LOW                  
libstdc++6@12.3.0-1ubuntu1~22.04.2       CVE-2022-27943       ONLY_UPSTREAM LOW                  
libsystemd0@249.11-0ubuntu3.17           CVE-2023-7008        ONLY_UPSTREAM LOW                  
libtinfo6@6.3-2ubuntu0.1                 CVE-2023-50495       ONLY_UPSTREAM LOW                  
libudev1@249.11-0ubuntu3.17              CVE-2023-7008        ONLY_UPSTREAM LOW                  
libzstd1@1.4.8+dfsg-3build1              CVE-2022-4899        ONLY_UPSTREAM LOW                  
login@1:4.8.1-2ubuntu2.2                 CVE-2023-29383       ONLY_UPSTREAM LOW                  
login@1:4.8.1-2ubuntu2.2                 CVE-2024-56433       ONLY_UPSTREAM LOW                  
ncurses-base@6.3-2ubuntu0.1              CVE-2023-50495       ONLY_UPSTREAM LOW                  
ncurses-bin@6.3-2ubuntu0.1               CVE-2023-50495       ONLY_UPSTREAM LOW                  
passwd@1:4.8.1-2ubuntu2.2                CVE-2023-29383       ONLY_UPSTREAM LOW                  
passwd@1:4.8.1-2ubuntu2.2                CVE-2024-56433       ONLY_UPSTREAM LOW                  
tar@1.34+dfsg-1ubuntu0.1.22.04.2         CVE-2025-45582       ONLY_UPSTREAM MEDIUM            
```
