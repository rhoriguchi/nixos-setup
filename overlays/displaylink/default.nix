{ displaylink, ... }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.7.0-61.129"; ./displaylink_5.7.0-61.129.zip; })
