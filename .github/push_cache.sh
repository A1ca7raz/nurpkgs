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

# Calc store
store_list=($(nix eval --raw .#packages.${arch} --apply "x: with builtins; let store_list=with x;[$*]; in foldl' (acc: y: acc+\" \"+y.outPath) '''' store_list"))

# Show package information
echo -en "\e[35m==>\e[0m Total \e[35m${#store_list[*]}\e[0m package"
[[ ${#store_list[*]} -gt 1 ]] && echo 's' || echo

[[ ${#store_list[*]} == 0 ]] && echo -e "\e[31mERROR:\e[0m No package or wrong packages given." && exit 1
echo '>>>>>>>>>> Package Store >>>>>>>>>>'
for i in ${store_list[*]}; do echo ${i}; done
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

# Start push
fail=1
for i in ${store_list[*]}; do
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
