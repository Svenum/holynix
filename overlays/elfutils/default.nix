_:

_final: prev: {
  elfutils = prev.elfutils.overrideAttrs
    (old: rec{
      version = "0.192";
      precheck = "";
      src = prev.fetchurl {
        url = "https://sourceware.org/elfutils/ftp/${version}/${old.pname}-${version}.tar.bz2";
        hash = "sha256-YWCZvq4kq6Efm2PYbKbMjVZtlouAI5EzTJHfVOq0FrQ=";
      };
    });
}
