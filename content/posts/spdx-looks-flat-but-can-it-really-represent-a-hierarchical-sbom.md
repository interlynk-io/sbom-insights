+++
date = '2026-08-25T10:00:00+05:30'
draft = false
title = 'SPDX looks Flat. But can it really represent a Hierarchical SBOM?'
categories = ['Tools', 'Best Practices', 'Standards']
tags = ['SBOM', 'sbomasm', 'SPDX', 'CycloneDX', 'Merge Strategies', 'Hierarchical Merge','SBOM Standards']
author = 'Vivek Sahu'
description = 'Exploring how SPDX relationship types `CONTAINS` and `DEPENDS_ON` can represent hierarchical SBOM semantics, and what this means for multi-format merge strategies.'
slug = 'spdx-looks-flat-but-can-it-really-represent-a-hierarchical-sbom'
+++

Hey SBOM enthusiasts 👋,

If you've been working with SBOMs for a while, you already know that merging multiple SBOMs isn't just about dumping all the components into one file.

The real challenge is preserving the **semantics meaning of each merge strategy**.

Are they dependencies?
Are they sub-components of another component?
Are they independent products being assembled together?
Or are we simply trying to flatten everything into one unified component list?

This is exactly why [sbomasm](https://github.com/interlynk-io/sbomasm) supports multiple merge strategies. We previously discussed how [Hierarchical, Flat, Assembly, and Augment Merge work](/posts/understanding-sbomasm-merge-strategies/) and when each strategy makes sense.

But when we look at different SBOM formats, an interesting question comes up:

> Can we represent the same merge semantics in SPDX that we can represent in CycloneDX?

At first glance, SPDX makes this look difficult. And that's where things get interesting.

## The Problem: CycloneDX has nesting, SPDX looks flat

Let's start with a simple example. Suppose we have two SBOMs.

One represents a frontend application:

```text
SBOM A
└── Frontend
    ├── React
    ├── Axios
    └── Nginx
```

And another represents a backend application:

```text
SBOM B
└── Backend
    ├── Express
    ├── Mongoose
    └── JWT
```

In CycloneDX, this hierarchy can be represented directly using nested `components[]`.

```text
My Application
├── Frontend
│   ├── React
│   ├── Axios
│   └── Nginx
└── Backend
    ├── Express
    ├── Mongoose
    └── JWT
```

The structure itself tells us something important:

- **React belongs under Frontend.**
- **Express belongs under Backend.**

This is useful when performing a Hierarchical Merge because each input SBOM can remain a self-contained sub-tree under a new root.

**But SPDX looks different.**

Unlike CycloneDX, SPDX does not have a nested `components[]` structure telling us that React belongs under Frontend. Instead, SPDX represents the elements and their connections through **relationships**.

So, structurally, the SPDX representation looks more like this:

```text
Frontend
React
Axios
Nginx

Backend
Express
Mongoose
JWT
```

The question is:
> If SPDX is structurally flat, how do we represent the hierarchy?

## First Question: Can `CONTAINS` represent nesting?

The first question was about hierarchy itself. If SPDX doesn't support nesting structure, can we use:

```text
CONTAINS
```

relationshipType to express that one element is a sub-component of another element? We asked this question in SPDX Implementors meetings.

> The answer from the SPDX Implementors Meeting discussion was **yes**.

The SPDX relationship model provides **CONTAINS** specifically for expressing containment relationships. In other words, while the SPDX document remains structurally flat, the relationship graph can express that one element contains another.

We can use it to express that one element contains another:

```text
Frontend ──CONTAINS──> React
Frontend ──CONTAINS──> Axios
Frontend ──CONTAINS──> Nginx
```

Similarly:

```text
Backend ──CONTAINS──> Express
Backend ──CONTAINS──> Mongoose
Backend ──CONTAINS──> JWT
```

Now we have a way to represent the hierarchy.

The SPDX document may still be structurally flat, but the relationships tell us how the elements are connected.

So instead of the structure itself telling us:

```text
Frontend
└── React
```

the relationship tells us:

```text
Frontend ──CONTAINS──> React
```

This gives us the first answer:
> **Yes, SPDX can represent nesting semantics using the `CONTAINS` relationship.**

But there is another question. And this one is more interesting.

## The more interesting Question: Can multiple relationships co-exist for same element?

Now consider a real software dependency graph. A component can have more than one semantic relationship with another component.

**For example**, Suppose React is contained inside Frontend. At the same time, React is also a dependency of Frontend. We therefore have two different pieces of information:

```text
Frontend ──CONTAINS──> React
Frontend ──DEPENDS_ON──> React
```

Is that valid?

The important thing here is that these two relationships describe **different semantics**.

`CONTAINS` answers:
> **Where does this component belong?**

While `DEPENDS_ON` answers:
> **What does this component depend on?**

**NOTE**:
This question we raised with the SPDX Implementors community was whether SPDX allows these two relationship types to co-exist between the same source and target.

> The conclusion from the Implementors discussion was **yes**.

So the same pair of elements can have different relationships describing different connections.

**For example**:

```text
Frontend
   │
   ├── CONTAINS ──────> React
   │
   └── DEPENDS_ON ────> React
```

The first relationship tells us about the component's place in the hierarchy. The second tells us about the dependency relationship. This distinction is important because **hierarchy and dependency are not necessarily the same thing**.

A component can belong to an application **and** be a dependency of that application.

Once we understand this, the pieces start to come together.

## Connecting the dots

So far, we have established two things:

1. `CONTAINS` can represent the relationship between a parent element and a contained element.
2. `CONTAINS` and `DEPENDS_ON` can represent different semantics between the same elements.

But how do these two capabilities help us reproduce the behavior of **Hierarchical Merge**?

Let's go back to our example.

We want to merge:

```text
Frontend
├── React
└── Axios

Backend
├── Express
└── Mongoose
```


into:

```text
Application
├── Frontend
│   ├── React
│   └── Axios
│
└── Backend
    ├── Express
    └── Mongoose
```

In CycloneDX, the hierarchy is represented directly through nested components.

In SPDX, we can represent the same semantics through relationships:


```text
Application
   │
   ├── DEPENDS_ON ──> Frontend
   │                     │
   │                     ├── CONTAINS ──> React
   │                     └── CONTAINS ──> Axios
   │
   └── DEPENDS_ON ──> Backend
                         │
                         ├── CONTAINS ──> Express
                         └── CONTAINS ──> JSON Web Token
```

Now we can distinguish two different questions.


**Where does a component belong?**

```text
CONTAINS
```

**What does a component depend on?**

```text
DEPENDS_ON
```

This is the key to representing Hierarchical Merge in SPDX.

## So what does this mean for Hierarchical Merge?

The goal of Hierarchical Merge is not simply to put all components into a new SBOM. The goal is to preserve the structure and dependency semantics of each input SBOM while bringing them under a new root. With CycloneDX, this can be represented using nested components:

```text
New Root
├── Frontend
│   ├── React
│   └── Axios
│
└── Backend
    ├── Express
    └── Mongoose
```

With SPDX, we can express the same semantics using relationships:

```text
New Root
   │
   ├── DEPENDS_ON ──> Frontend
   │                     │
   │                     ├── CONTAINS ──> React
   │                     └── CONTAINS ──> Axios
   │
   └── DEPENDS_ON ──> Backend
                         │
                         ├── CONTAINS ──> Express
                         └── CONTAINS ──> JSON Web Token
```

The representation is different, but the **semantics should remain the same**. That's an important distinction when working with multiple SBOM formats. We don't necessarily need every format to represent the data in exactly the same structural way. What matters is whether the format can preserve the meaning we need.

## What about the other merge strategies?

Hierarchical Merge is where this relationship model becomes particularly interesting. But the same reasoning also helps us understand how the other merge strategies map to SPDX.

### Assembly Merge

In Assembly Merge, the primary components from the input SBOMs become components of a new root.

For example:

```text
Application
├── Frontend
│   ├── React
│   └── Axios
│
└── Backend
    ├── Express
    └── Mongoose
```

In SPDX, this can be represented using `CONTAINS` relationships:

```text
Application
   │
   ├── CONTAINS ──> Frontend
   │
   └── CONTAINS ──> Backend
```

The existing relationships inside Frontend and Backend can remain intact.

So the root describes the assembly, while the existing relationships describe the contents and dependencies of each input SBOM.

### Flat Merge

Flat Merge is different. The goal here is to bring the components into a single flat representation while preserving the dependency relationships.

Conceptually:

```text
Application
├── React
├── Axios
├── Express
└── Mongoose
```

The hierarchy from the individual SBOMs is no longer the primary concern. Instead, the important information is the dependency graph:

```text
Frontend ──DEPENDS_ON──> React
Frontend ──DEPENDS_ON──> Axios

Backend ──DEPENDS_ON──> Express
Backend ──DEPENDS_ON──> Mongoose
```

SPDX's relationship model fits naturally here because the dependency semantics can be represented using `DEPENDS_ON` relationships between elements.

## What this means for `sbomasm` ?

This also gives us a useful way to think about merge strategies across formats.

| Merge Strategy   | CycloneDX                               | SPDX                                                 |
| ---------------- | --------------------------------------- | ---------------------------------------------------- |
| **Hierarchical** | Nested components + dependencies        | `CONTAINS` + `DEPENDS_ON` relationships              |
| **Assembly**     | Primary components nested under root    | Root `CONTAINS` primary components                   |
| **Flat**         | Flattened components + dependency graph | Flat elements + preserved `DEPENDS_ON` relationships |
| **Augment**      | Enrich existing SBOM                    | Enrich existing SBOM                                 |

The important part is not that the underlying representation is identical. It isn't. CycloneDX and SPDX model relationships differently.

The important part is that `sbomasm` can preserve the **intent of the merge strategy** across formats. That's what multi-format SBOM tooling should aim for.


## The Bigger Lesson: Flat structure doesn't mean Flat semantics

This is probably the most interesting takeaway from this whole exploration. When we first look at SPDX, it is easy to think:

> "SPDX is flat."

And from there, it is tempting to conclude:

> "SPDX cannot represent hierarchy."

But those two statements are not the same. A format can be structurally flat while still representing rich relationships between its elements. Think about it this way:

```text
CycloneDX
    │
    ├── Structure
    │      └── Nested components
    │
    └── Relationships
           └── Dependencies
```

Whereas SPDX can be thought of more like:

```text
SPDX
    │
    ├── Elements
    │
    └── Relationships
           ├── CONTAINS
           ├── DEPENDS_ON
           └── Other relationship types
```

CycloneDX gives us hierarchy directly through its structure. SPDX can express the same **semantics** through relationships. That is a subtle but important difference. It also shows why looking only at the document structure can sometimes be misleading. To understand what an SBOM actually means, we often need to look at both:

**What elements exist?**

and

**How are those elements related?**

## SPDX doesn't have native component nesting

There is one important distinction we should keep clear. We should **not** say:

> "SPDX supports native component nesting."

It doesn't have structural nesting in the same way CycloneDX does. Instead, the more accurate statement is:

> **SPDX does not have structural nesting like CycloneDX, but its relationship model can represent nesting semantics through `CONTAINS`.**

This distinction matters because the two formats are still structurally different. For example, CycloneDX can represent:

```text
Application
└── Frontend
    └── React
```

directly through nested component structures.

SPDX represents the same relationship through:

```text
Application ──CONTAINS──> Frontend
Frontend ──CONTAINS──> React
```

The data model is different. The semantics can still be preserved.

## Wrapping Up

What started as a question about how to represent merge strategies across SPDX and CycloneDX turned into a much more interesting exploration of how SBOM formats represent relationships.

The key takeaway is simple:

**SPDX may be structurally flat, but that doesn't make its semantics flat.**

With `CONTAINS`, we can represent the relationship between an element and the elements it contains.

With `DEPENDS_ON`, we can represent dependency semantics.

And because these relationships describe different aspects of the model, they can work together to preserve both hierarchy and dependencies. This is especially useful for Hierarchical Merge. CycloneDX can represent the hierarchy directly through nested components. SPDX can represent the same hierarchy through `CONTAINS` relationships while continuing to represent dependency information through `DEPENDS_ON`.

So when working with multiple SBOM formats, the goal shouldn't be:

> **"Can every format represent the data in exactly the same way?"**

A better question is:

> **"Can every format preserve the same meaning?"**

That is the real challenge in multi-format SBOM tooling. And sometimes, what looks like a limitation at first turns out to be simply a different way of expressing the same idea.

## Resources

- [sbomasm GitHub repository](https://github.com/interlynk-io/sbomasm)
- [sbomasm issue #344 — SPDX merge strategy inconsistencies](https://github.com/interlynk-io/sbomasm/issues/344)
- [Understanding SBOM Merge Strategies](/posts/understanding-sbomasm-merge-strategies/)
- [SPDX Specifications](https://spdx.dev/)
- [SPDX 2.2 Specification — Relationships](https://spdx.github.io/spdx-spec/v2.2.2/relationships-between-SPDX-elements/)
- [SPDX 3.0.1 Core Specification](https://spdx.github.io/spdx-spec/v3.0.1/)

If you loved this project, show the love back by starring ⭐ the [repo](https://github.com/interlynk-io/sbomasm).

Have questions or need help with a specific use case? File an [issue](https://github.com/interlynk-io/sbomasm/issues/new), we'd love to help!
