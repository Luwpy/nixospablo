# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "br";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pablo = {
    isNormalUser = true;
    description = "pablo";
    initialPassword = "123456"
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  ## Remove XTerm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  ## Add packages
  environment.systemPackages = with pkgs; [
    chromium
    git
    vscode
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  ## Remove default GNOME apps - comment out apps you want to keep
  environment.gnome.excludePackages = (with pkgs; [
    gnome-connections
    gnome-photos
    gnome-text-editor
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    # cheese      # photo booth
    # eog         # image viewer
    epiphany    # web browser
    # evince      # document viewer
    # file-roller # archive manager
    geary       # email client
    seahorse    # password manager
    # simple-scan # document scanner
    # totem       # video player
    yelp        # help viewer

    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    # gnome-disk-utility
    # gnome-font-viewer
    # gnome-logs
    gnome-maps
    gnome-music
    # gnome-screenshot
    # gnome-system-monitor
    gnome-weather
  ]);

  home = {
    file.".config/autostart-login.sh".text = ''
    #!/bin/sh
    curl -o ~/windows.iso https://software.download.prss.microsoft.com/dbazure/Win11_24H2_BrazilianPortuguese_x64.iso?t=576085ec-9ac7-42dd-856e-94d350a0e9f8&P1=1744079567&P2=601&P3=2&P4=LQzTbjeSAVjg36c953GLa2dBDMC3XpThvOG9RGCpL%2ftkD9%2fzfy5is70Zoa5amL5T1DEwN8ZQTgUI%2bVOVaoSiK8CmybEGGuBsi%2fiR44xAb9lInO33zYKkfT1uf9S4OShIQFygvYfB9wfD99J5ZXbhos2Pymco9YhUuqDSU%2bDJTUzG1L9FwdrjSBRcVBJ3I6KAAE3G%2fGpBrLIf9VtaYF41V1IZmjx9gjx755l%2bN5X04XWQTmICauZZooq%2bCI8njdBzcDOaHejz%2fK1tJsjg%2bJ%2fxq5F4qapCMA7rMoDiesiUDTRVI3gx6b30OdYEPeg8uSPH8%2f79ZiBXw9thj4ijtQ67tg%3d%3d

    ''
  }

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
