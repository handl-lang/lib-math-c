# math-c

Native-backed math implementations for Handl — the `-c` implementation
module of the `math` contract package. Each `handl-packages/math-c/<f>.hnl`
binds the contract signature from `math/<f>` to the host `math.*` op
(`export sqrt: Sqrt := (a) ~> math.sqrt(a)`).

Part of the `handl-lang` org split (ADR-0128). History is a
`git subtree split` of `platform/handl-packages/math-c/`.

## Dependencies

`.handl.toml` wires the package-name import seam:

- `math-c` — self-declared so `from "math-c/<f>"` resolves under this
  manifest's context.
- `math` — the contract package in `../platform/handl-packages/math`
  (sibling checkout of `handl-lang/platform`); `math-c` files import their
  arrow signatures (`Sqrt`, `Ceil`, …) by name from it.

The matching consumer wiring lives in `platform/.handl.toml`
(`math-c = { path = "../math-c/handl-packages/math-c" }`); the platform
`math` facade (`handl-packages/math/index.hnl`) re-exports these
implementations as `from "math-c/<f>"`.
