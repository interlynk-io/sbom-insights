+++
date = '2025-09-23T14:09:20+05:30'
draft = false
title = 'Github Releases Are Where SBOMs Goto Die'
categories = ['Automation', 'Tools']
tags = ['SBOM', 'GitHub', 'Automation', 'sbommv', 'Dependency-Track', 'Software Supply Chain', 'CI/CD']
author = 'Vivek Sahu'
description = 'SBOMs stuck in GitHub Releases slow down security teams. See how sbommv automates SBOM transfers to platforms like Dependency-Track seamlessly.'
+++

![Blog header for automating SBOM transfers from GitHub releases using sbommv](/posts/image-30.png)

Hey there 👋, SBOM enthusiasts ! Since the [2021 Cyber security Executive Order](https://www.nist.gov/itl/executive-order-14028-improving-nations-cybersecurity) by Joe Biden. SBOMs (Software Bill of Materials) have become essential for software security and compliance. With countries like the [EU](https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act), [US](https://www.ntia.gov/sites/default/files/publications/sbom_minimum_elements_report_0.pdf), [Germany](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Publications/TechGuidelines/TR03183/BSI-TR-03183-2-2_0_0.pdf?__blob=publicationFile&v=3), and [India](https://www.cert-in.org.in/PDF/SBOM_Guidelines.pdf) introducing their own SBOM regulations, it’s clear:

> SBOMs aren’t optional anymore—they're the new standard.

To meet this demand, tools for SBOM generation, signing, quality analysis, enrichment, and integration into security platforms have rapidly evolved, largely driven by the open-source community.

## The SBOM Transfer Challenge

Once generated, an SBOM typically needs to be manually downloaded, uploaded, and integrated into security tools, requiring human intervention at multiple steps.

This approach is:

- ❌ **Time-consuming** – Repeatedly downloading and uploading SBOMs consumes valuable time.
- ❌ **Error-prone** – Manual handling increases the chance of error.
- ❌ **Outdated** – In an era of automation, relying on manual workflows simply doesn’t scale.

> Manual way has become an old fashion in the world of Automation.

This inefficiency is a major bottleneck for security teams and slows down software supply chain risk management.

## Seamless SBOMs transfer using sbommv

At [Interlynk](https://www.interlynk.io/), we designed [sbommv](https://github.com/interlynk-io/sbommv) to **enable seamless SBOM transfers across systems**. Its modular architecture supports input and output adapters, along with translation and enrichment, ensuring flexibility and adaptability. This design makes sbommv highly extensible, allowing easy integration with additional systems in the future.

- **Eliminates manual work** – No more downloading, uploading, or tedious file handling.
- **Effortless and Seamless integration** – Seamlessly moves SBOMs across platforms with minimal setup.
- **Scalable & future-ready** – Adapts to evolving security and compliance needs.

🚀 With sbommv, **SBOMs flow from source to destination with zero manual effort** — eliminating human intervention and aligning perfectly with the modern automation-first approach.

## Real-World Scenario

Many software projects **publish SBOMs on GitHub**, alongside binaries, archives, executables, and signatures. The SBOMs artifacts are also termed as **digital artifacts**.

Once an SBOM is generated, it needs to be transferred to **SBOM management platforms** like [Dependency-Track](https://dependencytrack.org/), [Interlynk](https://www.interlynk.io/) and other security tools for deeper analysis, vulnerability assessments, and compliance tracking. However, this process is often manual and inefficient. Security teams or engineers typically have to **locate, download, and upload SBOMs manually** adding unnecessary overhead and increasing the risk of errors.

This outdated workflow involves:

1️⃣ **Manually searching** for SBOMs in GitHub releases or other repositories.
2️⃣ **Downloading and re-uploading** them to SBOM management platforms for processing.
3️⃣ **Repeating this process** for every software release, across multiple repositories—leading to wasted time and potential inconsistencies.

This **manual workflow is widespread** across open-source projects, enterprises, and regulated industries, where software security and compliance are critical. As software development accelerates and release cycles shorten, the frequency of SBOM generation grows. Relying on **manual SBOM transfers is no longer practical** — organizations need a scalable, automated approach to keep up.

To address this challenge, let’s explore a hands-on guide for efficiently transferring SBOMs across systems via sbommv...

## sbommv in action 🚀

### Installation

```bash
brew tap interlynk-io/interlynk
brew install sbommv
```

For any other installation methods, you can follow this [guide](https://github.com/interlynk-io/sbommv?tab=readme-ov-file#installation).

## Hands-on with sbommv

Before transferring SBOMs from Github to Dependency-Track, ensure you have installed and running. For detailed Dependency-Track installation steps, refer to the [Appendix](Appendix: Setting Up Dependency-Track) at the buttom section.

We are done with setting up prerequisites for sbommv. Let’s unleash the power of sbommv…

### 1. Automated SBOM transfer from GitHub to Dependency-Track

This is the simplest and most automated way to manage SBOMs with minimal user effort. It leverages GitHub's [API](https://docs.github.com/en/rest/dependency-graph/sboms?apiVersion=2022-11-28) to automatically pulls the SBOM for the latest main branch, as GitHub allows to export SBOM for an repository.

**NOTE**: Enable SBOM export through the [Dependency Graph API](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/configuring-the-dependency-graph)

Run the following command to fetch the SBOM from the sbommv repository and move it to Dependency-Track:

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbommv" \
--output-adapter=dtrack  \
--out-dtrack-url="http://localhost:8081"
```

**After execution:**

- The SBOM is fetched --> converted to CycloneDX --> uploaded to Dependency-Track.
- If the project doesn’t exist, it is auto-created in Dependency-Track. Above it is created with a name interlynk-io/sbommv-latest.
- Along with project creation it adds description and tags. Above the description is added as - "Created & uploaded by sbommv" and tags as "github" and "sbommv".

#### Pros & Cons of Using GitHub API Method for SBOM Transfer

As GitHub allows SBOMs to be exported manually or via its Dependency Graph API making it a convenient source of SBOM.

#### ✅ Pros

✔️ **Fully Automated** – Eliminates the need to manually generate and transfer SBOMs.
✔️ **Keeps Projects Up-to-Date** – Automatically syncs with Dependency-Track, ensuring that the latest SBOM is always available.
✔️ **Fastest way to get started**, without using any tools for SBOM generation.

#### ❌ Cons

⚠️ Limited to Main Branch – GitHub’s API only provides SBOMs for the default branch, meaning it lacks visibility into past versions or specific releases.
⚠️ No Historical Snapshots – It does not capture SBOMs for previous versions of the software, which may be critical for compliance or security audits.

#### Alternative GitHub Methods for More Advanced SBOM Workflows

For teams needing greater control over SBOM extraction, sbommv supports additional GitHub methods beyond the API approach:

- **Release-Based Method** – Fetches all SBOMs from GitHub releases, ensuring version history is captured.
- **Tool-Based Method** – Clones the repository and generates fresh SBOMs using tools like Syft, providing a more comprehensive software bill of materials.

These options allow for deeper insights, better version tracking, and more complete SBOM management beyond what GitHub’s API alone can offer.

### 2. Uploading pre-existing SBOMs from a folder to Dependency-Track

In cases where SBOMs are already stored locally, sbommv can seamlessly transfer them from a **Folder** to **Dependency-Track**

To demonstrate this, let’s populate a local folder with SBOMs. We'll download all SBOMs from the sbomqs GitHub [repository](https://github.com/interlynk-io/sbomqs/releases/tag/v1.0.3) via GitHub release method, ensuring we fetch the latest available version.

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--in-github-method="release" \
--output-adapter=folder \
--out-folder-path="demo"
```

![Terminal output of sbommv downloading SBOMs from GitHub releases to a local folder](/posts/image-31.png)

Now that we have a collection of SBOMs in our local folder demo, the next step is to seamlessly transfer them to Dependency-Track using sbommv.

Run the following command to upload all SBOMs from the local demo folder to Dependency-Track:

```bash
sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081"
```

![Terminal output of sbommv uploading SBOMs from a local folder to Dependency-Track](/posts/image-32.png)

![Dependency-Track dashboard showing multiple projects created from uploaded SBOMs](/posts/image-33.png)

**After execution**:

- Only valid SBOM files are detected and uploaded.
- SPDX 2.2 SBOMs are automatically upgraded to SPDX 2.3 before being converted to CycloneDX, maintaining compatibility with Dependency-Track acceptability.
- Automatically creates the project name using the primary component name and version from the SBOM.

### 3. Dry-Run Mode (Optional Feature)

Before executing an SBOM transfer, sbommv provides a dry-run mode, allowing users to preview which SBOMs will be processed—without making any actual changes. This feature helps verify transfers for both GitHub-based and folder-based SBOM sources.

#### Previewing a Github-to-Dependency-Track Transfer

To check which SBOMs will be transferred from a GitHub repository to Dependency-Track, run:

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbommv" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--dry-run
```

![Terminal output of sbommv dry-run previewing a GitHub-to-Dependency-Track transfer](/posts/image-34.png)

- Displays the list of SBOMs that would be fetched from which all repo and their formats.
- Ensures project names and formats are correctly identified before execution.
- Total number of SBOMs fetched.

#### Previewing a Folder-to-Dependency-Track Transfer

To verify SBOMs stored in a local folder before transferring them to Dependency-Track, run:

```bash
sbommv transfer \
--input-adapter=folder \
--in-folder-path="demo" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--dry-run
```

![Terminal output of sbommv dry-run previewing a folder-to-Dependency-Track transfer](/posts/image-35.png)

- Lists valid SBOM files detected in the folder.
- Confirms format, project name with it will be uploaded to DTrack, Spec-Version and filename.
- Total SBOMs to be uploaded.

Dry-run mode helps prevent errors and validate transfers before execution, making it a useful feature for ensuring smooth SBOM management.

So, far we have cover two key industry scenarios:

- 1️⃣ Automated SBOM generation and transfer – Fetching SBOMs directly from GitHub and seamlessly integrating them into Dependency-Track.
- 2️⃣ Uploading pre-existing SBOMs – Transferring locally stored SBOMs from a folder to Dependency-Track while ensuring format compatibility and project organization.

These workflows demonstrate how sbommv streamlines SBOM movement, reducing manual effort and ensuring SBOMs are always available for security and compliance analysis.

## Future Work: What’s Next for sbommv?

- **Folder Monitoring** – Instead of manually triggering SBOM transfers, sbommv will continuously monitor directories and automatically upload new SBOMs as they appear. Stay tuned—this feature is launching next week 🚀 with hands-on with Interlynk platform !
- **Expanded Input & Output Support** – We're adding support for S3 buckets, additional security tools, and more SBOM formats, making sbommv even more versatile.
- **Advanced SBOM Processing** – Enhancements are on the way, including better SBOM format conversions, improved validation, and detailed logging for greater visibility into SBOM transfers.

If you find sbommv useful, show your support by giving the repository a ⭐ on [GitHub](https://github.com/interlynk-io/sbommv). Your feedback and contributions help drive its future development!

Got a feature request? Open an [issue](https://github.com/interlynk-io/sbommv/issues/new) on our GitHub repo — we’d love to hear your ideas! 🚀

## Wrapping up

Manually transferring SBOMs is no longer a viable approach, especially as software supply chain security and compliance requirements continue to evolve. Inefficient workflows not only waste time but also introduce risks that can compromise security. Automation is the only scalable solution.

With sbommv, SBOM movement is seamless—whether pulling directly from GitHub or transferring pre-existing SBOMs from local folders to Dependency-Track. By eliminating manual handling, organizations can ensure that SBOMs are always up to date, integrated into security tools, and readily available for analysis.

> The shift towards automated SBOM management isn’t just a convenience—it’s a necessity.

"Start using sbommv today and bring automation to your SBOM lifecycle

> — because security doesn’t scale manually."

## References & Resources

🔹 sbommv GitHub Repository – [GitHub](https://github.com/interlynk-io/sbommv)
🔹 Dependency-Track Documentation – [DT Docs](https://docs.dependencytrack.org/) and [Github Link](https://github.com/DependencyTrack/dependency-track)
🔹 SPDX & CycloneDX Specification – [SPDX doc](https://spdx.github.io/spdx-spec/v2.3/) | [CycloneDX doc](https://cyclonedx.org/specification/overview/)
🔹 Interlynk Official Website – [Website](https://www.interlynk.io/)
🔹 Interlynk OSS Projects – [Github](https://github.com/interlynk-io)
🔹sbommv [getting started guide](https://github.com/interlynk-io/sbommv/blob/main/docs/getting_started.md) and [examples](https://github.com/interlynk-io/sbommv/tree/main/examples)

## Appendix: Setting Up Dependency-Track

1. Run a Dependency-Track locally on your system using docker

```bash
$ docker pull dependencytrack/bundled
$ docker volume create --name dependency-track
$ docker run -d -m 8192m -p 8080:8080 --name dependency-track -v dependency-track:/data dependencytrack/bundled
```

2. Visit <http://localhost:8080>
3. Log in with the default credentials:
4. Now change your password.
5. Finally you landed into homepage of Dependency-Track platform.
6. Let's create `DTRACK_API_KEY` token, which is required to access the platform.
7. On the left hand side, go to Adminstration --> Access Management --> Teams --> click on Adminsitrator --> copy the below API keys, something like this:
8. Now, export this token in your CLI, before running sbommv.

```bash
export  DTRACK_API_KEY="odt_WYMdgLZ8sQNEVAfTwD7C5tV55ysQI1Ps"
```
