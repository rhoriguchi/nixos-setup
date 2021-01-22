{ displaylink, evdi, lib }:

displaylink.overrideAttrs (oldAttrs: {
  src = assert lib.versions.majorMinor oldAttrs.version == "5.3";
    assert lib.versions.patch oldAttrs.version == "1";
    ./displaylink_5.3.1.zip;
})
