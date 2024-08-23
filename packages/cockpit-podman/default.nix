{
  nodejs,
  makeWrapper,
  gettext,
  stdenv,
  fetchFromGitHub,
  gnutls,
  glib,
  systemd,
  pkg-config,
  autoreconfHook,
  json-glib,
  krb5,
  polkit,
  libssh,
  pam,
  libxcrypt,
  libxslt,
  xmlto,
  python3Packages,
  docbook_xsl,
  docbook_xml_dtd_43,
  bashInteractive,
  lib
}:

let
  pythonWithGobject = python3Packages.python.withPackages (p: with p; [
    pygobject3
  ]);
in
stdenv.mkDerivation rec {
  pname = "cockpit-podman";
  version = "93";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = "cockpit-podman";
    rev = "refs/tags/${version}";
    hash = "sha256-1SpSzC5wOsv4Ha0ShtuyPsKLm0fVuPt8KFejJHFU8MY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    nodejs
    makeWrapper
    gettext
    (lib.getDev glib)
    systemd
    json-glib
    pkg-config
    autoreconfHook
    gnutls
    systemd
    json-glib
    pkg-config
    autoreconfHook
    krb5
    polkit
    libssh
    pam
    libxcrypt
    (lib.getBin libxslt)
    xmlto
    pythonWithGobject.python
    python3Packages.setuptools
    docbook_xsl
    docbook_xml_dtd_43
  ];

  postPatch = ''
    # Instead of requiring Internet access to do an npm install to generate the package-lock.json
    # it copies the package-lock.json already present in the node_modules folder fetched as a git
    # submodule.
    echo "#!/bin/sh" > test/node_modules

    substituteInPlace src/tls/cockpit-certificate-helper.in \
      --replace 'COCKPIT_CONFIG="@sysconfdir@/cockpit"' 'COCKPIT_CONFIG=/etc/cockpit'

    substituteInPlace src/tls/cockpit-certificate-ensure.c \
      --replace '#define COCKPIT_SELFSIGNED_PATH      PACKAGE_SYSCONF_DIR COCKPIT_SELFSIGNED_FILENAME' '#define COCKPIT_SELFSIGNED_PATH      "/etc" COCKPIT_SELFSIGNED_FILENAME'

    substituteInPlace src/common/cockpitconf.c \
      --replace 'const char *cockpit_config_dirs[] = { PACKAGE_SYSCONF_DIR' 'const char *cockpit_config_dirs[] = { "/etc"'

    # instruct users with problems to create a nixpkgs issue instead of nagging upstream directly
    substituteInPlace configure.ac \
      --replace 'devel@lists.cockpit-project.org' 'https://github.com/NixOS/nixpkgs/issues/new?assignees=&labels=0.kind%3A+bug&template=bug_report.md&title=cockpit%25'

    patchShebangs \
      build.js \
      test/common/pixel-tests \
      test/common/run-tests \
      test/common/tap-cdp \
      test/static-code \
      tools/escape-to-c \
      tools/make-compile-commands \
      tools/node-modules \
      tools/termschutz \
      tools/webpack-make.js

    for f in node_modules/.bin/*; do
      patchShebangs $(realpath $f)
    done

    export HOME=$(mktemp -d)

    cp node_modules/.package-lock.json package-lock.json

    for f in pkg/**/*.js pkg/**/*.jsx test/**/* src/**/*; do
      # some files substituteInPlace report as missing and it's safe to ignore them
      substituteInPlace "$(realpath "$f")" \
        --replace '"/usr/bin/' '"' \
        --replace '"/bin/' '"' || true
    done

    substituteInPlace src/common/Makefile-common.am \
      --replace 'TEST_PROGRAM += test-pipe' "" # skip test-pipe because it hangs the build

    substituteInPlace test/pytest/*.py \
      --replace "'bash" "'${bashInteractive}/bin/bash"

    echo "m4_define(VERSION_NUMBER, [${version}])" > version.m4
  '';

  configureFlags = [
    "--enable-prefix-only=yes"
    "--disable-pcp" # TODO: figure out how to package its dependency
    "--with-default-session-path=/run/wrappers/bin:/run/current-system/sw/bin"
    "--with-admin-group=root" # TODO: really? Maybe "wheel"?
    "--enable-old-bridge=yes"
  ];

  enableParallelBuilding = true;

  preBuild = ''
    patchShebangs \
      tools/test-driver
  '';
}
