#!/usr/bin/env bash

export root_dir=$(git rev-parse --show-toplevel)
export out_dir="${root_dir}/build"
export src_dir="${root_dir}/src"
export exe_name="tile_puzzle"
export default_build_flags=(
	-vet
	-strict-style
	-warnings-as-errors
	-o:size
	-microarch:native
	"-out:\"${out_dir}/${exe_name}\""
	-show-timings
)
