{
  description = "AI agent skill and plugin sources";

  inputs = {
    ponytail = {
      url = "github:DietrichGebert/ponytail?ref=v5.3.2";
      flake = false;
    };

    skills = {
      url = "github:anthropics/skills";
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
