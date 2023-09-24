{ displaylink, ... }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.8.0-63.33"; ./displaylink_5.8.0-63.33.zip; })
