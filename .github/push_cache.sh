#!/usr/bin/env bash

extra_args=${ATTIC_PUSH_ARGS:--j8}
cache=${ATTIC_CACHE:-test}
retry_times=${ATTIC_PUSH_RETRY:-3}

push_with_retry() {
  for n in $(seq 1 ${retry_times}); do
    attic push ${extra_args} ${cache} $1 && return 0
  done
  false
}

[[ $1 ]] && pkglist=($1) || pkglist=($(nix eval .#checks.x86_64-linux --apply 'x: with builtins; map (x: x.outPath) (attrValues x)' --impure | sed -e 's/"//g' -e 's/ /\n/g' | sed -e '1d' -e '$d'))

echo '>>>>>>>>>> Package Store >>>>>>>>>>'
for i in ${pkglist[*]}; do echo ${i}; done
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

build_fail=1
for i in ${pkglist[*]}; do
  echo -e " \e[32m=====>> $i\e[0m"
  if push_with_retry $i; then
    echo -en " \e[32m"
  else
    echo -en " \e[31m"; build_fail=;
  fi
  echo -e "<<=====\e[0m"
done

[[ $build_fail ]] && true || false
