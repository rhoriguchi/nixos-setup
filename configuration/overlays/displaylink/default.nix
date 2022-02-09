{ displaylink, evdi, lib }:
displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "5.5.0-beta-59.118"; ./displaylink_5.5.0-beta-59.118.zip; })
