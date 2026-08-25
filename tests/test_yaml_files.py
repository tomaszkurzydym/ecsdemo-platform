"""Lint and hygiene checks applied to every YAML file in the repository."""

import io
from pathlib import Path

import pytest
import yaml
from yamllint import linter
from yamllint.config import YamlLintConfig

REPO_ROOT = Path(__file__).resolve().parent.parent

YAML_FILES = sorted(
    path
    for path in REPO_ROOT.iterdir()
    if path.is_file() and path.suffix in {".yml", ".yaml"}
)

CONFIG = YamlLintConfig(file=str(REPO_ROOT / ".yamllint.yml"))

IDS = [path.name for path in YAML_FILES]


def test_expected_yaml_files_are_discovered():
    assert {"buildspec.yml", "mu.yml"} <= set(IDS)


@pytest.mark.parametrize("path", YAML_FILES, ids=IDS)
def test_yaml_file_is_a_single_parseable_document(path):
    with path.open(encoding="utf-8") as handle:
        documents = list(yaml.safe_load_all(handle))
    assert len(documents) == 1
    assert documents[0] is not None


@pytest.mark.parametrize("path", YAML_FILES, ids=IDS)
def test_yaml_file_passes_yamllint(path):
    content = path.read_text(encoding="utf-8")
    problems = [
        f"{path.name}:{problem.line}:{problem.column}: {problem.message}"
        for problem in linter.run(io.StringIO(content), CONFIG)
        if problem.level == "error"
    ]
    assert not problems, "\n".join(problems)


@pytest.mark.parametrize("path", YAML_FILES, ids=IDS)
def test_yaml_file_has_no_tabs(path):
    content = path.read_text(encoding="utf-8")
    assert "\t" not in content
