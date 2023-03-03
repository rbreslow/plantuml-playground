{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # Iterate through each architecture supported by Nixpkgs and Hydra (e.g.,
    # ARM/x86 Linux and macOS).
    # https://github.com/numtide/flake-utils/blob/master/default.nix#L2-L8
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = nixpkgs.lib;
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            plantuml
          ];

          # We need to help the VSCode extension find PlantUML from our
          # development shell.
          shellHook = 
            let
              vscodeSettings = pkgs.writeText "settings.json" (builtins.toJSON {
                "plantuml.java" = "${pkgs.jre}/bin/java";
                "plantuml.jar" = "${pkgs.plantuml}/lib/plantuml.jar";
                "plantuml.commandArgs" = [
                  "-DGRAPHVIZ_DOT=${pkgs.graphviz}/bin/dot"
                ];
              });
            in ''
              echo "${vscodeSettings}" >./.vscode/settings.json
            '';
        };
      }
    );
}
