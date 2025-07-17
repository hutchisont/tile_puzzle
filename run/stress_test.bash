#!/usr/bin/env bash

run_dir="$(git rev-parse --show-toplevel)/run"
source "${run_dir}/vars.bash"

mkdir -p "${out_dir:?}/"

odin test "${src_dir}" "${default_build_flags[@]}" --all-packages -keep-executable "$@" || exit 1

for i in {0..10000}
do
	echo "Running $i"
	"${out_dir}/${exe_name}" &>> "${out_dir}/stress_test.txt" || exit 1
done
