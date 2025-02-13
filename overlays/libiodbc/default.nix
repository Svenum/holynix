{ ... }:

final: prev: {
  libiodbc = prev.libiodbc.overrideAttrs (old: {
    configureFlags = [
     "--disable-libodbc"
    ];
  });
}
