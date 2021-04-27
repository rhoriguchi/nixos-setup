{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: {
  # TODO check with derivation hash
  src = assert lib.versions.majorMinor oldAttrs.version == "5.4";
    assert lib.versions.patch oldAttrs.version == "0";
    ./displaylink_5.4.0.zip;
})
