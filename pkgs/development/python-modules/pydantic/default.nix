{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder

# build-system
, hatchling
, hatch-fancy-pypi-readme

# native dependencies
, libxcrypt

# dependencies
, annotated-types
, pydantic-core
, typing-extensions

# tests
, cloudpickle
, email-validator
, dirty-equals
, faker
, pytestCheckHook
, pytest-mock
}:

buildPythonPackage rec {
  pname = "pydantic";
  version = "2.6.3";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    rev = "refs/tags/v${version}";
    hash = "sha256-neTdG/IcXopCmevzFY5/XDlhPHmOb6dhyAnzaobmeG8=";
  };

  buildInputs = lib.optionals (pythonOlder "3.9") [
    libxcrypt
  ];

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    annotated-types
    pydantic-core
    typing-extensions
  ];

  passthru.optional-dependencies = {
    email = [
      email-validator
    ];
  };

  nativeCheckInputs = [
    cloudpickle
    dirty-equals
    faker
    pytest-mock
    pytestCheckHook
  ] ++ lib.flatten (lib.attrValues passthru.optional-dependencies);

  preCheck = ''
    export HOME=$(mktemp -d)
    substituteInPlace pyproject.toml \
      --replace "'--benchmark-columns', 'min,mean,stddev,outliers,rounds,iterations'," "" \
      --replace "'--benchmark-group-by', 'group'," "" \
      --replace "'--benchmark-warmup', 'on'," "" \
      --replace "'--benchmark-disable'," ""
  '';

  disabledTestPaths = [
    "tests/benchmarks"

    # avoid cyclic dependency
    "tests/test_docs.py"
  ];

  pythonImportsCheck = [ "pydantic" ];

  meta = with lib; {
    description = "Data validation and settings management using Python type hinting";
    homepage = "https://github.com/pydantic/pydantic";
    changelog = "https://github.com/pydantic/pydantic/blob/v${version}/HISTORY.md";
    license = licenses.mit;
    maintainers = with maintainers; [ wd15 ];
  };
}
