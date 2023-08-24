#!/usr/bin/env bash

# Variables
arch=${ARCH:-x86_64-linux}

# Functions
build() {
  echo -e " \e[32m======>> $2\e[0m"
  if nix build .#packageBundles.${arch}.${1}.${2} --impure -v; then
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
  pkglist=($(nix eval .#packageBundles.${arch}.${grp} --apply "builtins.attrNames" --impure | sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/ /\n/g'))
  for pkg in ${pkglist[*]}; do
    build $grp $pkg
  done
done

[[ $fail ]] && true || false