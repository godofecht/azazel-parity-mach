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

