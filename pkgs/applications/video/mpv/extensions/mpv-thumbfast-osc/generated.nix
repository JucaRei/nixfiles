# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  mpv-thumbfast-osc = {
    pname = "mpv-thumbfast-osc";
    version = "04819fc9ce49b67dfc2bac71c26e037bcb57b9d4";
    src = fetchFromGitHub {
      owner = "po5";
      repo = "thumbfast";
      rev = "04819fc9ce49b67dfc2bac71c26e037bcb57b9d4";
      fetchSubmodules = false;
      sha256 = "sha256-YLI8cCOSF1YacTOOGZxT7mfP68OhhyGm6JzVFXNsxtw=";
    };
    date = "2023-11-28";
  };
}
