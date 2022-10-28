{ displaylink, ... }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.6.1-59.184"; ./displaylink_5.6.1-59.184.zip; })
