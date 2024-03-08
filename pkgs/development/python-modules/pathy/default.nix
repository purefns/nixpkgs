{ lib
, buildPythonPackage
, fetchPypi
, fetchpatch
, google-cloud-storage
, mock
, pytestCheckHook
, pythonOlder
, smart-open
, typer
}:

buildPythonPackage rec {
  pname = "pathy";
  version = "0.11.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uz0OawuL92709jxxkeluCvLtZcj9tfoXSI+ch55jcG0=";
  };

  propagatedBuildInputs = [
    google-cloud-storage
    smart-open
    typer
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  disabledTestPaths = [
    # Exclude tests that require provider credentials
    "pathy/_tests/test_clients.py"
    "pathy/_tests/test_gcs.py"
    "pathy/_tests/test_s3.py"
  ];

  pythonImportsCheck = [
    "pathy"
  ];

  meta = with lib; {
    description = "A Path interface for local and cloud bucket storage";
    homepage = "https://github.com/justindujardin/pathy";
    license = licenses.asl20;
    maintainers = with maintainers; [ melling ];
  };
}
