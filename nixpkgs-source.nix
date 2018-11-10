{ nixpkgs ? import <nixpkgs> {} }:
let
  bootstrap = import <nixpkgs> { };
  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    # rev = "10b979ff213d7e63a6e072d0433a21687e311483";
    # sha256 = "0k6ksczp1r1qfs4ly5mqlc4xh25j1vzqjrgwpmj72ihyxn7r5j8x";
    rev = "4927a248b57efbebac03c1a21f904e281d0b95ed";
    sha256 = "005lkhpffnc368wgqs07p9g1rf7ndp00hprmfg026qcd4lf09ys0";
  };
in src
