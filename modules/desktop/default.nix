{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop;
in {
    config = mkIf config.services.xserver.enable {
        assertions = [
            {
              assertion = (countAttrs (n: v: n == "enable" && value) cfg) < 2;
              message = "Can't have more than one desktop environment enabled at a time";
            }
            {
              assertion =
              let
                  srv = config.services;
              in
                  srv.xserver.enable || srv.sway.enable ||
                      !(anyAttrs (n: v: isAttrs v && anyAttrs (n: v: isAttrs v && v.enable)) cfg);
              message = "Can't enable a desktop app without a desktop environment";
            }
        ];

        user.packages = with pkgs; [
            xclip
            xdotool
            qgnomeplatform        # QPlatformTheme for a better Qt application inclusion in GNOME
            libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
        ];

        fonts = {
            fontDir.enable = true;
            enableGhostscriptFonts = true;
            fonts = with pkgs; [
                ubuntu_font_family
                dejavu_fonts
                symbola
                nerdfonts
            ];
        };

        # Try really hard to get QT to respect my GTK theme.
        env = {
            GTK_DATA_PREFIX = [ "${config.system.path}" ];
            QT_QPA_PLATFORMTHEME = "gnome";
            QT_STYLE_OVERRIDE = "kvantum";
        };

        services.xserver.displayManager.sessionCommands = ''
            # GTK2_RC_FILES must be available to the display manager.
            export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
        '';

        # Clean up leftovers, as much as we can
        system.userActivationScripts.cleanupHome = ''
            pushd "${config.user.home}"
            rm -rf .compose-cache .nv .pki .dbus .fehbg
            [ -s .xsession-errors ] || rm -f .xsession-errors*
            popd
        '';
    };
}
