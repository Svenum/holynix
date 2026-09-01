{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.ollama;
in
{
  options.holynix.services.ollama = {
    enable = mkEnableOption "Enable ollama service";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      loadModels = [
        "LisyNeko/qwen3.8-9b-coder"
      ];
    };
  };
}
