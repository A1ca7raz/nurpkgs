check:
	nix flake check --no-build --no-allow-import-from-derivation --show-trace

update:
	nix flake update

bump:
	git add flake.lock
	git commit -m "lock: bump on `date +'%Y%m%d'`"
