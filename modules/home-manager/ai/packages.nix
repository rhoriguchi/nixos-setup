{ pkgs }:
{
  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "v4.10.3";
    hash = "sha256-aypYnQf+zkKGj+dfs+qFKTFIvaick9p0XJNtPkSwIB0=";
  };

  skill-creator =
    let
      anthropicSkills = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "skills";
        rev = "53048666b05b4799081517d00e09e0a2dd688678";
        hash = "sha256-xaxkXFpzH4s2OIOcZqPy+HzfRAy2HbKpagjMhY+uinA=";
      };
    in
    pkgs.linkFarm "skill-creator" {
      skill-creator = "${anthropicSkills}/skills/skill-creator";
    };
}
