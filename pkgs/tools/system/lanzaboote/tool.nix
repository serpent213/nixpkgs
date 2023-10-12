{ systemd
, makeWrapper
, binutils-unwrapped
, sbsigntool
, rustPlatform
, fetchFromGitHub
, lib
}:
rustPlatform.buildRustPackage rec {
  pname = "lanzaboote_tool";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "lanzaboote";
    rev = "v${version}";
    hash = "sha256-Fb5TeRTdvUlo/5Yi2d+FC8a6KoRLk2h1VE0/peMhWPs=";
  };

  sourceRoot = "source/rust/tool";
  cargoHash = "sha256-ebaLnq2takCEvbHVqkI73FVTwjn1u80nnuy+GzVnROA=";

  env.TEST_SYSTEMD = systemd;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    # Clean PATH to only contain what we need to do objcopy.
    # This is still an unwrapped lanzaboote tool lacking of the
    # UEFI stub location.
    mv $out/bin/lzbt $out/bin/lzbt-unwrapped
    makeWrapper $out/bin/lzbt-unwrapped $out/bin/lzbt \
      --set PATH ${lib.makeBinPath [ binutils-unwrapped sbsigntool ]}
  '';

  nativeCheckInputs = [
    binutils-unwrapped
    sbsigntool
  ];

  meta = with lib; {
    description = "Lanzaboote UEFI tooling for SecureBoot enablement on NixOS systems";
    homepage = "https://github.com/nix-community/lanzaboote";
    license = licenses.gpl3Only;
    mainProgram = "lzbt";
    maintainers = with maintainers; [ raitobezarius nikstur ];
  };
}
