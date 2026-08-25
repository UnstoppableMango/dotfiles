let
  flake = builtins.getFlake (toString ./..);
  inherit (flake) inputs;
  lib = inputs.nixpkgs.lib;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  repoRootStr = toString ./..;
  # `builtins.getFlake` evaluates against its own store copy, so paths dug
  # out of flake outputs (e.g. homeModules) are under `flake.outPath`, not
  # the real working-directory root. Normalize both to the same relative
  # id so the wiring layer actually connects to the walked module graph.
  storeRootStr = toString flake.outPath;

  relPath =
    p:
    let
      s = toString p;
    in
    if lib.hasPrefix (repoRootStr + "/") s then
      lib.removePrefix (repoRootStr + "/") s
    else if lib.hasPrefix (storeRootStr + "/") s then
      lib.removePrefix (storeRootStr + "/") s
    else
      s;

  # `flake.homeModules.*` comes back wrapped by home-manager's flake-parts
  # `deferredModule` option type (nested `{ imports = [ <wrapped> ]; }`
  # shells, several levels deep) rather than the bare path written in
  # flake.nix. Dig through that wrapping to find the real path.
  digPath =
    v:
    if builtins.typeOf v == "path" then
      v
    else if builtins.isAttrs v && v ? imports && builtins.isList v.imports && v.imports != [ ] then
      digPath (builtins.head v.imports)
    else if builtins.isList v && v != [ ] then
      digPath (builtins.head v)
    else
      v;

  externalNode = "external module (via inputs)";

  # Only supply the args a module actually declares, so functions without
  # `...` (e.g. plain closed patterns) don't error on unknown attrs.
  stubArgsFor =
    f:
    let
      wanted = builtins.functionArgs f;
    in
    lib.filterAttrs (n: _: builtins.hasAttr n wanted) {
      inherit lib pkgs inputs;
      config = { };
      osConfig = { };
      self = flake;
    };

  resolveModule =
    path:
    let
      v = import path;
    in
    if builtins.isFunction v then v (stubArgsFor v) else v;

  edge = from: to: {
    inherit from to;
  };

  # `rp` (the "from" node) is a plain lexical variable captured by the
  # `stepFrom` closure below, not part of the threaded accumulator — it
  # must stay fixed across sibling imports regardless of what the
  # recursive `walk` calls for earlier siblings return.
  walk =
    acc: path:
    let
      rp = relPath path;
    in
    if acc.visited ? ${rp} then
      acc
    else
      let
        acc1 = acc // {
          visited = acc.visited // {
            ${rp} = true;
          };
        };
        modVal = resolveModule path;
        importsList = if builtins.isAttrs modVal then (modVal.imports or [ ]) else [ ];
        # A "path" typed import isn't necessarily one of ours — e.g.
        # `inputs.nixvim.homeModules.nixvim` is itself a raw path into
        # nixvim's own module tree. Only recurse into paths that live
        # inside this repo; anything else (including such foreign paths)
        # is external, same as a function/attrset import value.
        isLocalPath = elem: builtins.typeOf elem == "path" && lib.hasPrefix repoRootStr (toString elem);
        stepFrom =
          acc2: elem:
          if isLocalPath elem then
            let
              childRel = relPath elem;
              acc3 = acc2 // {
                edges = acc2.edges ++ [ (edge rp childRel) ];
              };
            in
            walk acc3 elem
          else
            acc2 // { edges = acc2.edges ++ [ (edge rp externalNode) ]; };
      in
      lib.foldl' stepFrom acc1 importsList;

  entryPoints = [
    ../modules
    ../users/erik
    ../users/erik/server.nix
    ../users/erasmussen
    ../darwin/erasmussen
  ];

  walkResult = lib.foldl' walk {
    visited = { };
    edges = [ ];
  } entryPoints;

  rawModuleNodes = builtins.attrNames walkResult.visited;
  rawModuleEdges = walkResult.edges;

  # A parent that fans out to more than this many leaf modules (no imports
  # of their own) gets those leaves collapsed into one summary node in the
  # diagram, with the full list kept in the surrounding markdown text
  # instead. Post-processing over the already-derived edge list, not a
  # separate evaluation pass.
  collapseThreshold = 8;

  outDegree = lib.foldl' (
    acc: e: acc // { ${e.from} = (acc.${e.from} or 0) + 1; }
  ) { } rawModuleEdges;
  isLeafModule = rp: !(outDegree ? ${rp});
  childrenOf = p: map (e: e.to) (builtins.filter (e: e.from == p) rawModuleEdges);

  collapseCandidates = lib.unique (map (e: e.from) rawModuleEdges);
  collapses = builtins.filter (c: c.count > collapseThreshold) (
    map (
      p:
      let
        leaves = builtins.filter isLeafModule (childrenOf p);
      in
      {
        inherit p leaves;
        count = builtins.length leaves;
      }
    ) collapseCandidates
  );

  # Synthetic node id is namespaced under the parent's own path so groupOf
  # still places it in the parent's subgraph without any special-casing.
  synthRp = c: "${c.p}/(collapsed)";
  synthLabel = c: "${toString c.count} leaf modules";
  collapsedLeafSet = lib.unique (lib.concatMap (c: c.leaves) collapses);

  moduleNodes =
    (builtins.filter (rp: !(lib.elem rp collapsedLeafSet)) rawModuleNodes) ++ (map synthRp collapses);
  moduleEdges =
    (builtins.filter (e: !(lib.elem e.to collapsedLeafSet)) rawModuleEdges)
    ++ (map (c: edge c.p (synthRp c)) collapses);

  nodeLabelOverrides = lib.listToAttrs (
    map (c: {
      name = synthRp c;
      value = synthLabel c;
    }) collapses
  );
  nodeLabel = rp: nodeLabelOverrides.${rp} or rp;

  renderCollapseNote =
    c:
    "- `${c.p}` (${toString c.count}): "
    + lib.concatStringsSep ", " (map (l: "`${l}`") (lib.sort lib.lessThan c.leaves));

  # overlays/clan.nix isn't a home-manager module (closed `{ clan-core }:`
  # pattern, no `imports`), so it's wired in by hand rather than walked.
  clanNode = "overlays/clan.nix";
  clanEdge = edge "clan-core" clanNode;

  # composeManyExtensions [...] in flake.nix collapses to one opaque
  # function once evaluated, so which inputs feed it can't be recovered by
  # evaluation. Captured by hand from flake.nix's `overlay` definition.
  overlayNode = "overlay (flake.nix, composed)";
  overlayInputs = [
    "nixpkgs"
    "devctl"
    "mangopkgs"
    "nil"
    "nix-direnv"
    "nix-vscode-extensions"
  ];
  overlayEdges = map (i: edge i overlayNode) overlayInputs ++ [ (edge clanNode overlayNode) ];

  # homeConfigurations.<name> / darwinConfigurations.<name> don't retain
  # which named homeModules/darwinModules attr built them, so this pairing
  # (and the stylix/hosts/home-manager/nix-darwin wiring) is captured by
  # hand from flake.nix rather than derived.
  homeModuleTargets = {
    erik = relPath (digPath flake.homeModules.erik);
    erikServer = relPath (digPath flake.homeModules.erikServer);
    erasmussen = relPath (digPath flake.homeModules.erasmussen);
  };
  darwinModuleTargets = {
    erasmussen = relPath (digPath flake.darwinModules.erasmussen);
  };

  homeConfigNames = builtins.attrNames flake.homeConfigurations;
  darwinConfigNames = builtins.attrNames flake.darwinConfigurations;

  homeConfigModule = {
    "erik@darter" = homeModuleTargets.erik;
    "erik@hades" = homeModuleTargets.erik;
    "erik@server" = homeModuleTargets.erikServer;
    "erasmussen@Eriks-MacBook-Pro.local" = homeModuleTargets.erasmussen;
  };
  stylixConfigs = [
    "erik@darter"
    "erik@hades"
    "erasmussen@Eriks-MacBook-Pro.local"
  ];

  wiringEdges =
    (map (n: edge "home-manager" n) homeConfigNames)
    ++ (map (n: edge n homeConfigModule.${n}) homeConfigNames)
    ++ (map (n: edge "hosts" n) homeConfigNames)
    ++ (map (n: edge "stylix" n) stylixConfigs)
    ++ (map (n: edge overlayNode n) homeConfigNames)
    ++ (map (n: edge "nix-darwin" n) darwinConfigNames)
    ++ (map (n: edge n darwinModuleTargets.erasmussen) darwinConfigNames)
    ++ (map (n: edge "home-manager" n) darwinConfigNames)
    ++ (map (n: edge n homeModuleTargets.erasmussen) darwinConfigNames)
    ++ (map (n: edge "hosts" n) darwinConfigNames)
    ++ (map (n: edge "stylix" n) darwinConfigNames)
    ++ (map (n: edge overlayNode n) darwinConfigNames);

  inputNodes = builtins.attrNames inputs;

  allNodes =
    inputNodes
    ++ [
      overlayNode
      clanNode
      externalNode
    ]
    ++ homeConfigNames
    ++ darwinConfigNames
    ++ moduleNodes;

  allEdges = overlayEdges ++ [ clanEdge ] ++ wiringEdges ++ moduleEdges;

  sanitizeId =
    s:
    "n_"
    +
      builtins.replaceStrings
        [
          "/"
          "."
          "@"
          "-"
          " "
          "("
          ")"
          ":"
          ","
        ]
        [
          "_"
          "_"
          "_"
          "_"
          "_"
          "_"
          "_"
          "_"
          "_"
        ]
        s;

  groupOf =
    rp:
    if rp == externalNode then
      "External"
    else if lib.elem rp inputNodes then
      "Flake Inputs"
    else if rp == overlayNode || lib.elem rp (homeConfigNames ++ darwinConfigNames) then
      "flake.nix wiring"
    else
      let
        parts = lib.splitString "/" rp;
        n = builtins.length parts;
        c0 = builtins.elemAt parts 0;
        c1 = if n >= 2 then builtins.elemAt parts 1 else null;
        c2 = if n >= 3 then builtins.elemAt parts 2 else null;
      in
      if c0 == "modules" && c1 == "toolchain" && c2 == "kubernetes" then
        "modules/toolchain/kubernetes"
      else if c0 == "modules" && c1 != null then
        "modules/${c1}"
      else if c0 == "modules" then
        "modules"
      else if c0 == "users" && c1 != null then
        "users/${c1}"
      else
        c0;

  groupNames = lib.unique (map groupOf allNodes);

  nodesByGroup = lib.groupBy groupOf allNodes;

  renderGroup =
    g:
    let
      ns = lib.sort lib.lessThan (nodesByGroup.${g} or [ ]);
      lines = map (rp: "    ${sanitizeId rp}[\"${nodeLabel rp}\"]") ns;
    in
    ''
      subgraph "${g}"
      ${lib.concatStringsSep "\n" lines}
      end'';

  renderEdge = e: "  ${sanitizeId e.from} --> ${sanitizeId e.to}";

  mermaid = ''
    flowchart LR
    ${lib.concatStringsSep "\n" (map renderGroup (lib.sort lib.lessThan groupNames))}
    ${lib.concatStringsSep "\n" (map renderEdge (lib.unique allEdges))}
  '';

in
''
  # Module dependency graph

  Generated by `make graph` (`scripts/dep-graph.nix`) from the current state of `flake.nix`, `modules/`, `users/`, `darwin/`, and `overlays/`. Do not hand-edit; rerun `make graph` instead.

  Roots are flake inputs. Leaves are modules with no further local `imports`. Two things this graph deliberately omits (see `scripts/dep-graph.nix` for why): `config.dotfiles.*` option-read couplings between modules, and which specific flake input feeds a non-path `imports` entry (collapsed into the single `${externalNode}` node).

  ```mermaid
  ${mermaid}
  ```

  ${lib.optionalString (collapses != [ ])
    "Parents fanning out to more than ${toString collapseThreshold} leaf modules are collapsed to one summary node above; full lists:\n\n${lib.concatStringsSep "\n" (map renderCollapseNote collapses)}"
  }
''
