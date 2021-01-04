{ displaylink, evdi }:
displaylink.overrideAttrs (oldAttrs: {
  # TODO Add ascertain to make sure that version is 5.3.1.34
  src = ./displaylink_5.3.1.zip;
})
