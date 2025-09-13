# Modified from https://github.com/NixOS/nixpkgs/pull/208866
{
  appstream,
  biome,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitHub,
  gjs,
  glib,
  gobject-introspection,
  gtk-css-lsp,
  gtksourceview5,
  lib,
  libadwaita,
  libportal-gtk4,
  libshumate,
  meson,
  ninja,
  pkg-config,
  python312Packages,
  rustc,
  stdenv,
  vala,
  vte-gtk4,
  webkitgtk_6_0,
  wrapGAppsHook4,
}: stdenv.mkDerivation {
  pname = "workbench";
  version = "48.0-dev";

  src = fetchFromGitHub {
    owner = "workbenchdev";
    repo = "Workbench";
    rev = "730729b";
    hash = "sha256-jFyetgcSfDKsJ941ynndFAFYBDzLyu7ym8i3hchRLA0=";
    fetchSubmodules = true;
  };

  patches = [
    ./patches/appstream_version.patch # Modified to become last commit date
    ./patches/de-flatpak-ify.patch
    ./patches/demo-compat.patch
    ./patches/previewer-fix.patch
    ./patches/source-perms.patch
  ];

  postPatch = ''
    substituteInPlace src/meson.build --replace-fail "/app/bin/blueprint-compiler" "blueprint-compiler"
    substituteInPlace troll/gjspack/bin/gjspack \
      --replace-fail "#!/usr/bin/env -S gjs -m" "#!${gjs}/bin/gjs -m"
    substituteInPlace build-aux/library.js \
      --replace-fail "#!/usr/bin/env -S gjs -m" "#!${gjs}/bin/gjs -m"
  '';

  preFixup = ''
    # https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
    sed -e '2iimports.package._findEffectiveEntryPointName = () => "re.sonny.Workbench"' \
      -i $out/bin/re.sonny.Workbench
    gappsWrapperArgs+=(
      --prefix PATH : $out/bin
      --prefix PATH : "${lib.makeBinPath [biome blueprint-compiler glib gtk-css-lsp python312Packages.python-lsp-server]}"
    )
  '';

  dontPatchShebangs = true;

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    rustc
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    gtksourceview5
    libadwaita
    libportal-gtk4
    libshumate
    vte-gtk4
    webkitgtk_6_0
  ];

  doCheck = true;

  meta = with lib; {
    description = "Learn and prototype with GNOME technologies";
    homepage = "https://github.com/sonnyp/Workbench";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
  };
}
