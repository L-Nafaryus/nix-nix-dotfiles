{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.graphics;
    configDir = config.dotfiles.configDir;
in {
    options.modules.desktop.graphics = {
        enable         = mkBoolOpt false;
        tools.enable   = mkBoolOpt true;
        raster.enable  = mkBoolOpt true;
        vector.enable  = mkBoolOpt true;
        sprites.enable = mkBoolOpt false;
        models.enable  = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs;
            (if cfg.tools.enable then [
                font-manager
                imagemagick
            ] else []) ++

            # replaces illustrator & indesign
            (if cfg.vector.enable then [
                unstable.inkscape
            ] else []) ++

            # Replaces photoshop
            (if cfg.raster.enable then [
                krita
                gimp
            ] else []) ++

            # Sprite sheets & animation
            (if cfg.sprites.enable then [
                aseprite-unfree
            ] else []) ++

            # 3D modelling
            (if cfg.models.enable then [
                unstable.blender-hip
            ] else []);
    };
}
