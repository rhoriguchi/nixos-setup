{ displaylink, ... }: displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "6.0.0-24"; ./displaylink_6.0.0-24.zip; })
