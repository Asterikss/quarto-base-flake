{
  description = "Reusable and extensible Quarto environment builder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Expose nixpkgs for child flakes to ensure consistent versioning
        nixpkgsFor = pkgs;

        lib = {
          # Function that can be used by other flakes to override Quarto's
          # extraPythonPackages
          mkQuartoEnv =
            {
              extraPythonPackages ? (ps: [ ]),
            }:
            pkgs.quarto.override {
              extraPythonPackages = ps: extraPythonPackages ps;
            };

          # Function that can be used by other flakes to override Quarto's python
          # interpreter and extraPythonPackages to allow overriding python with
          # additional packages that are not in nixpkgs
          mkQuartoCustomPython =
            {
              python ? pkgs.python3,
              extraPythonPackages ? (ps: [ ]),
            }:
            pkgs.quarto.override {
              python3 = python;
              extraPythonPackages = extraPythonPackages;
            };
        };
      }
    );
}
