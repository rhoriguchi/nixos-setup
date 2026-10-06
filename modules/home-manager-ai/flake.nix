{
  description = "AI agent skill and plugin sources";

  inputs = {
    ponytail = {
      url = "github:DietrichGebert/ponytail?ref=v4.13.0";
      flake = false;
    };

    skills = {
      url = "github:anthropics/skills?rev=53048666b05b4799081517d00e09e0a2dd688678";
      flake = false;
    };
  };

  outputs =
    { ... }@inputs:
    {
      overlays.default = _: prev: {
        skills = {
          ponytail = inputs.ponytail;

          skill-creator = prev.linkFarm "skill-creator" {
            skill-creator = "${inputs.skills}/skills/skill-creator";
          };
        };
      };
    };
}
