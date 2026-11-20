# lib-math-c

Native-backed implementation of the `math` ports (each arrow binds the
contract signature to the host `math.*` op).

## Layout

```text
src/        the .hnl sources
pkg.hnl     package manifest — modules, deps, description, license
```

`math` is the contract package (`lib-math`), which is why this repo has the
back-edge dependency `math-c -> math`.

## Gate

```bash
HNL=../host-cli/target/debug/hnl scripts/hnl-gate.sh
```

## License

MIT.
