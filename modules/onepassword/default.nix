{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.onePassword;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # The desktop app owns the agent socket; it is not in the CLI package, and
  # the app is not installable from nixpkgs on macOS, where it is a sandboxed
  # bundle that keeps the socket under its group container.
  agentSocket =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  options.dotfiles.onePassword.enable = lib.mkEnableOption ''
    the 1Password CLI. Its SSH agent is chosen with
    `dotfiles.ssh.agent = "1password"`'';

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs._1password-cli ];

    programs.ssh.settings."*".IdentityAgent =
      lib.mkIf (config.dotfiles.ssh.agent == "1password")
        # Quoted because the macOS group container path contains spaces.
        ''"${agentSocket}"'';
  };
}
