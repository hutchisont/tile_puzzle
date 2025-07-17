#!/usr/bin/env bash

run_dir="$(git rev-parse --show-toplevel)/run"
source "${run_dir}/vars.bash"

mkdir -p "${out_dir:?}/"

odin run "${src_dir}" "${default_build_flags[@]}" "$@"
