{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.4.1-55.174"; ./displaylink_5.4.1-55.174.zip; })
