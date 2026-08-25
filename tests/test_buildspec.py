"""Schema checks for the CodeBuild buildspec consumed by the mu pipeline."""

import pytest

TOP_LEVEL_KEYS = {
    "version",
    "run-as",
    "env",
    "proxy",
    "batch",
    "phases",
    "reports",
    "artifacts",
    "cache",
}

PHASE_NAMES = {"install", "pre_build", "build", "post_build"}

SUPPORTED_VERSIONS = {"0.2"}


def test_buildspec_is_a_mapping(buildspec):
    assert isinstance(buildspec, dict)


def test_version_is_supported(buildspec):
    # CodeBuild parses `version` as a string; 0.1 semantics differ per-command.
    assert str(buildspec["version"]) in SUPPORTED_VERSIONS


def test_only_known_top_level_keys(buildspec):
    assert set(buildspec) <= TOP_LEVEL_KEYS


def test_phases_present_and_named_correctly(buildspec):
    phases = buildspec["phases"]
    assert isinstance(phases, dict)
    assert phases, "buildspec must declare at least one phase"
    assert set(phases) <= PHASE_NAMES


def test_build_phase_declared(buildspec):
    assert "build" in buildspec["phases"]


@pytest.mark.parametrize("phase_name", sorted(PHASE_NAMES))
def test_phase_commands_are_non_empty_strings(buildspec, phase_name):
    phase = buildspec["phases"].get(phase_name)
    if phase is None:
        pytest.skip(f"{phase_name} phase not declared")
    assert set(phase) <= {"commands", "finally", "run-as", "on-failure"}
    commands = phase["commands"]
    assert isinstance(commands, list) and commands
    for command in commands:
        assert isinstance(command, str)
        assert command.strip()


def test_artifacts_files_are_declared(buildspec):
    artifacts = buildspec["artifacts"]
    files = artifacts["files"]
    assert isinstance(files, list) and files
    for pattern in files:
        assert isinstance(pattern, str)
        assert pattern.strip()


def test_artifacts_include_whole_workspace(buildspec):
    # mu deploys the repo contents, so the pipeline needs every file forwarded.
    assert "**/*" in buildspec["artifacts"]["files"]
