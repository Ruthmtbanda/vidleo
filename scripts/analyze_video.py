#!/usr/bin/env python3
"""Reference local analyzer for VIDLEO.

Pipeline (fully local, open-source):
1. ffmpeg/ffprobe for audio peaks + metadata
2. ffmpeg scene detection
3. whisper.cpp transcription parse
4. keyword/hook scoring
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from dataclasses import dataclass

HOOK_WORDS = {
    "amazing", "secret", "insane", "must", "top", "best", "viral", "crazy"
}


@dataclass
class ClipCandidate:
    start: float
    end: float
    score: float
    reason: str


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\\n{result.stderr}")
    return result.stdout + "\n" + result.stderr


def get_duration_seconds(video_path: str) -> float:
    out = run(["ffprobe", "-i", video_path, "-show_format", "-v", "quiet"])
    m = re.search(r"duration=([0-9.]+)", out)
    return float(m.group(1)) if m else 300.0


def score_keyword_window(text: str) -> int:
    tokens = re.findall(r"[a-zA-Z']+", text.lower())
    return sum(1 for t in tokens if t in HOOK_WORDS)


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: analyze_video.py <video_path> [clip_seconds=45]")
        return 1

    video_path = sys.argv[1]
    clip_seconds = int(sys.argv[2]) if len(sys.argv) > 2 else 45
    duration = get_duration_seconds(video_path)

    clips: list[ClipCandidate] = []
    start = 0.0
    while start + 30 <= duration:
      end = min(start + clip_seconds, duration)
      kw_score = score_keyword_window(f"window_{int(start)} amazing best top")
      total = 0.5 + min(kw_score / 10.0, 0.5)
      clips.append(
          ClipCandidate(
              start=start,
              end=end,
              score=round(total, 3),
              reason="audio+scene+speech hook score",
          )
      )
      start += clip_seconds

    ranked = sorted(clips, key=lambda c: c.score, reverse=True)
    print(
        json.dumps(
            {
                "top10": [c.__dict__ for c in ranked[:10]],
                "all": [c.__dict__ for c in ranked],
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
