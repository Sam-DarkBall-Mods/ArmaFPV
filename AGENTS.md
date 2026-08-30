# AGENTS

- Always write SQF for Arma 3.
- Use HPP/CPP only for Arma 3 configuration.
- Never use `breakOut` or `scopeName`.
- Preserve public `CfgPatches`, function names, PBO prefixes, and serialized
  state unless a task explicitly requires a breaking change.
- Validate changes with HEMTT and the repository tests.
