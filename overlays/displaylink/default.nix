{ displaylink, ... }: displaylink.overrideAttrs (oldAttrs: { src = assert oldAttrs.version == "6.1.0-17"; ./displaylink_6.1.0-17.zip; })
