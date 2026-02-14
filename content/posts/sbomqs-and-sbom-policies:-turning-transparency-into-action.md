+++
date = '2025-09-23T17:36:55+05:30'
draft = false
title = 'sbomqs and SBOM Policies: Turning Transparency Into Action'
categories = ['Compliance', 'Quality', 'Tools']
tags = ['SBOM', 'sbomqs', 'Policy', 'Compliance', 'Supply Chain', 'Risk Management', 'Security', 'Vulnerability Management']
author = 'Vivek Sahu'
description = 'Turn SBOM transparency into action with sbomqs policies. Define rules for licenses, vulnerabilities, and suppliers to automate supply chain risk decisions.'
+++

![Blog header for sbomqs SBOM policy enforcement feature](/posts/image-25.png)

Hey SBOM enthusiasts 👋

An SBOM isn’t just a list of components anymore — it has detailed information of your software, which contains hundreds of components. And that's what gives you the transparency of each and every component: such as, who authored it, who supplies it, under what license it’s released, and even what known vulnerabilities it carries. In other words, it’s not just an inventory — it’s visibility into the very DNA of your software.

Now, if SBOMs provides this transparency, the next obvious question is: **how do we use that transparency in practice?** The answer usually ties back to some common needs:

- Meeting compliance requirements,
- Identifying and Managing existing vulnerabilities,
- Ensuring license compliance,
- Mitigate supply chain risks

In this blog, we’ll dig into one specific use case — **mitigating supply chain risks with policies**. This is exactly where SBOM policies come into play. Think of them as guardrails: the SBOM shows you all the data, but policies decide how to act on it. And when you’re dealing with hundreds or even thousands of components, manually checking each one isn’t realistic. That’s why you need clear rules that spell out what’s acceptable and what’s not.

**For example:**

- Can we ship a GPL-licensed library inside a commercial product?
- What if a component shows up without a license or supplier or author value ?
- Should we block the build if one dependency has a known vulnerability?
- Do we allow outdated libraries, or should they be banned completely?

These aren’t “nice to have” questions. They’re the real, everyday decisions organizations need to make if they want to ship software responsibly. SBOM policies transform a raw list of components into something actionable — a living framework that enforces compliance, improves security, and builds trust.

In short:

> SBOMs show you the data, but policies decide what you do with it.

That’s where the real power kicks in — when policies turn raw transparency into action.

Let’s make this concrete with a few examples:

- **Licensing guardrails**: Scan the SBOM and block the build if disallowed licenses (like GPL or AGPL) appear.
- **Missing information**: If a component doesn’t declare a license or supplier, that’s a red flag. Policies can warn you or even fail the pipeline until it’s fixed.
- **Security checks**: A policy might say, “If a component has a known critical CVE, fail the build.” That way, vulnerable software never reaches production.
- **Banned components**: Outdated or untrusted libraries? A policy makes sure they don’t sneak back in.
- **Compliance rules**: SBOMs can also be checked against standards (like NTIA or BSI) to ensure required fields are always present.

And the best part is ? Policies bring consistency. Instead of every team arguing over what’s acceptable, the organization defines the rules once — and they’re enforced automatically wherever SBOMs are checked.

That’s how policies transform your SBOM from a static list into a **decision-making engine**.

## Enforcing SBOM Rules with sbomqs

sbomqs is an open-source tool for checking the quality and compliance of SBOMs. Recently, it got smarter — it now supports policies.

Policies in sbomqs is a collection of rules. Instead of you manually scanning an SBOM to decide what’s acceptable or risky, sbomqs lets you define those rules upfront and then enforces them automatically.

You can provide policies in two ways:

1. As a YAML policy file.
2. Inline on the command line

## The Building Blocks of a Policy

Before jumping into examples, let’s break down the concepts:

- **Policy** → a collection of rules.
- **Type** → defines what condition is checked (whitelist, blacklist, or required).
- **Action** → tell policy what to do if a rule is violated (fail, warn, or pass).

So, the flow is simple:

- ✅ If the rules are satisfied → the check passes → pass .
- ❌ If the rules are not satisfied → violation→the outcome follows the action (fail, warn).

## Rule

Each rule is a list SBOM field/values. A rule have:

- **field** → the SBOM attribute to check (e.g., license, supplier, version).
- **values** → the exact values allowed or disallowed.
- **patterns** → regex patterns for flexible matching.
- (future support: operator → in, not_in, matches, not_matches).

The logic is:

- Multiple rules in a policy → combined with AND (all must pass).
- Multiple values/patterns in a rule → combined with OR (any match passes).

## Types of Policies

### 1. Whitelist

Allows only defined values in the list.

Violation if the value is outside the list.

**Example**:

```yaml
policy:
  - name: approved_licenses
    type: whitelist
    rules:
      - field: license
        values: [MIT, Apache-2.0, BSD-3-Clause]
    action: fail
```

- ✔ Components with MIT or Apache-2.0 → no violation → pass
- ✘ Components with GPL-3.0 → violation, → action → fail

### 2. Blacklist

- Disallows certain values.
- Violation if the value matches the list/pattern.

**Example**:

```yaml
policy:
  - name: banned_components
    type: blacklist
    rules:
      - field: name
        patterns: ["log4j-1.*", "commons-collections-3.2.1"]
    action: fail
```

- ✔ Component okio-1.6.0 → no violation → pass
- ✘ Component log4j-1.2.17 → violation → fail

### 3. Required

- Ensures certain fields are always present.
- Violation if a required field is missing.

```yaml
policy:
  - name: required_metadata
    type: required
    rules:
      - field: supplier
      - field: version
      - field: license
    action: fail
```

- ✔ Component with supplier, version, and license → no violation → pass.
- ✘ Component missing supplier → violation → fail.

### Action

Finally, the action decides how policy responds when a violation happens:

- **fail** → mark as failed, exit with non-zero code (block CI/CD pipeline).
- **warn** → report the violation but continue (exit code zero).
- **pass** → force pass even with violations (useful for dry-runs).

👉 With this structure, sbomqs policies let you move from just seeing risks in your SBOM to actually enforcing rules around them — whether that’s blocking GPL licenses, ensuring metadata completeness, or banning unsafe libraries.

## Hands-on Demo

### Running sbomqs with Policies

This policy below, named approved_licenses, is of type whitelist. It means only the licenses listed here (MIT, Apache-2.0) are considered acceptable. If a component has any other license, it violates the policy, and since the action is set to fail, the overall result will fail.

```yaml
policy:
  - name: approved_licenses
    type: whitelist
    rules:
      - field: license
        values: [MIT, Apache-2.0]
    action: fail
```

We will run this policy against incomplete which has license value as "NOASSERTION" or "NONE". So, obviously it should violate the policy, therefore, it should fail as per the policy action.

```bash
sbomqs policy -f samples/policy/whitelist/approved-licenses.yaml samples/policy/in-complete.spdx.sbom.json
```

![sbomqs policy output showing license whitelist check failed with 6 violations](/posts/image-26.png)

The output shows that the policy check failed. Here’s why:

- The SBOM has 6 components in total.
- The policy applied 1 rule (license whitelist).
- All 6 components violated that rule, resulting in 6 violations.
- Since the policy action is set to fail, the final outcome is marked as fail.

Now, will run the same command against complete SBOM, which contain license with either of the listed licenses:

```bash
sbomqs policy -f samples/policy/whitelist/approved-licenses.yaml samples/policy/complete-sbom.spdx.json
```

![sbomqs policy output showing license whitelist check passed with 0 violations](/posts/image-27.png)

The output shows that the policy check failed. Here’s why:

- The SBOM contains 5 components in total.
- The policy applied 1 rule (license whitelist).
- All 5 components had licenses within the approved list (MIT or Apache-2.0), so there were 0 violations.
- Since no violations were found, the final outcome is marked as pass.

For more policies you can refer here: <https://github.com/interlynk-io/sbomqs/tree/main/samples/policy>

### Applying Inline Policies (CLI)

You don’t always need a YAML file to define policies. With sbomqs, you can also write them inline, directly in the CLI. Let’s take the same approved_licenses whitelist policy from before and express it inline.

**Example** → Whitelisting licenses (MIT, Apache-2.0) directly in the CLI

```bash
sbomqs policy \
--name approved_licenses \
--type whitelist \
--rules "field=license,values=MIT,Apache-2.0" \
--action fail \
samples/policy/in-complete.spdx.sbom.json
```

![sbomqs inline CLI policy output showing license whitelist failure for 6 components](/posts/image-28.png)

The outcome shows that the SBOM had 6 components, and all 6 failed the whitelist rule (none matched MIT or Apache-2.0). Since the action was set to fail, the final result is also fail.

### Applying multi-policies using YAML

In the real world, you rarely stop at just one rule/policy. You want to check for multiple things at the same time — like whether licenses are approved, whether certain components are banned, and whether all the required metadata fields are present.

That’s exactly why sbomqs supports running multiple policies from a single YAML file. Here’s an example policy.yaml with three different checks:

```yaml
policy:
  - name: approved_licenses
    type: whitelist
    rules:
      - field: license
        values:
          - MIT
          - Apache-2.0
          - BSD-3-Clause
    action: warn # or 'fail'

  - name: banned_components
    type: blacklist
    rules:
      - field: name
        patterns:
          - "log4j*"
          - "commons-collections-3.2.1"
    action: fail

  - name: required_metadata
    type: required
    rules:
      - field: supplier
      - field: version
      - field: license
      - field: checksum
    action: fail
```

Now, let’s run it:

```bash
sbomqs policy -f samples/policy/custom/custom-policies.yaml samples/policy/in-complete.spdx.sbom.json
```

![sbomqs multi-policy output showing whitelist warn, blacklist fail, and required pass results](/posts/image-29.png)

Breaking it down:

- **approved_licenses** (whitelist) → All 6 components failed to match the approved licenses (MIT, Apache-2.0, BSD-3-Clause). Since the action is set to warn, the policy result is warn, not fail.
- **banned_components** (blacklist) → 1 of the 6 components matched a banned pattern (log4j\* or commons-collections-3.2.1). Because the action is set to fail, this caused the policy to fail.
- **required_metadata** (required) → All components had the required fields (supplier, version, license, checksum), so this policy passed with no violations. And the total rules applied to it are 4 in total. Basically the components has values such as "NOASSERTION" or "NONE", but not empty or nil.

## Wrapping It Up

At its core, an SBOM gives you transparency — a clear view of every piece that makes up your software. But transparency on its own isn’t enough. Without rules, it’s just data sitting in a file.

That’s why policies matter. They turn your SBOM into something actionable: guardrails that decide what’s acceptable, what’s risky, and what simply can’t be shipped. From blocking vulnerable components to banning unwanted licenses, policies make sure your software supply chain stays secure, compliant, and trustworthy.

So the next time you look at an SBOM, don’t just see a list of components. See it as the foundation for decisions. And with the right policies in place, those decisions become consistent, automated, and reliable — helping you ship software that others can truly trust.

Feel free to raise an [issue](https://github.com/interlynk-io/sbomqs/issues/new) if you have any other use-cases or anything else. If you love this project show your love by starring ⭐ the sbomqs [repository](https://github.com/interlynk-io/sbomqs)!

## Resources

- sbomqs repo: <https://github.com/interlynk-io/sbomqs/>
- sbomqs policies and sboms: <https://github.com/interlynk-io/sbomqs/tree/main/samples/policy>
- sbomqs policy documentation: <https://github.com/interlynk-io/sbomqs/blob/main/docs/policy.md>
