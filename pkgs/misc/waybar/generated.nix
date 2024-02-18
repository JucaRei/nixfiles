{fetchgit}:{
  waybar = {
    pname = "waybar";
    version = "3cd311819be3af40f3aaec76917018a93d18c70f";
    src = fetchgit {
      url = "https://github.com/alexays/waybar";
      rev = "3cd311819be3af40f3aaec76917018a93d18c70f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Ig/w7deBZpC3UkkHqUTt0loaKIy+mPdAZ6+hoa7lozY=";
    };
    date = "2024-02-16";
  };
}
