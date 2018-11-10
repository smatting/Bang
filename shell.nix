{ nixpkgs ?
    import
      (import ./nixpkgs-source.nix {})
      {config = {allowUnfree = true;};}
}:

with nixpkgs;

let
  # mkFun generate a package selection function (ps: [base ..]) from a package.yaml
  mkFun = fn:
    let
      packageYAML = writeTextFile { name = "package.yaml"; text = builtins.readFile fn; };
      packageJSON = runCommand "package.json" { yq = pkgs.yq; } "$yq/bin/yq . ${packageYAML} > $out";
      package = builtins.fromJSON (builtins.readFile packageJSON);
      text = "ps: with ps; [" + lib.concatStringsSep " " package.dependencies + "]";
      defaultNix = pkgs.writeTextFile { name = "default.nix"; text = text; };
      fun = import defaultNix;
    in fun;

  haskellOverrides = self: super: {
    hmidi = with super; super.callPackage
      ({ mkDerivation, base, stm, CoreAudio, CoreMIDI }:
       mkDerivation {
         pname = "hmidi";
         version = "0.2.2.1";
         sha256 = "15sf5jxr8nzbmn78bx971jic0ia51s8mrzdik2iqbgznairr30ay";
         libraryHaskellDepends = [ base stm ];
         librarySystemDepends = [CoreAudio CoreMIDI];
         description = "Binding to the OS level MIDI services";
         license = stdenv.lib.licenses.bsd3;
       }) { CoreAudio = darwin.apple_sdk.frameworks.CoreAudio; CoreMIDI = darwin.apple_sdk.frameworks.CoreMIDI; };
  };

  haskellPackages =
      pkgs.haskellPackages.override {
        overrides = haskellOverrides;
      };

  # ghc = pkgs.haskell.packages.ghc822.ghcWithHoogle (mkFun ./package.yaml);
  ghc = haskellPackages.ghcWithHoogle (mkFun ./package.yaml);

  # "hmidi" = callPackage
  #   ({ mkDerivation, base, stm }:
  #    mkDerivation {
  #      pname = "hmidi";
  #      version = "0.2.2.1";
  #      sha256 = "15sf5jxr8nzbmn78bx971jic0ia51s8mrzdik2iqbgznairr30ay";
  #      libraryHaskellDepends = [ base stm ];
  #      description = "Binding to the OS level MIDI services";
  #      license = stdenv.lib.licenses.bsd3;
  #    }) {};


in

pkgs.stdenv.mkDerivation {
  name = "my-haskell-package";
  buildInputs = [ ghc ];
  shellHook = "eval $(egrep ^export ${ghc}/bin/ghc)";
}
