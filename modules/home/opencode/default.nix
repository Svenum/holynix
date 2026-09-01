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
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
          };
        };
      };
    };
  };
}
