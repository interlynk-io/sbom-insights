+++
date = '2025-09-23T17:01:06+05:30'
draft = false
title = "Lean, Clean, and Compliance Ready: sbomasm's removal capabilities"
categories = ['Tools', 'Compliance']
tags = ['SBOM', 'sbomasm', 'Data Privacy', 'Compliance', 'SBOM Editing', 'Best Practices']
author = 'Vivek Sahu'
description = 'Remove unwanted fields, components, and sensitive data from SBOMs using sbomasm. Keep your SBOM lean, private, and compliance-ready in SPDX or CycloneDX.'
+++

![Blog header for sbomasm SBOM field and component removal capabilities](/posts/image-23.png)

Hey SBOM enthusiasts 👋,

we all know by now — SBOMs aren’t optional anymore. They’ve become a standard part of the software supply chain, and there’s a lot you can do with them: augmenting, enriching, editing, validating… the list keeps growing.

But here’s the thing — while adding and improving data in SBOMs gets most of the attention, sometimes the real power comes from removing what you don’t need. Maybe it’s for privacy, maybe for cleanup, maybe to keep your SBOM lean before sharing it.

When working with SBOMs, “removal” could mean:

- Removal of single field from the document metadata
- Removal of single field from specific component
- Removal of same field from all components
- Or even removal of entire component (plus its dependencies)

That’s where sbomasm’s new removal features come in.

**Example**: maybe you want to remove every field with value "NOASSERTION". Or hide a license before sending the SBOM to a partner. Or drop a hash that could expose internal build details.

Until now, sbomasm allows to edit SBOM common fields. In addition to that, it will now supports removing them — in both SPDX and CycloneDX formats — without making you wrestle with each format’s schema.

## Why we choosen Common Field over Schema Field ?

We initially considered two approaches for field removal:

- **Schema Based Removal** – where users need to specify exact schema paths (e.g., CreationInfo->Creator->Person for SPDX) for each field, which differ b/w SPDX and CycloneDX.
- **Common Fields-Based Removal** – you just the field name (like license, author, purl), which are too common among SBOM, and sbomasm handles the schema differences

## The sbomasm remove(rm) command

The new remove command supports two types of removal:

1. **Field Removal** – Take out specific fields, either from the SBOM’s document metadata or from individual components metadata. Example: remove license from a single component, or strip author from the document, or remove license having value "Apache-2.0" field from all components.
2. **Component Removal** – Remove one or more components entirely, along with their linked dependencies and files.

Both work for SPDX and CycloneDX — and both keep your SBOM valid.

Let's discuss them one by one.

## Field Removal in sbomasm

Under this, following scenarios are possible. For say, one can remove:

- **From the document itself**: fields like author, supplier, timestamp
- **From a specific component**: fields like license, hash, purl, description, repo, supplier, cpe
- **From all components**: same as above, but applied across the SBOM.

### 1.1 Remove field from document using key(field)

**Examples**:

- Remove field "author" from document section

```bash
sbomasm rm --field author --scope document sbom.json -o new-sbom.json
```

### 1.2 Remove field from document using key and value

**Example**:

- Remove field "author" having value "Interlynk" from document section

```bash
sbomasm rm --field author --value "Interlynk" --scope document   sbom.json -o new-sbom.json
```

### 2.1 Remove field from specific component using key

**Example**:

- Remove field "license" from a specific component having name "nginx" and version "v1.21.0"

```bash
sbomasm rm --field license --scope component --name "nginx" --version "v1.21.0" sbom.json -o new-sbom.json
```

### 2.2 Remove field from specific component using key and value

**Example**:

- Remove "purl" field with value "pkg:golang/github.com/fluxcd/pkg/oci@v0.45.0" from a specific component having name "github.com/fluxcd/pkg/oci" and version "v0.45.0".

```bash
sbomasm rm --field purl --value "pkg:golang/github.com/fluxcd/pkg/oci@v0.45.0" --scope component
--name "github.com/fluxcd/pkg/oci" --version "v0.45.0" sbom.json -o new-sbom.json
```

### 3.1 Remove field from all component using key

**Example**:

- Remove "supplier" field from all components

```bash
sbomasm rm --field supplier  --scope component -a sbom.json -o new-sbom.json
where, all components is signifies via "-a".
```

### 3.2 Remove field from all component using key and value

**Example**:

- Remove "license" field from all components if it's value is "Apache-2.0"

```bash
sbomasm rm --field license --value "Apache-2.0" --scope component -a  sbom.json -o new-sbom.json
```

**NOTE**:

- Support fields for document are: author, supplier, tool, lifecycle, license, description, repository, timestamp
- Similarly, supported fields for component are: copyright, cpe, description, hash, license, purl, repo, supplier, type

## Component Removal in sbomasm

Sometimes, a component just shouldn’t be in the SBOM at all — maybe it’s internal, maybe it’s irrelevant to the version you’re sharing. Component removal lets you delete:

- Remove a single component by name, version, or PURL
- Remove multiple components by matching a field and value
- Remove all related dependencies and files automatically

### 1. Remove specific component

**Example**:

- Remove a entire component with a name "nginx" and version "v2.0.5". And by default it will also remove all it's dependencies and files.

```bash
sbomasm rm --components --name nginx --version "v2.0.5"
```

**NOTE**:

The key difference in flags between "field removal" and "component removal" is the singular vs. plural form: --component vs --components

- In field removal, the default action targets a single component, so the flag is "--component". To apply changes to all components, you add the "-a" flag.
- In component removal, the default action targets all components, so the flag is "--components". Here to deal with particular component, provide name and version

### 2. Remove all Components using Field

**Example**:

- Remove all components if it has field "author"

```bash
sbomasm rm --components --field author  sbom.json -o new-sbom.json
```

- Remove all components if it has field "license"

```bash
sbomasm rm --components --field license  sbom.json -o new-sbom.json
```

### 3. Remove all Components using Field And Value

**Example**:

Remove all components(and it's related dependencies) having a field "PURL" and it's value "pkg:golang/org/xyz/abc@v1.0.0".

```bash
sbomasm rm --components --field purl --value "pkg:golang/org/xyz/abc@v1.0.0" sbom.json -o new-sbom.json
```

This finds all components with that PURL and removes them with their dependencies.

- Remove all components and it's related dependencies having a field "license" and value "Apache-2.0".

```bash
sbomasm rm --components --field license --value "Apache-2.0"  sbom.json -o new-sbom.json
```

- Remove all components(and it's related dependencies) having a "type" and value "library".

```bash
sbomasm rm --components --field type --value "library"  sbom.json -o new-sbom.json
```

So, these were sorts of examples on both "field removal" as well as "component removal". For more example refer [doc](https://github.com/interlynk-io/sbomasm/blob/main/docs/removal.md). If yours use-case is similar or even different or any issues or features related to it, simply file up an [issue](https://github.com/interlynk-io/sbomasm/issues/new) here. We would love to help.

## Conclusion

Whether it’s trimming sensitive details, cleaning up unused metadata, or removing entire components that don’t belong, sbomasm now gives you precise control over what stays in your SBOM — and what doesn’t.

The reality is, SBOMs aren't just static files you generate once and forget about. They're living artifacts that evolve with your software, and sometimes evolution means subtraction. And when evolution means addition, sbomasm can also [enrich your SBOMs with license data from ClearlyDefined](/posts/sbomasm-enriches-licenses-using-clearlydefined-datasets/).

By supporting both SPDX and CycloneDX with a common field approach, sbomasm removes the guesswork (and schema headaches) so you can focus on what matters: delivering accurate, shareable, and compliance-ready SBOMs without manual cleanup marathons.

Try out sbomasm here: <https://github.com/interlynk-io/sbomasm>

If you loved this project, show the love back by starring ⭐ this [repo](https://github.com/interlynk-io/sbomasm).
