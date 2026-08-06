# azazel-parity-mach

[mach](https://github.com/hexops/mach)'s `mpsc` — a std-only
multi-producer/single-consumer Queue + Pool — built two ways, to prove and
compare [azazel](https://github.com/godofecht/azazel) and
[zaza](https://github.com/godofecht/zaza).

mach targets a nominated Zig nightly. Both builds use `0.17.0-dev.892`
(mach-latest); azazel reaches it through its `"0.17"` lane. Both compile a
consumer that instantiates the `Pool` and `Queue` generics at comptime, which
forces the datastructure to compile without a `std.Io` event loop.

Neither vendors mach's source; each stages the single `mpsc.zig` file at a
pinned commit with its own `fetch.sh` (a `curl`, no clone of mach's large tree).

## Pinned upstream

| | |
|---|---|
| Repository | https://github.com/hexops/mach |
| Commit | `4be8e50fc89a532878887dba002f590cc50d8e89` |
| File | `src/mpsc.zig` |
| Zig | `0.17.0-dev.892+54537285c` (mach-latest) |

## Build it

```sh
cd azazel && ./fetch.sh && sh gen_build_spec.sh && zig build && ./zig-out/bin/consumer
cd zaza  && ./fetch.sh && zig build run
```

Both print `mach mpsc: Pool and Queue generics compiled`.

## Comparison

Clean-cache builds with dependencies pre-fetched, Apple Silicon, fastest of two runs.


| Build | Clean build | Config |
|-------|-------------|--------|
| azazel | 3.5 s | `project.cue` — 14 lines · 497 B |
| zaza | 3.2 s | `build.zig` — 29 lines · 954 B |

The upstream's full build is not reproduced here (see the note below), so no native time is listed.

**mach's own `build.zig` pins a single Zig nightly and rejects others, so its full build is not reproduced here; the mpsc slice builds in ~3 s either way.**


## Build process & what can be optimized

Both build roots stage the pinned upstream with `fetch.sh` into a git-ignored
`vendor/` (a `curl` for single-file slices, a shallow clone for source trees) —
no upstream sources are committed. Then:

- **azazel**: `sh gen_build_spec.sh` runs CUE and emits `build_spec.zig` (the
  build declared as data), then `zig build` compiles it. The CUE step is
  memoized — it re-runs only when the model changes (~0.20s → ~0.01s otherwise).
- **zaza**: `zig build` drives the standard Zig build graph directly.

### What actually makes it faster

Measured across the corpus (clean vs warm builds):

| Lever | Speedup | Note |
|-------|---------|------|
| Content-addressed cache (rebuild) | **89×** | 14.2s → 0.16s; Zig has it, both inherit it |
| Incremental (edit one file) | **10.8×** | 14.2s → 1.32s; deps stay cached |
| CI dependency cache | **2×** | cold 13.3s → warm 6.6s; this repo's CI caches `~/.cache/zig` |
| Memoized CUE codegen | **20×** | azazel's only overhead, gone |
| Parallelism (many cores) | **1.1×** | marginal — shared `std` + startup dominate |
| GPU | none | compilation is branchy, sequential, dependency-ordered |

The instinct to parallelize like a C++ build doesn't transfer: Zig is one
mostly-single-threaded compile per artifact with a fast self-hosted backend and a
shared `std` that caches. **For Zig, caching is the lever, not parallelism.**

The real frontier is *residency*: a resident compile server that keeps the
InternPool hot and recompiles only changed declarations, plus in-place binary
patching (Zig's roadmap) and a shared content-addressed cache. azazel's
build-as-data is positioned for it — the build is a query, and the cache key is
computable from the pinned model without running the compiler. Full write-up and
the cross-repo comparison: the [corpus dashboard](https://claude.ai/code/artifact/8c37ee83-b358-4351-a1e0-eb02ec0aedd4).
