{ ... }:
with builtins; {
  mapPackages = f: path:
    listToAttrs (map
      (name: { inherit name; value = f name; })
      (filter
        (v: v != null)
        (attrValues (mapAttrs
          (k: v: if v == "directory" && k != "_sources" then k else null)
          (readDir path)
        ))
      )
    );
}
