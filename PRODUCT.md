# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Wallee teammates setting up a Mac for Codex and ChatGPT, including people following the setup live during a presentation.

## Product purpose

Wallee AI Config turns a multi-step workstation setup into one rerunnable command. Success means a teammate can install the required tools, public agent instructions, and public skills without reconstructing Yannic's machine by hand.

## Positioning

The repository combines workstation packages, a public-safe projection of Yannic's Codex defaults, and the complete public systems-thinking skill suite. It keeps optional access to Zendesk as a separate human decision.

## Operating context

The installer runs in Terminal on macOS. It uses Homebrew, GitHub, the `skills` CLI, and Codex. The repository is public and must remain safe to share outside Wallee.

## Capabilities and constraints

- Install Homebrew when missing.
- Install Codex, ChatGPT, Node.js, pnpm, and Git.
- Install global Codex instructions and a selected Codex configuration profile.
- Install all skills from `JustYannicc/skills`, plus `unslop`, `writing-for-agents`, `grilling`, and `research` from their public sources.
- Preserve replaced local files as timestamped backups.
- Keep Zendesk disabled unless the person running the installer opts in.
- Exclude credentials, private project rules, private URLs, machine paths, and project-specific trust entries.

## Brand commitments

The public name is "Wallee AI Config." The Wallee bird identity is Tailorbird, represented by a common tailorbird, `Orthotomus sutorius`, in the shared ordered-dither toy-bird family. The compact bird and ANSI Shadow wordmark remain separate assets.

## Evidence on hand

The source setup list and public repository URLs came from the user. The existing local Wallee config candidate supplied the desktop preferences and high-trust profile. No customer claims, benchmarks, or private Wallee material belong in the repository.

## Product principles

- One command starts the setup.
- Reruns preserve working state and create recoverable backups before replacement.
- Public defaults do not grant broad authority silently.
- Human decisions stay visible where access or risk changes.
