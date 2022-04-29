{ pkgs, ... }:
let
  modDrv = { src, name }:
    pkgs.stdenv.mkDerivation {
      inherit src name;

      deps = [ ];

      preferLocalBuild = true;
      buildCommand = ''
        mkdir -p $out
        cp $src "$out/${name}.zip"
      '';
    };

  aai-vehicles-chaingunner = modDrv {
    name = "aai-vehicles-chaingunner_0.6.1";
    src = ./aai-vehicles-chaingunner_0.6.1.zip;
  };

  air-filtering = modDrv {
    name = "air-filtering_0.8.3";
    src = ./air-filtering_0.8.3.zip;
  };

  angelsaddons-storage = modDrv {
    name = "angelsaddons-storage_0.0.8";
    src = ./angelsaddons-storage_0.0.8.zip;
  };

  angelsinfiniteores = modDrv {
    name = "angelsinfiniteores_0.9.10";
    src = ./angelsinfiniteores_0.9.10.zip;
  };

  better-trainHorn = modDrv {
    name = "Better-TrainHorn_1.0.2";
    src = ./Better-TrainHorn_1.0.2.zip;
  };

  clock = modDrv {
    name = "clock_1.1.0";
    src = ./clock_1.1.0.zip;
  };

  explosive-excavation = modDrv {
    name = "Explosive Excavation_1.1.8";
    src = ./Explosive-Excavation_1.1.8.zip;
  };

  factorissimo2 = modDrv {
    name = "Factorissimo2_2.5.3";
    src = ./Factorissimo2_2.5.3.zip;
  };

  girlCharacter = modDrv {
    name = "GirlCharacter_1.0.6";
    src = ./GirlCharacter_1.0.6.zip;
  };

  helmod = modDrv {
    name = "helmod_0.12.9";
    src = ./helmod_0.12.9.zip;
  };

  miniloader = modDrv {
    name = "miniloader_1.15.6";
    src = ./miniloader_1.15.6.zip;
  };

  power-armor-mk3 = modDrv {
    name = "Power Armor MK3_0.4.1";
    src = ./Power-Armor-MK3_0.4.1.zip;
  };

  qol_research = modDrv {
    name = "qol_research_3.3.0";
    src = ./qol_research_3.3.0.zip;
  };

  squeak-Through = modDrv {
    name = "Squeak Through_1.8.2";
    src = ./Squeak-Through_1.8.2.zip;
  };

  traintunnels = modDrv {
    name = "traintunnels_0.0.11";
    src = ./traintunnels_0.0.11.zip;
  };

  tree_collision = modDrv {
    name = "tree_collision_1.1.0";
    src = ./tree_collision_1.1.0.zip;
  };

  ultimateBelts = modDrv {
    name = "UltimateBelts_1.1.0";
    src = ./UltimateBelts_1.1.0.zip;
  };
in {
  services.factorio.mods = [
    aai-vehicles-chaingunner
    air-filtering
    angelsaddons-storage
    angelsinfiniteores
    better-trainHorn
    clock
    explosive-excavation
    factorissimo2
    girlCharacter
    helmod
    miniloader
    power-armor-mk3
    qol_research
    squeak-Through
    traintunnels
    tree_collision
    ultimateBelts
  ];
}
