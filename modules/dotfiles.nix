{ config, pkgs, lib, dotfilesDir, ... }:

let
  username = "marcogomez";
  homeDir = "/home/${username}";
in {
  environment.etc = {
    "dotfiles/zsh/zshrc".source = "${dotfilesDir}/zsh/zshrc";
  };

  systemd.user.services.dotfiles-setup = {
    description = "Symlink dotfiles into user home";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "link-dotfiles" ''
        mkdir -p "${homeDir}/.config"
        ln -sf /etc/dotfiles/zsh/zshrc "${homeDir}/.zshrc"
        chown ${username}:${username} "${homeDir}/.zshrc"
      '';
    };
  };

  systemd.user.targets.default.wantedBy = [ "graphical-session.target" ];
}
