+++
date = '2025-11-05T11:23:58-08:00'
draft = false
title = 'Sbom Generator Recommendations & Workflows'

tags = ["SBOM", "Generators", "Workflow"]
categories = ["Generators", "SBOM"]
description = "This guide helps you choose the right SBOM (Software Bill of Materials) generator for your project based on your technology stack and requirements"
author = "Ritesh Noronha"

+++

This guide helps **software engineers, DevSecOps teams, and open-source maintainers** choose and implement the right SBOM (Software Bill of Materials) generator for their projects — based on technology stack, ecosystem, and workflow maturity.

## General Guidelines

When selecting and using SBOM generators, follow these best practices:

- **Choose actively maintained tools**: Select SBOM generators that are actively maintained, whether they are ecosystem-built generators or external tools.

- **Prefer Open Source Software (OSS)**: OSS SBOM generators are improving rapidly and benefit from community contributions and transparency.

- **Generate during build process**: Application-specific SBOMs should be created during the build process for maximum accuracy and freshness.

- **Source-based SBOMs are next best**: If build-time generation isn't possible, source code analysis is the next most accurate approach.

- **Follow the Single Responsibility Principle**: Create separate SBOMs for each piece of software. For example, a Java application deployed in containers requires two SBOMs (one for the application, one for the container) which can then be combined. This allows each component to be developed and addressed individually.

- **Ensure NTIA compliance**: SBOM generators should produce NTIA-compliant SBOMs to maximize value. Use tools like [sbomqs](https://github.com/interlynk-io/sbomqs) to assess the quality of your chosen generator.

## Industry Best Practices (SBOM Generation White Paper)

The [SBOM Generation White Paper](https://github.com/SBOM-Community/SBOM-Generation/blob/main/whitepaper/Draft-SBOM-Generation-White-Paper-Feb-25-2025.pdf) from the SBOM Community provides comprehensive guidance on SBOM generation. Key insights include:

### Generation Strategy

- **Automation First**: Integrate SBOM generation into CI/CD pipelines to eliminate manual errors and ensure consistency across projects and teams.

- **Multi-Stage Generation**: Generate SBOMs at multiple lifecycle points—source, build, and binary stages—to capture the complete software evolution and identify where components are introduced or modified.

- **Maturity Progression**: Start with basic binary SBOMs and progressively enhance coverage to include source-level and build-time components.

### Format Considerations

- **SPDX**: Offers broad compatibility and is excellent for license information tracking and compliance.

- **CycloneDX**: Excels at capturing component relationships and vulnerability data, making it ideal for security-focused workflows.

- Choose the format based on your organizational needs and downstream tooling requirements.

### Quality and Compliance

- **Component Accuracy**: Capture precise version information and dependencies to support effective vulnerability correlation.

- **Data Quality Validation**: Validate SBOMs using quality checkers to ensure completeness and compliance with NTIA minimum elements.

- **Component Transparency**: SBOMs enable organizations to understand their software composition, assess supply chain risks, and respond rapidly to vulnerability disclosures.

### Roles and Responsibilities

Different parties have distinct SBOM obligations:

- **Producers**: Generate accurate SBOMs during the build process
- **Consumers**: Validate and utilize SBOMs for risk assessment
- **Hosts**: Maintain and update SBOMs for deployed software

This requires clear communication and standardized formats across the software supply chain.

## Decision Matrix

| Language / Ecosystem        | Preferred Format | Recommended Tool(s)                                                                                                              | Notes                                              |
| --------------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| **Go**                      | CycloneDX        | [cyclonedx-gomod](https://github.com/CycloneDX/cyclonedx-gomod)                                                                  | Native Go module integration                       |
| **Java (Maven)**            | CycloneDX        | [cyclonedx-maven-plugin](https://github.com/CycloneDX/cyclonedx-maven-plugin)                                                    | Integrates with Maven lifecycle                    |
| **Java (Gradle)**           | CycloneDX        | [cyclonedx-gradle-plugin](https://github.com/CycloneDX/cyclonedx-gradle-plugin)                                                  | Easy Gradle task integration                       |
| **JavaScript / TypeScript** | CycloneDX        | [@cyclonedx/cyclonedx-npm](https://github.com/CycloneDX/cyclonedx-node-npm), `npm sbom` (npm ≥9)                                 | Ecosystem-native                                   |
| **Python**                  | CycloneDX        | [cyclonedx-bom](https://github.com/CycloneDX/cyclonedx-python)                                                                   | Supports pip, poetry                               |
| **C# / .NET**               | SPDX             | [Microsoft sbom-tool](https://github.com/microsoft/sbom-tool), [CycloneDX.NET](https://github.com/CycloneDX/cyclonedx-dotnet)    | Great for NuGet                                    |
| **C/C++**                   | SPDX             | [CMake 3.28+](https://cmake.org/), [conan-sbom](https://github.com/conan-io/conan-extensions/tree/main/extensions/commands/sbom) | Built-in or package manager support                |
| **Containers**              | SPDX / CycloneDX | [Syft](https://github.com/anchore/syft), [Trivy](https://github.com/aquasecurity/trivy)                                          | Excellent for images                               |
| **Embedded (Yocto)**        | SPDX             | Built-in (`INHERIT += "create-spdx"`)                                                                                            | Native SPDX generation                             |
| **Embedded (Buildroot)**    | CycloneDX        | [generate-cyclonedx](https://fossies.org/linux/buildroot/utils/generate-cyclonedx)                                               | Built-in script                                    |
| **Cross-language**          | SPDX             | [sbom-tool](https://github.com/microsoft/sbom-tool)                                                                              | Multipurpose tools for large number of ecosystems. |

## General-Purpose SBOM Generators

| Tool                                                              | Formats         | Highlights                              | Best For                 |
| ----------------------------------------------------------------- | --------------- | --------------------------------------- | ------------------------ |
| **[Syft](https://github.com/anchore/syft)**                       | CycloneDX, SPDX | Fast, wide language & container support | Containers, file systems |
| **[Trivy](https://github.com/aquasecurity/trivy)**                | CycloneDX, SPDX | Vulnerability scanning included         | Containers, file systems |
| **[Microsoft SBOM Tool](https://github.com/microsoft/sbom-tool)** | SPDX, CycloneDX | NTIA-compliant, multi-language          | Applications             |
| **[sbomqs](https://github.com/interlynk-io/sbomqs)**              | —               | Quality and compliance validation       | Assessing SBOM quality   |

## Quality Assessment

After generating SBOMs, assess their quality using:

### [sbomqs](https://github.com/interlynk-io/sbomqs)

- Evaluates SBOM quality and NTIA compliance
- Provides scoring and recommendations
- Helps ensure your SBOMs meet industry standards

```bash
sbomqs score your-sbom.json
```

## CI/CD Integration Workflows

Integrating SBOM generation into your CI/CD pipeline ensures that SBOMs are created automatically with every build, eliminating manual steps and improving consistency.

### When to Generate SBOMs

- **Every build**: Generate SBOMs for all builds to maintain a complete history
- **Release builds**: At minimum, generate SBOMs for production releases
- **Pull requests**: Consider generating and validating SBOMs in PR checks
- **Scheduled builds**: For projects with dependencies that change frequently

### Where to Store SBOMs

- **Release artifacts**: Attach SBOMs to GitHub/GitLab releases
- **Container registries**: Store SBOMs alongside container images using OCI artifacts
- **Artifact repositories**: Upload to artifact storage (S3, Artifactory, Nexus)
- **SBOM repositories**: Dedicated SBOM management platforms ([Interlynk](https://app.interlynk.io), Dependency-Track, Guac)
- **Version control**: Commit SBOMs to a dedicated branch or repository

### Example: Go Application with GitHub Actions

Here's a complete workflow for generating, validating, and publishing SBOMs for a Go application:

```yaml
name: Build and Generate SBOM

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

jobs:
  build-and-sbom:
    runs-on: ubuntu-latest
    permissions:
      contents: write # For uploading release artifacts
      packages: write # For container registry

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: "1.22"

      - name: Build application
        run: |
          go build -o myapp ./cmd/myapp

      # Generate CycloneDX SBOM
      - name: Generate CycloneDX SBOM
        run: |
          go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@latest
          cyclonedx-gomod app -json -output sbom-cyclonedx.json

      # Generate SPDX SBOM
      - name: Generate SPDX SBOM
        run: |
          curl -Lo sbom-tool https://github.com/microsoft/sbom-tool/releases/latest/download/sbom-tool-linux-x64
          chmod +x sbom-tool
          ./sbom-tool generate -b . -bc . -pn myapp -pv 1.0.0 -ps MyOrg -nsb https://myorg.com
          # SBOM will be in _manifest/spdx_2.2/manifest.spdx.json
          cp _manifest/spdx_2.2/manifest.spdx.json sbom-spdx.json

      # Validate SBOM quality
      - name: Install sbomqs
        run: |
          curl -Lo sbomqs https://github.com/interlynk-io/sbomqs/releases/latest/download/sbomqs-linux-amd64
          chmod +x sbomqs

      - name: Validate SBOM Quality
        run: |
          ./sbomqs score sbom-cyclonedx.json
          ./sbomqs score sbom-spdx.json

      # Upload SBOMs as build artifacts
      - name: Upload SBOM artifacts
        uses: actions/upload-artifact@v4
        with:
          name: sboms
          path: |
            sbom-cyclonedx.json
            sbom-spdx.json

      # For releases: attach SBOMs to GitHub release
      - name: Attach SBOMs to Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v1
        with:
          files: |
            sbom-cyclonedx.json
            sbom-spdx.json
            myapp
```

### CI/CD Best Practices

1. **Fail fast on quality**: Set minimum quality thresholds with sbomqs
2. **Cache tools**: Cache SBOM generator binaries to speed up builds
3. **Version SBOMs**: Include version/commit information in SBOM metadata
4. **Automate distribution**: Automatically publish SBOMs to consumers
5. **Sign SBOMs**: Consider signing SBOMs to verify integrity
6. **Multi-format generation**: Generate both CycloneDX and SPDX if consumers need different formats
7. **Separate jobs**: Consider separating SBOM generation into dedicated jobs for clarity
8. **Notifications**: Alert teams when SBOM generation fails or quality drops

## Best Practices Summary

1. **Multi-stage builds**: Generate separate SBOMs for each build stage
2. **Automation**: Integrate SBOM generation into CI/CD pipelines
3. **Version control**: Store SBOMs alongside releases
4. **Regular updates**: Regenerate SBOMs with each build
5. **Validation**: Always validate SBOM quality with sbomqs
6. **Format selection**: Choose CycloneDX or SPDX based on your ecosystem and tooling support

## Additional Resources

- [SBOM Generation White Paper](https://github.com/SBOM-Community/SBOM-Generation/blob/main/whitepaper/Draft-SBOM-Generation-White-Paper-Feb-25-2025.pdf) - Comprehensive guidance on SBOM generation best practices from the SBOM Community

- [NTIA Minimum Elements](https://www.ntia.gov/files/ntia/publications/sbom_minimum_elements_report.pdf)

- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)

- [SPDX Specification](https://spdx.github.io/spdx-spec/)

- [Interlynk](https://app.interlynk.io/)
