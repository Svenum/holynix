{ ... }:

final: prev: {

  vimPlugins = prev.vimPlugins.extend (vfinal: vprev: {
    bracey-vim = prev.vimPlugins.bracey-vim.overrideAttrs (old:
    let
      nodeDependencies = (prev.callPackage ./npm.nix {}).nodeDependencies;
    in
    {
      buildInputs = [
        nodeDependencies
      ];

      buildPhase = ''
        ln -s ${nodeDependencies}/lib/node_modules ./node_modules
        export PATH="${nodeDependencies}/bin:$PATH"
      '';
    });
  });
}
