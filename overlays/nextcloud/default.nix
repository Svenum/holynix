_:

_: prev: {
  nextcloud-client = prev.nextcloud-client.overrideAttrs (old: rec {
    version = "4.0.0";
    src = prev.fetchFromGitHub {
      owner = "nextcloud-releases";
      repo = "desktop";
      tag = "v${version}";
      hash = "sha256-IXX1PdMR3ptgH7AufnGKBeKftZgai7KGvYW+OCkM8jo=";
    };
  });
}
