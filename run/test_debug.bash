#!/usr/bin/env bash

run_dir="$(git rev-parse --show-toplevel)/run"
source "${run_dir}/vars.bash"

mkdir -p "${out_dir:?}/"

odin test "${src_dir}" "${default_build_flags[@]}" --all-packages -debug -define:ODIN_TEST_LOG_LEVEL=debug "$@"
