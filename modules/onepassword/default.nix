{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.onePassword;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  usesAgent = config.dotfiles.ssh.agent == "1password";

  # The desktop app owns the agent socket and the signing helper; neither is
  # in the CLI package, and the app is not installable from nixpkgs on macOS,
  # where it is a sandboxed bundle that keeps the socket under its group
  # container and the helper inside the bundle.
  agentSocket =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";

  sshSignProgram =
    if isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${pkgs._1password-gui}/share/1password/op-ssh-sign";
in
{
  options.dotfiles.onePassword.enable = lib.mkEnableOption ''
    the 1Password CLI. Its SSH agent is chosen with
    `dotfiles.ssh.agent = "1password"`'';

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs._1password-cli ];

    programs.ssh.settings."*".IdentityAgent =
      lib.mkIf usesAgent
        # Quoted because the macOS group container path contains spaces.
        ''"${agentSocket}"'';

    # Keys held by 1Password never reach ssh-keygen, so git signs through the
    # app's helper instead.
    programs.git.settings.gpg.ssh.program = lib.mkIf (
      usesAgent && config.dotfiles.git.signing.key != null && config.dotfiles.git.signing.format == "ssh"
    ) sshSignProgram;
  };
}
