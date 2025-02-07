{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Archive Utilities
    atool # apack arepack als adiff atool aunpack acat
    gzip # gunzip zmore zegrep zfgrep zdiff zcmp uncompress gzip znew zless zcat zforce gzexe zgrep
    lz4 # lz4c lz4 unlz4 lz4cat
    lzip # lzip
    lzo # Real-time data (de)compression library
    lzop # lzop
    p7zip # 7zr 7z 7za
    rar # Utility for RAR archives
    rzip # rzip
    unzip # zipinfo unzipsfx zipgrep funzip unzip
    xz # lzfgrep lzgrep lzma xzegrep xz unlzma lzegrep lzmainfo lzcat xzcat xzfgrep xzdiff lzmore xzgrep xzdec lzdiff xzcmp lzmadec xzless xzmore unxz lzless lzcmp
    zip # zipsplit zipnote zip zipcloak
    zstd # zstd pzstd zstdcat zstdgrep zstdless unzstd zstdmt
  ];
}
