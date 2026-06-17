---
layout: home

hero:
  name: "Core Toolkit"
  text: "for Claude"
  tagline: A structured AI-driven development workflow — from implementation through documentation sync and PR publication.
  image:
    src: /hero.png
    alt: Core Toolkit for Claude
  actions:
    - theme: brand
      text: Get Started
      link: /guide/
    - theme: alt
      text: View on GitHub
      link: https://github.com/ontheroadjp/core-toolkit-for-claude

features:
  - icon: <i class="fa-solid fa-code-branch"></i>
    title: /work
    details: Main entry point for all tasks. Gates → investigates → routes to patch or task flow automatically.
    link: /guide/
  - icon: <i class="fa-solid fa-file-circle-plus"></i>
    title: /new-issue
    details: Turns a rough idea into one or more well-formed GitHub issues. Optional pre-/work entry point.
    link: /guide/
  - icon: <i class="fa-solid fa-rotate"></i>
    title: /docs-sync
    details: Syncs docs to match implementation using git diff as truth, then publishes the draft PR.
    link: /developer/
  - icon: <i class="fa-solid fa-code-pull-request"></i>
    title: /review-resolve
    details: Fetches PR review comments and guides through addressing or declining each one interactively.
    link: /guide/
  - icon: <i class="fa-solid fa-book"></i>
    title: /task & /patch
    details: Delegated flows for implementation with or without documentation changes.
    link: /developer/specification
  - icon: <i class="fa-solid fa-shield-halved"></i>
    title: Hooks
    details: Auto-approve readonly commands, guard destructive operations, log token usage, and notify Slack.
    link: /guide/configuration
---
