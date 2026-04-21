{
  flake.modules.homeManager.k9s = _: {
    programs.k9s = {
      enable = true;
      settings.k9s.ui.skin = "pink";
      skins.pink.k9s = {
        body = {
          fgColor = "#ee2677";
          bgColor = "#0a090c";
          logoColor = "#dc6acf";
        };
        info = {
          fgColor = "#5e239d";
          sectionColor = "#dc6acf";
        };
        frame = {
          border = {
            fgColor = "#dc6acf";
            focusColor = "#ee2677";
          };
          menu = {
            fgColor = "#ffe6e8";
            keyColor = "#1csd99";
            numKeyColor = "#ee2677";
          };
          crumbs = {
            fgColor = "#ee2677";
            bgColor = "#1f1f1f";
            activeColor = "#1f1f1f";
          };
          status = {
            newColor = "#5e239d";
            modifyColor = "#dc6acf";
            addColor = "lightskyblue";
            errorColor = "indianred";
            highlightcolor = "#ee2677";
            killColor = "slategray";
            completedColor = "gray";
          };
          title = {
            fgColor = "#dc6acf";
            bgColor = "#1e1f0f";
            highlightColor = "#5e239d";
            counterColor = "#ffe6e8";
            filterColor = "#ee2677";
          };
        };
        views = {
          table = {
            fgColor = "#0a090c";
            bgColor = "#0f0f0f";
            cursorColor = "#ffe6e8";
            header = {
              fgColor = "#ee2677";
              bgColor = "#0f0f0f";
              sorterColor = "#dc6acf";
            };
          };
          yaml = {
            keyColor = "#5e239d";
            colonColor = "#ee2677";
            valueColor = "#dc6acf";
          };
          logs = {
            fgColor = "#ffe6e8";
            bgColor = "#0f0f0f";
          };
        };
      };
    };
  };
}
