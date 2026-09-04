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
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536";
      };
      loadModels = [
        "qwen3.5:9b-q4_K_M"
        "qwen3:8b"
      ];
    };
  };
}
