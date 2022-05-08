## CircleCI config validation pre-commit hook

This CircleCI config validation [pre-commit](https://github.com/pre-commit/pre-commit) hook is intended to be used in conjunction with the [`dynamic-continuation`](https://github.com/bjd2385/dynamic-continuation-orb) orb (although this is not required). It extends the usual `circleci config validate` step by further validating a reduced config, excluding the default config, which dynamic-continuation would normally submit from a setup workflow.

### Prerequisites

You must have the [`circleci`](https://circleci.com/docs/2.0/local-cli/) CLI installed, as well as [`yq`](https://github.com/mikefarah/yq#install), which is used to reduce the config files.

#### Example `.pre-commit-config.yaml`

```yaml
repos:
...
- repo: https://github.com/bjd2385/circleci-config-pre-commit-hook
    rev: v1.0.3
    hooks:
      - id: circleci-config-validate
```
