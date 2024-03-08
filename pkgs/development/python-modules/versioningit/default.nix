{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, importlib-metadata
, packaging
, setuptools
, tomli
, pytestCheckHook
, build
, hatchling
, pydantic
, pytest-mock
, git
, mercurial
}:

buildPythonPackage rec {
  pname = "versioningit";
  version = "3.0.0";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TjzkemQk2FCunlXhsTSgIOn8vLiVM48QfytcUdNMnBs=";
  };

  postPatch = ''
    substituteInPlace tox.ini \
      --replace "--cov=versioningit" "" \
      --replace "--cov-config=tox.ini" "" \
      --replace "--no-cov-on-fail" ""
  '';

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    packaging
  ] ++ lib.optionals (pythonOlder "3.10") [
    importlib-metadata
  ] ++ lib.optionals (pythonOlder "3.11") [
    tomli
  ];

  nativeCheckInputs = [
    pytestCheckHook
    build
    hatchling
    pydantic
    pytest-mock
    git
    mercurial
  ];

  disabledTests = [
    # wants to write to the Nix store
    "test_editable_mode"
  ];

  pythonImportsCheck = [
    "versioningit"
  ];

  meta = with lib; {
    description = "setuptools plugin for determining package version from VCS";
    homepage = "https://github.com/jwodder/versioningit";
    changelog = "https://versioningit.readthedocs.io/en/latest/changelog.html";
    license     = licenses.mit;
    maintainers = with maintainers; [ DeeUnderscore ];
  };
}
