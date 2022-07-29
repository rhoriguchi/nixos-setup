{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.6.0-59.176"; ./displaylink_5.6.0-59.176.zip; })
