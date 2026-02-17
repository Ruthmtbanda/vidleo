# VIDLEO

VIDLEO is an offline-first Flutter short video creator app that can ingest YouTube links or local files, run local highlight analysis, and generate share-ready MP4 shorts.

## Core features

- Input source: YouTube URL (using `yt-dlp`) or local file picker (`.mp4`, `.mov`, `.avi`).
- Local analysis pipeline:
  - Audio peak detection
  - Scene change detection
  - Whisper transcription (via `whisper.cpp`)
  - Keyword/hook scoring
- Shorts generation:
  - Clip length range 30–60 seconds
  - Aspect ratio selection: `9:16`, `16:9`, `1:1`
  - Choose number of shorts to generate
  - Export, delete, and regenerate clips
- UI flow:
  - Home
  - Processing
  - Shorts grid
  - Settings

## Output directory

Generated clips are written under app documents directory:

`/VIDLEO/shorts/`

## Local binaries required (offline-compatible)

Install and bundle binaries for target device:

- `ffmpeg`
- `ffprobe`
- `yt-dlp`
- `whisper.cpp` binary

Set executable paths in app settings or wire app assets/platform channel to unpack binaries on first run.

## Architecture

- `lib/services/video_processing_service.dart`: orchestrates analysis + clip generation.
- `scripts/analyze_video.py`: reference local Python analyzer using ffmpeg/whisper outputs.
- Flutter UI remains fully local and API-free.

## Run (when Flutter SDK is installed)

```bash
flutter create .
flutter pub get
flutter run
```

> Do **not** build APK in debug/release as requested.

## Bootstrap workflow for missing Flutter SDK

If local environment is missing Flutter, use the repository bootstrap helper once Flutter is installed:

```bash
./scripts/bootstrap_flutter.sh
```

This repository also includes CI workflow `.github/workflows/flutter-bootstrap.yml` that runs:

- `flutter create . --project-name vidleo --platforms=android`
- `flutter pub get`
- `flutter analyze`

so bootstrap is continuously verified on pushes/PRs.
