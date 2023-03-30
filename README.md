> **Important:** this project has been merged with [dynamic-continuation-orb](https://github.com/bjd2385/dynamic-continuation-orb), for which it was intended to be used.

# CircleCI config validation pre-commit hook

This CircleCI config validation [pre-commit](https://github.com/pre-commit/pre-commit) hook is intended to be used in conjunction with the [`dynamic-continuation`](https://github.com/bjd2385/dynamic-continuation-orb) orb (although this is not required). It extends the usual `circleci config validate` step by further validating every config you define under `.circleci/`, which dynamic-continuation would normally merge and submit from a setup workflow.

```yaml
repos:
...
- repo: https://github.com/bjd2385/circleci-config-pre-commit-hook
    rev: v<latest version>
    hooks:
      - id: circleci-config-validate
```

## Prerequisites

You must have the [`circleci`](https://circleci.com/docs/2.0/local-cli/) CLI installed.
