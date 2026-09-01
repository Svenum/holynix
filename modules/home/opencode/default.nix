{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.opencode;
in
{
  options.holynix.opencode = {
    enable = mkEnableOption "Enable opencode";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = {
        model = "ollama/LisyNeko/qwen3.8-9b-coder:latest";
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "LisyNeko/qwen3.8-9b-coder:latest" = {
                name = "Qwen3.8 9B Coder";
              };
            };
          };
        };
      };
    };
  };
}
