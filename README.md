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

| Build | What it does | Config size |
|-------|--------------|-------------|
| azazel | imports the mpsc module + a consumer, declared as CUE data on the 0.17 lane | `project.cue`, 14 lines |
| zaza | imports the mpsc module via the standard Zig build graph | `build.zig`,       29 lines |

mach's own `build.zig` hard-pins a single Zig nightly; both builds here compile
the file directly and stay on the mach toolchain.
