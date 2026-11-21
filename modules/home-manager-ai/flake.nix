{
  description = "AI agent skill and plugin sources";

  inputs = {
    ponytail = {
      url = "github:DietrichGebert/ponytail?ref=v5.3.3";
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
        llm-agents = prev.llm-agents // {
          # TODO remove when viewer no longer hardcodes Asia/Shanghai
          open-code-review = prev.llm-agents.open-code-review.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace internal/viewer/server.go \
                --replace-fail "t.In(cstZone)" "t.Local()"
            '';
          });
        };

        skills = {
          ponytail = inputs.ponytail;

          skill-creator = prev.linkFarm "skill-creator" {
            skill-creator = "${inputs.skills}/skills/skill-creator";
          };
        };
      };
    };
}
