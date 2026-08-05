// Azazel builds a consumer of mach's mpsc (a std-only multi-producer/
// single-consumer Queue + Pool), declared as a CUE model. Built on the
// mach-nominated Zig toolchain (0.17), which Azazel reaches via the "0.17" lane.
// Source staged by ./fetch.sh into vendor/ (git-ignored).
package build

toolchain: zig: {
	lanes: ["0.17"]
	preferred: "0.17"
}

mpsc: #Module & {
	kind: "module"
	root: "vendor/mpsc.zig"
}

consumer: #Module & {
	kind: "exe"
	root: "src/consumer.zig"
	deps: ["mpsc"]
}
