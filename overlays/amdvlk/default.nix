{ ... }:

final: prev: {
  my_glslang = prev.glslang.overrideAttrs (finalAttrs: oldAttrs: {
    version = "15.0.0";
    src = self.fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "glslang";
      rev = "refs/tags/${finalAttrs.version}";
      hash = "sha256-QXNecJ6SDeWpRjzHRTdPJHob1H3q2HZmWuL2zBt2Tlw=";
    };
  });

  amdvlk = prev.amdvlk.overrideAttrs (old: {
    glslang = my_glslang;
    version = "2024.Q3.3";
  }); 
}
