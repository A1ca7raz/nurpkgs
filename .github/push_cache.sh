#!/usr/bin/env bash

extra_args=${ATTIC_PUSH_ARGS:--j8}
cache=${ATTIC_CACHE:-test}
retry_times=${ATTIC_PUSH_RETRY:-5}
[[ $CI_MODE ]] && dryrun_cmd="" || dryrun_cmd=echo

push_with_retry() {
  for n in $(seq 1 ${retry_times}); do
    $dryrun_cmd attic push ${extra_args} ${cache} $1 && return 0
  done
  false
}

[[ $* ]] && pkgs_need_build=$* || pkgs_need_build=
[[ $pkgs_need_build ]] && filter_expr="{ inherit (x) $pkgs_need_build; }" || filter_expr="x"
apply_expr="x: with builtins; let pkglist = ${filter_expr}; in map (x: x.outPath) (attrValues pkglist)"
pkglist=($(nix eval .#checks.x86_64-linux --apply "$apply_expr" --impure | sed -e 's/"//g' -e 's/ /\n/g' | sed -e '1d' -e '$d'))

echo -en "\e[35m==>\e[0m Total ${#pkglist[*]} package"
[[ ${#pkglist[*]} -gt 1 ]] && echo 's' || echo
[[ ${#pkglist[*]} == 0 ]] && echo -e "\e[31mERROR:\e[0m No package or wrong packages given." && exit 1
echo '>>>>>>>>>> Package Store >>>>>>>>>>'
for i in ${pkglist[*]}; do echo ${i}; done
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

build_fail=1
for i in ${pkglist[*]}; do
  echo
  echo -e " \e[32m=====>> $i\e[0m"
  if push_with_retry $i; then
    echo -en " \e[32m"
  else
    echo -en " \e[31m"; build_fail=;
  fi
  echo -e "<<=====\e[0m"
done

[[ $build_fail ]] && true || false
