{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: {
  # TODO remove old zip when updated to 5.4.1
  src = assert oldAttrs.version == "5.4.0-55.153"; ./displaylink_5.4.0-55.153.zip;
})
