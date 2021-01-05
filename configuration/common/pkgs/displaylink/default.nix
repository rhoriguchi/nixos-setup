{ displaylink, evdi }:
displaylink.overrideAttrs (oldAttrs: {
  src = assert oldAttrs.version == "5.3.1.34"; ./displaylink_5.3.1.zip;
})
