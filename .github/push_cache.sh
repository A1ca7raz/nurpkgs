#!/usr/bin/env bash

# Variables
cache=${CACHIX_CACHE:-test}
retry_times=${ATTIC_PUSH_RETRY:-10}
arch=${ARCH:-x86_64-linux}
[[ $CI_MODE ]] && dryrun="" || dryrun=echo

# Functions
push_with_retry() {
  for n in $(seq 1 ${retry_times}); do
    echo $1 | $dryrun cachix push ${cache}
    [[ $? == 0 ]] && return 0
  done
  false
}

# Parse opts
pkgs=()
groups=()
for i in $*; do
  if [[ $(nix eval --raw .#packageBundles.${arch}.${i}.type --impure 2> /dev/null) = "derivation" ]]; then
    pkgs+=(${i})
  else
    groups+=(${i})
  fi
done

# Calc store
pkglist=
if [[ $groups ]]; then
  filter_expr="{ inherit (x) ${groups[@]}; }"
  apply_expr="x: with builtins; let pkglist = ${filter_expr}; in map (x: map (y: y.outPath) (attrValues x)) (attrValues pkglist)"
  pkglist+=($(nix eval .#packageBundles.${arch} --apply "$apply_expr" --impure | sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/ /\n/g'))
fi

[[ $pkgs || $groups ]] && filter_expr="{ inherit (x) ${pkgs[@]}; }" || filter_expr="x"
apply_expr="x: with builtins; let pkglist = ${filter_expr}; in map (x: x.outPath) (attrValues pkglist)"
pkglist+=($(nix eval .#packages.${arch} --apply "$apply_expr" --impure | sed -e 's/"//g' -e 's/ /\n/g' | sed -e '1d' -e '$d'))

# Show package information
echo -en "\e[35m==>\e[0m Total \e[35m${#pkglist[*]}\e[0m package"
[[ ${#pkglist[*]} -gt 1 ]] && echo 's' || echo

[[ ${#pkglist[*]} == 0 ]] && echo -e "\e[31mERROR:\e[0m No package or wrong packages given." && exit 1
echo '>>>>>>>>>> Package Store >>>>>>>>>>'
for i in ${pkglist[*]}; do echo ${i}; done
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

# Start push
fail=1
for i in ${pkglist[*]}; do
  echo
  echo -e " \e[32m=====>> $i\e[0m"
  if push_with_retry $i; then
    echo -en " \e[32m"
  else
    echo -en " \e[31m"; fail=;
  fi
  echo -e "<<=====\e[0m"
done

[[ $fail ]] && true || false
