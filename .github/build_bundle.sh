#!/usr/bin/env bash

# Variables
arch=${ARCH:-x86_64-linux}
[[ $CI_MODE ]] && dryrun="" || dryrun=echo

# Functions
build_grp() {
  echo -e " \e[32m======>> $2\e[0m"
  if $dryrun nix build .#packageBundles.${arch}.${1}.${2} --impure -v; then
    echo -en " \e[32m"
  else
    echo -en " \e[31m" && fail=
  fi
  echo -e "<<======\e[0m"
}

build_pkg() {
  echo -e " \e[32m======>> $1\e[0m"
  if $dryrun nix build .#packageBundles.${arch}.${1} --impure -v; then
    echo -en " \e[32m"
  else
    echo -en " \e[31m" && fail=
  fi
  echo -e "<<======\e[0m"
}

groups=($GROUP_NAMES)
fail=1
for grp in ${groups[*]}; do
  echo -e "\e[33m==> $grp\e[0m"
  # if it is a nix package
  if [[ $(nix eval --raw .#packageBundles.${arch}.${grp}.type --impure 2> /dev/null) = "derivation" ]]; then
    build_pkg $grp
  else
    pkglist=($(nix eval .#packageBundles.${arch}.${grp} --apply "builtins.attrNames" --impure | sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/ /\n/g'))
    for pkg in ${pkglist[*]}; do
      build_grp $grp $pkg
    done
  fi
done

[[ $fail ]] && true || false