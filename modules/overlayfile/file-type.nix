# https://github.com/nix-community/home-manager/blob/master/modules/lib/file-type.nix
{ name, config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    types
    literalExpression
  ;

  inherit (import ./lib.nix { inherit lib; }) storeFileName;
in {
  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether this file should be generated. This option allows specific
        files to be disabled.
      '';
    };

    target = mkOption {
      type = types.str;
      default = name;
      defaultText = literalExpression "<name>";
      description = ''
        Path to target file.
      '';
    };

    text = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Text of the file. If this option is null then
        <xref linkend="opt-home.file._name_.source"/>
        must be set.
      '';
    };

    source = mkOption {
      type = types.path;
      default = pkgs.writeText (storeFileName name) config.text;
      description = ''
        Path of the source file or directory. If
        <xref linkend="opt-home.file._name_.text"/>
        is non-null then this option will automatically point to a file
        containing that text.
      '';
    };
  };
}
