# Easy Media Compress

Use ffmpeg in a whole directory with different options for image, audio and video. This aims to compress many files using the best codecs for file size like HEVC, Opus, VP9...

## Script usage

```ps1
.\directory-ffmpeg.ps1 [-inputpath] <String> [-outputpath] <String> [[-c_v] <String>] [[-c_a] <String>]
    [[-hwaccel] <String>] [[-b_v] <String>] [[-b_a] <String>] [[-ar] <String>] [[-ffmpegpath] <String>] [[-outputformatvideo] <String>]
    [[-outputformatimage] <String>] [[-outputformataudio] <String>] [<CommonParameters>]
```

It runs the ffmpeg command for each file in batch mode.
