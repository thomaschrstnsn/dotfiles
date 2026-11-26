{ stdenv, swift }:

# NextMeeting.app: a windowless app that writes the current/next calendar
# event to ~/Library/Caches/sketchybar/next_meeting.tsv for sketchybar's
# meeting item. It is an .app (not a plain binary) because macOS only grants
# calendar access to bundles carrying a usage description.
#
# The calendar (TCC) grant is tied to the ad-hoc signature, so macOS asks
# again only when main.swift or Info.plist change.
stdenv.mkDerivation {
  pname = "next-meeting";
  version = "1";

  src = ./.;

  nativeBuildInputs = [ swift ];

  buildPhase = ''
    runHook preBuild
    swiftc -O main.swift -o NextMeeting
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    app=$out/Applications/NextMeeting.app
    mkdir -p $app/Contents/MacOS
    cp Info.plist $app/Contents/Info.plist
    cp NextMeeting $app/Contents/MacOS/NextMeeting
    runHook postInstall
  '';

  # Sign after fixup: strip and the rpath fixes would invalidate an earlier
  # signature. The system codesign seals the whole bundle (binds Info.plist),
  # which sigtool cannot; this needs the nix sandbox off (the default on
  # Determinate Nix for macOS).
  dontStrip = true;
  postFixup = ''
    /usr/bin/codesign --force --sign - --identifier local.sketchybar.nextmeeting \
      $out/Applications/NextMeeting.app
  '';
}
