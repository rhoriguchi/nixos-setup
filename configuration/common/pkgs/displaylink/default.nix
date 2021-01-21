{ displaylink, evdi, stdenv }:

displaylink.overrideAttrs (oldAttrs: {
  src = assert stdenv.lib.versions.majorMinor oldAttrs.version == "5.3";
    assert stdenv.lib.versions.patch oldAttrs.version == "1";
    ./displaylink_5.3.1.zip;
})
