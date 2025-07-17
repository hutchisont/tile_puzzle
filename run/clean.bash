#!/usr/bin/env bash

run_dir="$(git rev-parse --show-toplevel)/run"
source "${run_dir}/vars.bash"

rm -rf "${out_dir:?}/"

