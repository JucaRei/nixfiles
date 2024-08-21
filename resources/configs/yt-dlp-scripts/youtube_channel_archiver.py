from pathlib import Path
import os
import subprocess


def main():
    dirs = [dir for dir in Path.cwd().iterdir() if dir.is_dir()]

    for dir in dirs:
        os.chdir(dir)
        for file in os.listdir(dir):
            if file.endswith(".txt"):
                txt_file = file
                channel_name = file.split('.')[0]
                yt_dlp_download(txt_file, channel_name)

def yt_dlp_download(txt_file, channel_name):
    result = subprocess.run(
        ["yt-dlp",
        "-f",
        "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
        "-o", "%(upload_date)s - %(channel)s - %(id)s - %(title)s.%(ext)s",
        "--sponsorblock-mark", 'all',
        "--geo-bypass",
        "--sub-langs", 'all',
        "--embed-subs",
        "--embed-metadata",
        "--convert-subs", 'srt',
        "--download-archive", f"{txt_file}", f"https://www.youtube.com/{channel_name}/videos"
        ]
    )


if __name__ == "__main__":
    main()
