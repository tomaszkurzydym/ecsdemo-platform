"""Schema checks for mu.yml, which defines the ECS environments for the demo."""

TOP_LEVEL_KEYS = {
    "namespace",
    "environments",
    "service",
    "templates",
    "extensions",
    "parameters",
    "basedir",
    "repo",
    "disableIAM",
    "roles",
}

ENVIRONMENT_KEYS = {
    "name",
    "provider",
    "loadbalancer",
    "cluster",
    "discovery",
    "vpcTarget",
    "roles",
}

SUPPORTED_PROVIDERS = {"ecs", "ecs-fargate", "eks", "eks-fargate", "ec2"}

REQUIRED_ENVIRONMENTS = {"acceptance", "production"}


def test_mu_config_is_a_mapping(mu_config):
    assert isinstance(mu_config, dict)


def test_only_known_top_level_keys(mu_config):
    assert set(mu_config) <= TOP_LEVEL_KEYS


def test_environments_is_a_non_empty_list(mu_config):
    environments = mu_config["environments"]
    assert isinstance(environments, list) and environments


def test_each_environment_has_a_name_and_provider(mu_config):
    for environment in mu_config["environments"]:
        assert isinstance(environment, dict)
        assert set(environment) <= ENVIRONMENT_KEYS
        assert isinstance(environment["name"], str)
        assert environment["name"].strip()
        assert environment["provider"] in SUPPORTED_PROVIDERS


def test_environment_names_are_unique(mu_config):
    names = [environment["name"] for environment in mu_config["environments"]]
    assert len(names) == len(set(names))


def test_workshop_environments_are_defined(mu_config):
    # test/up.sh and test/down.sh drive `mu env up/term` for both of these.
    names = {environment["name"] for environment in mu_config["environments"]}
    assert REQUIRED_ENVIRONMENTS <= names
