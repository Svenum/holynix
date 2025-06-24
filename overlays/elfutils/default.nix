_:

_final: prev: {
  elfutils = prev.elfutils.overrideAttrs
    (_old: {
      version = "0.192";
      precheck = "";
      src = fetchurl {
        url = "https://sourceware.org/elfutils/ftp/${version}/${pname}-${version}.tar.bz2";
        hash = "sha256-YWCZvq4kq6Efm2PYbKbMjVZtlouAI5EzTJHfVOq0FrQ=";
      };
    });
}
