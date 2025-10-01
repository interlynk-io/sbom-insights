+++
date = '2025-09-29T10:24:57-07:00'
draft = false
title = "Interlynk's Response to CISA's 2025 SBOM Minimum Elements Request for Comments"
tags = ["SBOM", "CISA", "Compliance", "Software Supply Chain"]
categories = ["Regulations", "Public Comments"]
description = "Interlynk's formal response to CISA's request for public comments on the 2025 Minimum Elements for a Software Bill of Materials (SBOM)"
author = "Ritesh Noronha"

+++

- **Docket Number:** [CISA-2025-0007](https://www.regulations.gov/document/CISA-2025-0007-0001)
- **Comment Deadline:** [October 3, 2025](https://www.regulations.gov/document/CISA-2025-0007-0001/comment)
- **Submission Portal:** [regulations.gov](https://www.regulations.gov/document/CISA-2025-0007-0001)

---

## Executive Summary

[Interlynk](https://interlynk.io/) appreciates the opportunity to provide feedback on CISA's proposed "2025 Minimum Elements for a Software Bill of Materials (SBOM)." As developers of open-source SBOM quality and management tools, we bring a unique perspective grounded in practical implementation experience across diverse enterprise environments.

Through our work on **[sbomqs](https://github.com/interlynk-io/sbomqs)** (SBOM Quality Score) and **[sbomasm](https://github.com/interlynk-io/sbomasm)** (SBOM Assembler), we have analyzed millions of SBOMs from various industries and toolchains, giving us deep insights into the real-world challenges of SBOM creation, validation, and consumption. Our tools help organizations assess SBOM completeness, manage multi-format SBOMs, and ensure compliance with evolving standards—experience that directly informs our response to these proposed minimum elements.

We commend CISA for its iterative approach to refining SBOM requirements. However, we have identified several areas where clarification or adjustment would significantly improve adoption and implementation success. Our recommendations focus on balancing comprehensive security requirements with practical feasibility, ensuring that the minimum elements drive meaningful improvements in software supply chain transparency without creating insurmountable barriers for software producers and consumers alike.

---

## Response to CISA's Specific Questions

### Elements to Remove
**Should any elements be removed from the 2025 CISA SBOM Minimum Elements, meaning the element should not be required for all SBOMs? Which elements, and why?**

At [Interlynk](https://interlynk.io) we support the removal of SWID as an SBOM format. 

### Additional Elements to Include
**Should CISA include any additional elements in the 2025 CISA SBOM Minimum Elements, meaning the element should be a requirement for all SBOMs? Which elements, and why?**

Interlynk would recommend the following additions

- Support Level for Components as required by the FDA. (Unspecified, Actively Maintained, Unmaintained, Abandoned)
- Signatures for authenticity & verification.
- Requiring Data Licenses for publicly available SBOMS, similar to SPDX 2.3 CC0-1.0.
- Minimum versions for supported SBOM formats. CycloneDX 1.5+ and SPDX 2.3+

---

## Comments on New 2025 Elements

### Component Hash

**Pros:**
- Establishes definitive component identity through cryptographic fingerprints
- Critical foundation for verifying software authenticity and detecting tampering
- Allows correlation between SBOMs and external security intelligence (CVE databases, provenance records, vulnerability feeds)
- Supports automated security workflows and component verification pipelines

**Cons:**
- Different build configurations, compression methods, and toolchains can produce varying hash values for functionally identical components
- Current SBOM generation tools lack consensus on hashing methodology and target artifacts
- Components obtained in multiple forms (source archives vs. pre-built binaries) create uncertainty about which artifact should be hashed
- Missing guidance on standardized hashing procedures limits interoperability between SBOM producers and consumers

[Interlynk](https://interlynk.io) endorses requiring cryptographic hashes as they form the cornerstone of component traceability and supply chain integrity. To maximize practical adoption, CISA should define explicit hashing conventions that address source-versus-binary scenarios and reference established standards that specify hash computation methods, ensuring consistency across the tooling ecosystem.

### License Information

[Interlynk](https://interlynk.io) strongly advocates for making license information mandatory in SBOMs, as it addresses a critical compliance gap for organizations managing complex software dependencies. To ensure consistent implementation, spelling out guidelines for custom license would be great. Also standardize on SPDX license format would go a step further. 

### Tool Name

[Interlynk](https://interlynk.io) strongly advocates for making tool name mandatory and recommends also requiring tool version, as both specifications provide native support for this data. CISA should additionally define conventions for representing multi-tool workflows where several tools contribute to or modify a single SBOM.

### Generation Context
[Interlynk](https://interlynk.io) Strongly supports the inclusion of this field. Knowing when an SBOM was generated, benefits the consumer with little overhead on the producer. This context allows consumers to make better decisions. For C/C++ based projects this make the most sense, as the linked library on the build system, might have a different version as compared to the runtime. 

---

## Comments on Practices and Processes

### Coverage (full depth, transitive dependencies)
The addition of this requirement, is great for vulnerability management. As you are probably aware but capturing this information for languages with package-managers is doable, however C/C++ could be a non-trivial effort.

### Known Unknowns & Redactions
[Interlynk](https://interlynk.io) is in agreement with these requirements for large organizations. Small and Midsize organizations may struggle to manage these requests or justify redactions. 

### Distribution and Delivery
[Interlynk](https://interlynk.io) is in agreement with these requirements. In addition to SBOM distribution & delivery it should also call out the distribution of VEX. 

### Practical Takeaways 
Based on all the guidelines provided, teams would require the following tooling at a minimum, which might be challenging to small teams
- Automated SBOM generation using CI/CD (Frequency)
- SBOM generator for package mangager or Custom Scripts for C/C++ (Coverage)
- Known/Unknown Handling using post-processing. (Known/Unknown)
- Artifact Storage for SBOM & VEX documents, Public or Auth access to these files (Distribution & Delivery)

---

## Conclusion

[Interlynk](https://interlynk.io) commends CISA's continued leadership in advancing SBOM standards and appreciates the opportunity to contribute to this important initiative. The proposed 2025 minimum elements represent a meaningful evolution toward more comprehensive software supply chain transparency, particularly with the addition of component hashes, license information, tool identification, and generation context.

Our recommendations are grounded in practical implementation experience across thousands of real-world SBOMs. We support the removal of SWID as a format and advocate for additional requirements including data licenses for public SBOMs, component support level indicators, cryptographic signatures for verification, and minimum version requirements for SBOM formats (CycloneDX 1.5+ and SPDX 2.3+).

The success of these minimum elements depends on clear, actionable guidance that balances security objectives with implementation feasibility. We encourage CISA to provide specific conventions for component hashing, license representation, and multi-tool workflows to ensure consistent adoption across the ecosystem.

Interlynk remains committed to supporting the SBOM community through our open-source tools and stands ready to collaborate with CISA and industry stakeholders in refining and implementing these critical standards. We believe that well-crafted minimum elements will accelerate SBOM adoption while delivering meaningful improvements in software supply chain security and transparency.





