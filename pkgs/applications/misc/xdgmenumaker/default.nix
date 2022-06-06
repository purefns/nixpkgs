{ lib
, fetchFromGitHub
, glib
, gobject-introspection
, python3Packages
, txt2tags
, wrapGAppsHook
, gitUpdater
}:

python3Packages.buildPythonApplication rec {
  pname = "xdgmenumaker";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "gapan";
    repo = pname;
    rev = version;
    sha256 = "1vrsp5c1ah7p4dpwd6aqvinpwzd8crdimvyyr3lbm3c6cwpyjmif";
  };

  format = "other";

  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    txt2tags
    wrapGAppsHook
  ];

  buildInputs = [
    glib
  ];

  pythonPath = with python3Packages; [
    pygobject3
    pyxdg
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  installFlags = [
    "DESTDIR="
  ];

  passthru.updateScript = gitUpdater {inherit pname version; };

  meta = with lib; {
    description = "Command line tool that generates XDG menus for several window managers";
    homepage = "https://github.com/gapan/xdgmenumaker";
    license = licenses.gpl3Plus;
    # NOTE: exclude darwin from platforms because Travis reports hash mismatch
    platforms = with platforms; filter (x: !(elem x darwin)) unix;
    maintainers = [ maintainers.romildo ];
  };
}
