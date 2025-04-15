{ pkgs, config, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings = {
    trusted-users = ["root" "marcogomez"];

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://nix-shell.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs.cachix.org"
    ];

    trusted-public-keys = [
      "nix-shell.cachix.org-1:kat3KoRVbilxA6TkXEtTN9IfD4JhsQp1TPUHg652Mwc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Enable the OpenSSH service
  services.openssh.enable = true;

  # Set the locale and timezone
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.utf8";

  # Configure networking
  networking.hostName = "threadripper";
  networking.networkmanager.enable = true;

  # Enable the firewall
  networking.firewall.enable = false;

  # Enable the Wayland compositor
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # User configuration
  programs.zsh.enable = true;
  
  users.users.marcogomez = {
    uid = 1000;
    isNormalUser = true;
    packages = with pkgs; [];
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" "realtime" ];
  };

  security.pam.loginLimits = [
    { domain = "@realtime"; item = "rtprio"; type = "soft"; value = "95"; }
    { domain = "@realtime"; item = "rtprio"; type = "hard"; value = "95"; }
    { domain = "@realtime"; item = "memlock"; type = "soft"; value = "unlimited"; }
    { domain = "@realtime"; item = "memlock"; type = "hard"; value = "unlimited"; }
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire = {
      "10-default" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ 48000 96000 192000 ];
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
        };
      };
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  environment.systemPackages = with pkgs; [
    wget git git-lfs neovim llvm autoconf automake cmake ninja gettext gnumake
    meson clang gcc nasm curl gnupg most lsb-release gawk zsh
    tmux tree gnutar jq unzip ffmpeg bc fzf ripgrep zsh zsh-completions
    zsh-syntax-highlighting zsh-autosuggestions neofetch ghostty fd    
    libtool bzip2 zip zlib plocate SDL SDL2 sdl3
    fluidsynth timidity mesa libGLU glew mpg123 noto-fonts-emoji btop
    libjpeg libgme libsndfile libvpx flatpak cloudflared gh
    docker docker-compose nvidia-container-toolkit noto-fonts
    imagemagick ffmpeg yt-dlp firefox discord ardour prismlauncher
    dialog wl-clipboard wofi vscode code-cursor brave google-chrome
    kdePackages.qt6ct oversteer raysession kdePackages.dolphin obs-studio
    vlc wl-clipboard-rs prismlauncher winetricks protonup-ng gimp kdePackages.kdenlive
    blender mpv qt5.qtwayland qt6.qtwayland

    (pkgs.raysession.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/raysession \
          --set QT_QPA_PLATFORM wayland \
          --prefix QT_QPA_PLATFORM_PLUGIN_PATH : "${pkgs.qt5.qtbase}/lib/qt-5/plugins/platforms"
      '';
    }))


    (python3.withPackages (python-pkgs: with python-pkgs; [
      pandas
      pynvim
      ipython
    ]))

    (pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [
        docker-credential-gcr
        beta
        alpha
        gsutil
        gke-gcloud-auth-plugin
        terraform-tools
        cloud-datastore-emulator
        cloud-firestore-emulator
        cloud-spanner-emulator
        pubsub-emulator
      ]
    ))
  ];

  system.stateVersion = "24.11";
}
