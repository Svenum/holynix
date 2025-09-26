{ vimUtils
, fetchFromGitHub
}:

vimUtils.buildVimPlugin rec{
  name = "pets-nvim";
  version = "2025-09-26";
  src = fetchFromGitHub {
    owner = "giusgad";
    repo = "pets.nvim";
    rev = "main";
    hash = "sha256-Dslrf6aw16Q4lKrQ/OAOOrS9oC6OMlB49BadAqzBcOY=";
  };
  meta = {
    homepage = "https://github.com/giusgad/pets.nvim";
  };
}
