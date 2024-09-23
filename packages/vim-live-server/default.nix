{ lib
, vimUtils
, fetchFromGitHub
, nodePackages
}:

vimUtils.buildVimPlugin {
  name = "vim-live-server";
  src = fetchFromGitHub {
    owner = "wolandark";
    repo = "vim-live-server";
    rev = "master";
    hash = "sha256-uD7pBehPJVz44raINCScXkxMN4iiGejUQ1M32mV3YKQ=";
  };
}
