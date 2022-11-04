<#
.SYNOPSIS
FFMPEG directory wrapper
.DESCRIPTION
This script makes running Ffmpeg in batch mode easy
.PARAMETER inputpath
Path of input files directory
.PARAMETER OutputPath
Path of the output files directory
#>

param (
    [Parameter(
        Mandatory = $true
    )]
    [String]
    $inputpath = '.',
    [Parameter(
        Mandatory = $true
    )]
    [String]
    $outputpath = '.',
    [String]
    $c_v = 'libx265',
    [String]
    $c_a = 'libopus',
    [String]
    $hwaccel = 'vulkan',
    [String]
    $b_v = '1.5M',
    [String]
    $b_a = '128K',
    [String]
    $ar = '48000',
    [String]
    $ffmpegpath = 'ffmpeg',
    [String]
    $outputformatvideo,
    [String]
    $outputformatimage,
    [String]
    $outputformataudio
)

function Get-TargetFiles-Recursive() {
    Get-ChildItem -Recurse | Where-Object { $_.Extension -eq '.mp4' } | Select-Object -ExpandProperty FullName $inputpath
}

function Get-OutputFullFileNameVideo([Parameter(Mandatory = $true)] $filepath) {
    $format = $outputformatvideo
    if ($format.Length -eq 0) {
        $format = Get-ChildItem $filepath | Select-Object -ExpandProperty Extension
    }
    return "$outputpath\$(Get-ChildItem $filepath | Select-Object -ExpandProperty BaseName)$format"
}

function Get-OutputFullFileNameImage([Parameter(Mandatory = $true)] $filepath) {
    $format = $outputformatimage
    if ($format.Length -eq 0) {
        $format = Get-ChildItem $filepath | Select-Object -ExpandProperty Extension
    }
    return "$outputpath\$(Get-ChildItem $filepath | Select-Object -ExpandProperty BaseName)$format"
}

function Get-OutputFullFileNameAudio([Parameter(Mandatory = $true)] $filepath) {
    $format = $outputformataudio
    if ($format.Length -eq 0) {
        $format = Get-ChildItem $filepath | Select-Object -ExpandProperty Extension
    }
    return "$outputpath\$(Get-ChildItem $filepath | Select-Object -ExpandProperty BaseName)$format"
}

# Help command
if ($args[0] -eq 'Help') {
    Write-Host '###################'
}

# Checking parameters are correct

if (-not(Test-Path -Path $outputpath -PathType Container)) {
    Write-Host 'Creating output directory...' -ForegroundColor DarkMagenta -BackgroundColor White
    New-Item -ItemType Directory -Name $outputpath
}

if (-not(Test-Path -Path $inputpath -PathType Container)) {
    Write-Host 'Input path must be a directory' -ForegroundColor Red
    exit
}

if (($outputformatvideo.Length -ne 0 -and -not $outputformatvideo.StartsWith(".")) -or ($outputformatimage.Length -ne 0 -and -not $outputformatimage.StartsWith('.')) -or ($outputformataudio.Length -ne 0 -and -not $outputformataudio.StartsWith('.'))) {
    Write-Host 'Output formats must start with "."' -ForegroundColor Red
    exit
}

Write-Host "Input path: $inputpath"

foreach ($item in $(Get-ChildItem $inputpath)) {
    Write-Host "$item" -ForegroundColor DarkCyan
    $ex = $null
    if (Get-ChildItem $item -Include '*.mp4', '*.avi', '*.mov', '*.mkv', '*.wmv', '*.flv', '*.webm') {
        $ex = Start-Process -PassThru -Wait -NoNewWindow -FilePath $ffmpegpath -ArgumentList '-hwaccel', $hwaccel, '-i', "`"$item`"", '-c:v', $c_v, '-c:a', $c_a, '-b:v', $b_v, '-b:a', $b_a, '-ar', $ar, "`"$(Get-OutputFullFileNameVideo -filepath $item)`""
    }
    elseif (Get-ChildItem $item -Include '*.jpg', '*.jpeg', '*.png', '*.webp') {
        $ex = Start-Process -PassThru -Wait -NoNewWindow -FilePath $ffmpegpath -ArgumentList '-hwaccel', $hwaccel, '-i', "`"$item`"", "`"$(Get-OutputFullFileNameImage -filepath $item)`""
    }
    elseif (Get-ChildItem $item -Include '*.mp3', '*.wav', '*.m4a', '*.flac', '*.opus', '*.aac', '*.ac3', '*.wma') {
        $ex = Start-Process -PassThru -Wait -NoNewWindow -FilePath $ffmpegpath -ArgumentList '-i', "`"$item`"", '-b:a', $b_a, '-c:a', $c_a, '-ar', $ar, "`"$(Get-OutputFullFileNameAudio $item)`""
    }
    else {
        Write-Host "Cannot process $item" -ForegroundColor Red
        continue
    }
    if ($ex.ExitCode -ne 0) {
        Write-Host "Stdout:"
        Write-Host $ex.StandardOutput
        Write-Host "Stderr:"
        Write-Host $ex.StandardError -ForegroundColor Red       
    }
}
