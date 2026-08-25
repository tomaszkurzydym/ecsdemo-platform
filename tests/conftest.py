from pathlib import Path

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent


def load_yaml(path):
    with path.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle)


@pytest.fixture(scope="session")
def repo_root():
    return REPO_ROOT


@pytest.fixture(scope="session")
def buildspec():
    return load_yaml(REPO_ROOT / "buildspec.yml")


@pytest.fixture(scope="session")
def mu_config():
    return load_yaml(REPO_ROOT / "mu.yml")
