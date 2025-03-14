_:

_final: prev: {
  libiodbc = prev.libiodbc.overrideAttrs (_old: {
    configureFlags = [
      "--disable-libodbc"
    ];
  });
}
