+++
date = '2025-09-23T15:30:57+05:30'
draft = false
title = 'Modular SBOM Automation: Now With Aws S3 Support'
categories = ['Automation', 'Tools', 'Cloud']
tags = ['SBOM', 'AWS', 'S3', 'Cloud Storage', 'sbommv', 'Automation', 'Dependency-Track']
+++

![alt text](/posts/image-9.png)

In our previous posts, we streamlined SBOM workflows by moving them from GitHub releases or local folders directly into platforms like Dependency-Track and then, we took it one step further with folder continuous monitoring—continuous fetching and uploading via sbommv’s daemon mode, which runs in the background and keeps an eye on target folders for any incoming or modified SBOMs.

As we know, sbommv is a modular system that seamlessly integrates multiple input systems like folders, GitHub, and multiple output systems like Dependency-Track, Interlynk, and folders—allowing SBOMs to move effortlessly from one system to another. Building on that foundation, it's time for another leap forward: **Integrating AWS S3 with sbommv**.

If your SBOMs live on S3, or you want to store them there for compliance, backups, audits, or sharing across environments, sbommv now has you covered. Whether your SBOM source or destination is S3, sbommv makes it seamless.

Let's dive into how you can:

- Fetch SBOMs directly from S3 buckets
- Upload SBOMs into S3 buckets or SBOM Platforms like Dependency Track, etc
- Fetch SBOMs directly from local storage or github and push to S3 for storage.
- Set up dry-run previews
- Prepare for S3 monitoring (future work)

## Why S3? 🌐

S3 is everywhere—widely used by dev teams, security engineers, and compliance officers. SBOMs generated during CI/CD workflows are often stored in S3 buckets, but until now, moving them in and out of S3 has been tedious and manual. Integrating S3 into sbommv builds on its modular and extensible architecture, adding S3 as both an input and output system—just like we did earlier with folders. This unlocks seamless SBOM movement from S3 to destination platforms or from other systems into S3, with full automation.

Automating SBOM movement between S3 and your security tools reduces manual work, speeds up security reviews, and ensures you’re always audit-ready.

**Use-Cases:**

- Export SBOMs from CI pipelines to an S3 bucket, then automatically transfer them to Dependency-Track.
- Transfer all your SBOMs from folder, github, etc to S3 bucket.
- Or fetch all SBOMs from S3 bucket and transfer to destination system like SBOM platforms such as Dependency-Track, Interlynk, etc.

We have done with theory part, now let's proceed with hands-on part:

### 1️⃣ Uploading SBOMs to S3 (Output Adapter)

Let's say you already have SBOMs either in a folder, GitHub, or any other input system. Now, you want to push them to an S3 bucket.

![alt text](/posts/image-10.png)

Make sure your AWS credentials are already configured locally and present at `~/aws/credential` path.

```bash
sbommv transfer \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--in-github-method=release \
--output-adapter=s3 \
--out-s3-bucket-name="demo-sbom-bucket" \
--out-s3-prefix="releases"
```

Or, if you want to provide the AWS_ACCESS_KEY and AWS_SECRET_ KEY on the go, then follow below command:

```bash
export AWS_ACCESS_KEY="dkke,kekffkee"
export AWS_SECRET_KEY="efewk.dkdclklvkrle"
```

```bash
sbommv transfer  \
--input-adapter=github \
--in-github-url="https://github.com/interlynk-io/sbomqs" \
--in-github-method=release \
--output-adapter=s3 \
--out-s3-bucket-name="demo-sbom-bucket" \
--out-s3-prefix="release" \--out-s3-region="us-east-1" \
--out-s3-access-key=$AWS_ACCESS_KEY \
--out-s3-secret-key=$AWS_SECRET_KEY
```

It will fetch all SBOMs from github release page of sbomqs repository for latest releases, and move them to demo-sbom-bucket S3 bucket under the prefix release. To check run the command:

```bash
$ aws s3 ls s3://demo-sbom-bucket/releases/ 

2025-04-26 22:09:11      65430 sbomqs-darwin-amd64.spdx.sbom
2025-04-26 22:09:12      65430 sbomqs-darwin-arm64.spdx.sbom
2025-04-26 22:09:10      65300 sbomqs-linux-amd64.spdx.sbom
2025-04-26 22:09:11      65300 sbomqs-linux-arm64.spdx.sbom
2025-04-26 22:09:13      67651 sbomqs-windows-amd64.exe.spdx.sbom
2025-04-26 22:09:09      67651 sbomqs-windows-arm64.exe.spdx.sbom
```

Now, you have SBOMs on S3 bucket, let's fetch from here and upload to SBOM platforms, like dependency track.

### 2️⃣ Fetching SBOMs from S3 (Input Adapter)

Let's fetch SBOMs stored in S3 and upload them into Dependency-Track or any other system?

![alt text](/posts/image-11.png)

Let's see what it fetched and what it would upload to Dependency Track:

```bash
sbommv  transfer  \ 
--input-adapter=s3 \
--in-s3-bucket-name="vivek-test-sbom" \
--in-s3-prefix="releases" \
--in-s3-region="us-east-1" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081" \
--dry-run

-----------------🌐 INPUT ADAPTER DRY-RUN OUTPUT 🌐-----------------

📦 Details of all Fetched SBOMs by S3 Input Adapter
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-darwin-amd64.spdx.sbom
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-darwin-arm64.spdx.sbom
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-linux-amd64.spdx.sbom
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-linux-arm64.spdx.sbom
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-windows-amd64.exe.spdx.sbom
 - 📁 Bucket: vivek-test-sbom | Prefix: releases | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-windows-arm64.exe.spdx.sbom

📦 Total SBOMs fetched: 6

-----------------🌐 OUTPUT ADAPTER DRY-RUN OUTPUT 🌐-----------------

📦 Dependency-Track Output Adapter Dry-Run
📦 DTrack API Endpoint: http://localhost:8081
- 📁 Would upload to project 'sbomqs-darwin-amd64-sha256:ca20055b1d9e111a2ae4e3ddc6390cc936ddc9d5b9d36b5aa7a401c8b935d386' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-darwin-amd64.spdx.sbom
- 📁 Would upload to project 'sbomqs-darwin-arm64-sha256:f20d3c22cc85c461bbd9932dc15002bc866657067925754c56b546c40661638a' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-darwin-arm64.spdx.sbom
- 📁 Would upload to project 'sbomqs-linux-amd64-sha256:eb0c8fd900d49e0522d23536d8df02d500b76b1a01a904585501c62f8e367957' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-linux-amd64.spdx.sbom
- 📁 Would upload to project 'sbomqs-linux-arm64-sha256:a0bb511212005a7b6d100e4f5ac683f355ad55e39eaffd5ea878b5be4f5a82fc' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-linux-arm64.spdx.sbom
- 📁 Would upload to project 'sbomqs-windows-amd64.exe-sha256:ce2be934bde9fe8525a9b71dd9d866c5cec593de97f76bf08ab0489aa0d1eb3a' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-windows-amd64.exe.spdx.sbom
- 📁 Would upload to project 'sbomqs-windows-arm64.exe-sha256:d6543ab68cc069402b44d9601dda6ebd8eedba0179fe3a0b0ed9136415237167' | Format: CycloneDX-JSON | SpecVersion: 1.5 | Filename: sbomqs-windows-arm64.exe.spdx.sbom

 📊 Total SBOMs to upload: 6

✅ Dry-run completed. No data was uploaded to DTrack.

```

![alt text](/posts/image-12.png)

To setup Dependency-Track locally follow this [guide](https://github.com/interlynk-io/sbommv/blob/main/examples/setup_dependency_track.md).

Now, let's execute the actual command to transfer SBOM from S3 to Dependency-Track:

```bash
sbommv  transfer  \ 
--input-adapter=s3 \
--in-s3-bucket-name="vivek-test-sbom" \
--in-s3-prefix="releases" \
--in-s3-region="us-east-1" \
--output-adapter=dtrack \
--out-dtrack-url="http://localhost:8081"
```

![alt text](/posts/image-13.png)

**What's happening:**

- Fetch SBOMs from "demo-sbom-bucket/releases/".
- Auto-validate them.
- Convert them from SPDX --> CycloneDX.
- Upload to Dependency-Track with the right project names, i.e their primary component name with their version.
- Add Tags(S3 and sbommv)uploads with helpful metadata.

If you are storing your SBOMs at some different locations and want that sbommv to support that too, then raise an issue for the same, we will help you out integrating that.

**What's Next:**

- Run sbommv in daemon mode to watch github released SBOMs

## References & Resources

- sbommv GitHub [Repository](https://github.com/interlynk-io/sbommv)
- AWS S3 [Documentation](https://docs.aws.amazon.com/s3/index.html)
- Dependency-Track [Documentation](https://docs.dependencytrack.org/)
- SPDX [Specification](https://spdx.dev/)
- CycloneDX [Specification](https://cyclonedx.org/)
