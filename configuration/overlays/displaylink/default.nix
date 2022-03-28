{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.5.0-59.151"; ./displaylink_5.5.0-59.151.zip; })
