# Graph Report - dotfiles  (2026-10-27)

## Corpus Check
- 155 files · ~46,194 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 6 file(s) not represented in the graph (top: (none) 4, .lock 1, .zsh 1)

## Summary
- 628 nodes · 851 edges · 76 communities (47 shown, 29 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a297e87d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- openrouter/default.nix
- hades.settings.json
- i3/default.nix
- dotfiles.ai.enable
- dotfiles.git.enable
- flake.nix
- hosts/hades.nix
- hosts/container.nix
- generic.nix
- Payload contracts
- github/default.nix
- ai/omnigent.nix
- How to Review
- json.schemaDownload.trustedDomains
- AGENTS.md
- How to Review
- How to Review
- How to Review
- Workflow
- How to Review
- AGENTS.md
- Agent context
- github.nix
- remote-control.nix
- Global agent instructions
- How to Review
- How to Review
- MoE Review (with Verification)
- dotfiles.zsh.enable
- server.nix
- ai/crush.nix
- yubikey/default.nix
- UnstoppableMango's dotfiles
- YubiKey onboarding
- coderabbit.nix
- dotfiles.kubernetes.enable
- GitHub MCP token
- Hyprland session
- i3 session
- extends
- [dockercompose]
- tdd-red.agent.md
- dotfiles.zsh.font
- slip/default.nix
- formatting
- tdd-green.agent.md
- tdd-refactor.agent.md
- aws.nix
- azure.nix
- chrome-devtools.nix
- containers.nix
- cursor.nix
- git-mcp.nix
- go.nix
- gossamer.nix
- haskell.nix
- kubernetes.nix
- playwright.nix
- rust.nix
- terraform.nix
- typescript.nix
- signal/default.nix
- dotfiles.zed.enable
- [csharp]
- [github-actions-workflow]
- gopls
- [jsonc]
- [nix]
- vs-kubernetes
- yaml.schemas
- moer/README.md
- nix-skill/SKILL.md
- tdd-orchestrator/README.md

## God Nodes (most connected - your core abstractions)
1. `dotfiles.ai.enable` - 48 edges
2. `dotfiles.git.enable` - 12 edges
3. `dotfiles.zsh.enable` - 11 edges
4. `json.schemaDownload.trustedDomains` - 10 edges
5. `AGENTS.md` - 9 edges
6. `dotfiles.stylix.enable` - 8 edges
7. `Agent context` - 8 edges
8. `MoE Review (with Verification)` - 8 edges
9. `dotfiles.kubernetes.enable` - 7 edges
10. `dotfiles.zsh.ohMyZsh.enable` - 7 edges

## Surprising Connections (you probably didn't know these)
- `withToken` --references--> `dotfiles.github.token.file`  [EXTRACTED]
  modules/ai/github.nix → modules/github/default.nix

## Import Cycles
- None detected.

## Communities (76 total, 29 thin omitted)

### Community 0 - "openrouter/default.nix"
Cohesion: 0.07
Nodes (25): dotfiles.ai.opencode.desktop.enable, dotfiles.ai.opencode.enable, dotfiles.openrouter.apiKeyFile, dotfiles.openrouter.apiKeyPlaceholder, dotfiles.openrouter.apiKeySecret, dotfiles.openrouter.baseUrl, dotfiles.openrouter.crush.enable, dotfiles.openrouter.crush.model (+17 more)

### Community 1 - "hades.settings.json"
Cohesion: 0.05
Nodes (38): chat.fontSize, chat.mcp.gallery.enabled, docker.lsp.telemetry, dotnet.defaultSolution, dotnetAcquisitionExtension.enableTelemetry, editor.experimental.treeSitterTelemetry, editor.formatOnSave, explorer.autoReveal (+30 more)

### Community 2 - "i3/default.nix"
Cohesion: 0.07
Nodes (23): bind, exec, dpms, exec, line, dotfiles.bizhawk.enable, dotfiles.bizhawk.package, dotfiles.brave.enable (+15 more)

### Community 3 - "dotfiles.ai.enable"
Cohesion: 0.11
Nodes (14): dotfiles.ai.braveSearch.enable, dotfiles.ai.caveman.enable, dotfiles.ai.claudeDesktop.package, dotfiles.ai.context7.enable, dotfiles.ai.deepwiki.enable, dotfiles.ai.enable, dotfiles.ai.figma.enable, dotfiles.ai.ghStack.enable (+6 more)

### Community 4 - "dotfiles.git.enable"
Cohesion: 0.12
Nodes (17): renderValue, signerLine, dotfiles.git.enable, dotfiles.git.gitkraken.package, dotfiles.git.localConfig, dotfiles.git.openCommit.apiKeySecret, dotfiles.git.openCommit.enable, dotfiles.git.openCommit.mode (+9 more)

### Community 5 - "flake.nix"
Cohesion: 0.09
Nodes (10): outputs, isModule, dotfiles.ai.mattpocock.src, dotfiles.neovim.defaultConfig, dotfiles.onePassword.enable, dotfiles.ssh.certAuthorities, dotfiles.ssh.hostKeyAliasDomain, dotfiles.ssh.hosts (+2 more)

### Community 6 - "hosts/hades.nix"
Cohesion: 0.11
Nodes (16): dotfiles.emacs.enable, dotfiles.helix.enable, dotfiles.kubernetes.rosequartz.admin.certFile, dotfiles.kubernetes.rosequartz.admin.keyFile, dotfiles.kubernetes.rosequartz.caFile, dotfiles.kubernetes.rosequartz.clusterName, dotfiles.kubernetes.rosequartz.currentContext, dotfiles.kubernetes.rosequartz.enable (+8 more)

### Community 7 - "hosts/container.nix"
Cohesion: 0.10
Nodes (12): dotfiles.ai.cloudflare.enable, dotfiles.ai.copilot.enable, dotfiles.ai.csharp.enable, dotfiles.ai.cursor.cli.enable, dotfiles.ai.fsharp.enable, dotfiles.ai.fsharp.mcp.enable, dotfiles.ai.gitlab.enable, dotfiles.ai.ocaml.enable (+4 more)

### Community 8 - "generic.nix"
Cohesion: 0.14
Nodes (13): dotfiles.ai.claudeDesktop.enable, dotfiles.c.enable, dotfiles.fonts.enable, dotfiles.git.gitkraken.enable, dotfiles.go.enable, dotfiles.homeManager.enable, dotfiles.neovim.enable, dotfiles.obsidian.enable (+5 more)

### Community 9 - "Payload contracts"
Cohesion: 0.12
Nodes (15): Dispatch mechanism, Green — input, Green — output, Loop, Payload contracts, Red — input (orchestrator → subagent), Red — output (subagent → orchestrator), Refactor — input (+7 more)

### Community 10 - "github/default.nix"
Cohesion: 0.12
Nodes (13): dotfiles.automation.flakeUpdate.enable, dotfiles.automation.flakeUpdate.flakePath, dotfiles.automation.flakeUpdate.onCalendar, dotfiles.github.token.flakePath, dotfiles.github.token.onCalendar, dotfiles.github.token.secret, dotfiles.github.token.sopsFile, dotfiles.github.token.sopsKey (+5 more)

### Community 11 - "ai/omnigent.nix"
Cohesion: 0.15
Nodes (10): dotfiles.ai.omnigent.autostart, dotfiles.ai.omnigent.caBundle, dotfiles.ai.omnigent.desktopApp, dotfiles.ai.omnigent.enable, dotfiles.ai.omnigent.listenAddress, dotfiles.containers.podmanAutostart, dotfiles.containers.podmanSocket, dotfiles.containers.sharedAuth (+2 more)

### Community 12 - "How to Review"
Cohesion: 0.18
Nodes (10): 1. Discover Instruction Files, 2. Extract Enforceable Rules, 3. Check the Diff Against Each Rule, 4. Verify the Rule Applies, 5. Citation Rule (MANDATORY), 6. Report, How to Review, Review Specialist: Team Policy (+2 more)

### Community 13 - "json.schemaDownload.trustedDomains"
Cohesion: 0.20
Nodes (10): json.schemaDownload.trustedDomains, https://developer.microsoft.com/json-schemas/, https://docs.renovatebot.com/, https://json-schema.org/, https://json.schemastore.org/, https://raw.githubusercontent.com/devcontainers/spec/, https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json, https://raw.githubusercontent.com/microsoft/vscode/ (+2 more)

### Community 14 - "AGENTS.md"
Cohesion: 0.20
Nodes (9): AGENTS.md, CI and releases, Cross-repo relationships, Entry points, Finding things, Language conventions, Layout, Owners (+1 more)

### Community 15 - "How to Review"
Cohesion: 0.20
Nodes (9): 1. Identify Concurrent Access Points, 2. Trace the Lock Acquisition Sequence, 3. Enumerate Interleavings, 4. Check Cache Timing, 5. Citation Rule (MANDATORY), 6. Report, How to Review, Review Specialist: Concurrency (+1 more)

### Community 16 - "How to Review"
Cohesion: 0.20
Nodes (9): 1. Trace the Hot Path, 2. For Each Lock/Connection Acquisition, Ask:, 3. Check Early-Exit Opportunities, 4. Check Batching Opportunities, 5. Citation Rule (MANDATORY), 6. Report, How to Review, Review Specialist: Performance (+1 more)

### Community 17 - "How to Review"
Cohesion: 0.20
Nodes (9): 1. Identify Multi-Step Operations, 2. Kill Each Dependency Mid-Flight, 3. Check Error Propagation, 4. Check Migration Safety, 5. Citation Rule (MANDATORY), 6. Report, How to Review, Review Specialist: Resilience (+1 more)

### Community 18 - "Workflow"
Cohesion: 0.20
Nodes (9): 1. Get the Code, 2. Dispatch 7 Specialist Reviewers × 2 Passes Each, 3. Aggregate Claims, 4. Deduplicate, 5. Report, Inputs, Review Specialist Supervisor, Sub-Agent Context (+1 more)

### Community 19 - "How to Review"
Cohesion: 0.20
Nodes (9): 1. For Each Test, Ask "What Mutation Would This Catch?", 2. Check Mock Boundaries, 3. Check Assertion Specificity, 4. Check Coverage of New Code, 5. Citation Rule (MANDATORY), 6. Report, How to Review, Review Specialist: Test Quality (+1 more)

### Community 20 - "AGENTS.md"
Cohesion: 0.22
Nodes (7): Architecture, Cachix, Class vs Instance Modules, Common Commands, Formatting, graphify, Overview

### Community 21 - "Agent context"
Cohesion: 0.22
Nodes (8): Agent context, Apply and verify, Commit, House style, Pick the right scope, The one file, What belongs, Where to put it in the file

### Community 22 - "github.nix"
Cohesion: 0.25
Nodes (6): withToken, dotfiles.ai.adhd.enable, dotfiles.ai.crush.crushrc, dotfiles.ai.github.ghAuth, dotfiles.ai.mattpocock.enable, dotfiles.github.token.file

### Community 23 - "remote-control.nix"
Cohesion: 0.22
Nodes (7): dotfiles.ai.checkoutRoot.context, dotfiles.ai.checkoutRoot.path, dotfiles.ai.remoteControl.enable, dotfiles.ai.remoteControl.name, dotfiles.ai.remoteControl.permissionMode, dotfiles.ai.remoteControl.rootDir, dotfiles.ai.remoteControl.spawn

### Community 24 - "Global agent instructions"
Cohesion: 0.22
Nodes (8): Asking questions, Automated review findings, Bug fixing and review, Commit and PR conventions, Docs and comments, English style, Global agent instructions, Shell autoload issue

### Community 25 - "How to Review"
Cohesion: 0.22
Nodes (8): 1. Understand, 2. Trace Data Flow, 3. Check Contracts, 4. Citation Rule (MANDATORY), 5. Report, How to Review, Review Specialist: Correctness, Your Lens

### Community 26 - "How to Review"
Cohesion: 0.22
Nodes (8): 1. Map the Trust Boundaries, 2. Trace Auth Through Each Path, 3. Check Credential Handling, 4. Citation Rule (MANDATORY), 5. Report, How to Review, Review Specialist: Security, Your Lens

### Community 27 - "MoE Review (with Verification)"
Cohesion: 0.22
Nodes (8): Anti-Patterns (DO NOT), Inputs, MoE Review (with Verification), Principles, Step 1: Dispatch the Specialist MoE, Step 2: Verify Each Claim, Step 3: Present Results, Step 4: Wait for Human Decision

### Community 28 - "dotfiles.zsh.enable"
Cohesion: 0.33
Nodes (5): dotfiles.javascript.enable, dotfiles.zsh.enable, dotfiles.zsh.ohMyZsh.enable, dotfiles.zsh.p10kConfig, dotfiles.zsh.prezto.enable

### Community 29 - "server.nix"
Cohesion: 0.29
Nodes (5): dotfiles.containers.enable, dotfiles.gnupg.enable, dotfiles.gnupg.pinentry, dotfiles.nix.enable, dotfiles.ssh.enable

### Community 30 - "ai/crush.nix"
Cohesion: 0.36
Nodes (7): command, flag, flags, pairs, quote, dotfiles.ai.crush.enable, dotfiles.ai.crush.oauthServers

### Community 31 - "yubikey/default.nix"
Cohesion: 0.25
Nodes (6): downloadedAs, dotfiles.sops.enable, dotfiles.sops.keyFile, dotfiles.yubikey.availableKeys, dotfiles.yubikey.enable, dotfiles.yubikey.gui

### Community 32 - "UnstoppableMango's dotfiles"
Cohesion: 0.25
Nodes (7): Consuming from another flake, Dendritic Pattern, Development, Home configurations, Layout, References and Links, UnstoppableMango's dotfiles

### Community 33 - "YubiKey onboarding"
Cohesion: 0.29
Nodes (6): New key, New machine, Prerequisites, Recovery, Troubleshooting, YubiKey onboarding

### Community 34 - "coderabbit.nix"
Cohesion: 0.33
Nodes (5): dotfiles.ai.coderabbit.apiKeySecret, dotfiles.ai.coderabbit.autoUpdate, dotfiles.ai.coderabbit.enable, dotfiles.ai.coderabbit.package, dotfiles.ai.coderabbit.region

### Community 35 - "dotfiles.kubernetes.enable"
Cohesion: 0.40
Nodes (3): dotfiles.k9s.enable, dotfiles.kubernetes.enable, dotfiles.openshift.enable

### Community 36 - "GitHub MCP token"
Cohesion: 0.40
Nodes (4): Expiry check, GitHub MCP token, Rotating, Token settings

### Community 37 - "Hyprland session"
Cohesion: 0.40
Nodes (4): Hyprland session, NixOS (hades), Switching, What the session is

### Community 38 - "i3 session"
Cohesion: 0.40
Nodes (4): i3 session, NixOS (hades), Other distributions (darter), Switching

### Community 39 - "extends"
Cohesion: 0.40
Nodes (4): extends, $schema, github>UnstoppableMango/renovate-config, schedule:daily

### Community 40 - "[dockercompose]"
Cohesion: 0.40
Nodes (5): [dockercompose], editor.autoIndent, editor.defaultFormatter, editor.insertSpaces, editor.tabSize

### Community 41 - "tdd-red.agent.md"
Cohesion: 0.40
Nodes (4): Hard rules, Return format, Stub rules (when you must), What you do

### Community 42 - "dotfiles.zsh.font"
Cohesion: 0.40
Nodes (3): dotfiles.ghostty.enable, dotfiles.kitty.enable, dotfiles.zsh.font

### Community 43 - "slip/default.nix"
Cohesion: 0.40
Nodes (4): dotfiles.slip.notebook.init, dotfiles.slip.notebook.path, dotfiles.slip.package, dotfiles.slip.zk.settings

### Community 44 - "formatting"
Cohesion: 0.50
Nodes (4): command, formatting, nix.serverSettings, nil

### Community 45 - "tdd-green.agent.md"
Cohesion: 0.50
Nodes (3): Hard rules, Return format, What you do

### Community 46 - "tdd-refactor.agent.md"
Cohesion: 0.50
Nodes (3): Hard rules, Return format, What you do

## Knowledge Gaps
- **121 isolated node(s):** `github>UnstoppableMango/renovate-config`, `schedule:daily`, `dotfiles.ai.adhd.enable`, `dotfiles.ai.aws.mcp.enable`, `dotfiles.ai.azure.mcp.enable` (+116 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 373 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **29 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dotfiles.ai.enable` connect `dotfiles.ai.enable` to `openrouter/default.nix`, `hosts/hades.nix`, `hosts/container.nix`, `generic.nix`, `ai/omnigent.nix`, `github.nix`, `remote-control.nix`, `ai/crush.nix`, `coderabbit.nix`, `aws.nix`, `azure.nix`, `chrome-devtools.nix`, `containers.nix`, `cursor.nix`, `git-mcp.nix`, `go.nix`, `gossamer.nix`, `haskell.nix`, `kubernetes.nix`, `playwright.nix`, `rust.nix`, `terraform.nix`, `typescript.nix`?**
  _High betweenness centrality (0.142) - this node is a cross-community bridge._
- **What connects `github>UnstoppableMango/renovate-config`, `schedule:daily`, `dotfiles.ai.adhd.enable` to the rest of the system?**
  _121 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `openrouter/default.nix` be split into smaller, more focused modules?**
  _Cohesion score 0.07435897435897436 - nodes in this community are weakly interconnected._
- **Why does `dotfiles.git.enable` connect `dotfiles.git.enable` to `openrouter/default.nix`, `hosts/hades.nix`, `hosts/container.nix`, `generic.nix`, `server.nix`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Should `hades.settings.json` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Why does `dotfiles.stylix.enable` connect `generic.nix` to `i3/default.nix`, `hosts/hades.nix`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Should `i3/default.nix` be split into smaller, more focused modules?**
  _Cohesion score 0.06854838709677419 - nodes in this community are weakly interconnected._