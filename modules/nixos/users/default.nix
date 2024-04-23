{ options, config, lib, ... }:

let
  cfg = config.holynix.users;
in
{
  options.holynix = {
    users = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule (
        { name, config, options, ... }:
        {
          options = {
            isGuiUser = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            isSudoUser = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            isKvmUser = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            git = {
              userName = lib.mkOption {
                type = lib.types.string;
                default = name;
              };
              userEmail = lib.mkOption {
                type = lib.types.string;
                default = name + "@example.com";
              };
            };
          };
        }
      ));
    };
  };

  config = lib.mkIf (if cfg != {} then true else false) {

  };
}
