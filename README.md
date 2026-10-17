# lib-math-c

Native-backed implementation of the `math` ports (each arrow binds the
contract signature to the host `math.*` op).

Part of the `handl-lang` org split (ADR-0128); formerly the `math-c` repo.
History is a `git subtree split` of `platform/handl-packages/math-c/`.

## Layout

```text
src/        the .hnl sources
pkg.hnl     dependencies: `{ deps: { math: "branch:main" } }`
```

`math` is the contract package (`lib-math`), which is why this repo has the
back-edge dependency `math-c -> math`.

## Gate

```bash
HNL=../cli/target/debug/hnl scripts/hnl-gate.sh
```
