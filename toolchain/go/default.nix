{
  flake.modules.homeManager.go = {
    programs.go = {
      enable = true;
      telemetry.mode = "off";
    };
  };
}
