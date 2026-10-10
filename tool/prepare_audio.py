#!/usr/bin/env python3
"""TailLimit 白噪音实录音处理脚本。

把原始录音处理成适合移动端内置的格式，并验证循环接缝。

处理链路（顺序很关键）：
    1. 测原始响度，算出需要的固定增益
    2. 施加固定增益
    3. 若首尾不连续，做等功率交叉淡化
    4. 编码为 Opus 48kHz 立体声
    5. 回读验证：削波、循环接缝

注意：不要把 loudnorm 和 afade 串在同一条滤镜链里。
loudnorm 是动态处理，会把 afade 淡出的静音重新抬起来，
导致循环接缝消失不掉。必须"先测增益、再固定增益、最后淡化"。

用法：
    python3 tool/prepare_audio.py --source raw.ogg --output assets/audio/x.ogg \
        --gain 5.9 [--xfade 4.0]

仅做检测（不改文件）：
    python3 tool/prepare_audio.py --inspect assets/audio/x.ogg
"""

from __future__ import annotations

import argparse
import math
import os
import re
import struct
import subprocess
import sys

SAMPLE_RATE = 48000      # Opus 仅支持 48k/24k/16k/12k/8k，取 48k
CHANNELS = 2
OPUS_BITRATE = "64k"     # 环境音 64k 已足够，实测占原始体积约 30%
LOUDNESS_TARGET = -20.0  # LUFS。-20 适合作为背景音，不刺耳


def run(args: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(args, capture_output=True)


def probe_duration(path: str) -> float:
    r = run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "csv=p=0", path])
    return float(r.stdout.decode().strip())


def read_pcm(path: str, rate: int = 22050) -> tuple[int, ...]:
    """读为单声道 16bit PCM 样本，用于分析。"""
    d = run(["ffmpeg", "-v", "error", "-i", path, "-f", "s16le",
             "-ac", "1", "-ar", str(rate), "-"]).stdout
    return struct.unpack(f"<{len(d) // 2}h", d)


def rms_db(samples) -> float:
    if not samples:
        return -999.0
    r = math.sqrt(sum(x * x for x in samples) / len(samples)) / 32768
    return 20 * math.log10(max(r, 1e-9))


def measure_gain(src: str) -> float:
    """单遍 loudnorm 只为读取测量值，不作为最终滤镜。"""
    r = run(["ffmpeg", "-v", "info", "-i", src,
             "-af", f"loudnorm=I={LOUDNESS_TARGET}:TP=-2:LRA=11:print_format=summary",
             "-f", "null", "-"])
    m = re.search(r"Input Integrated:\s*(-?[\d.]+)\s*LUFS", r.stderr.decode())
    in_lufs = float(m.group(1)) if m else LOUDNESS_TARGET
    return round(LOUDNESS_TARGET - in_lufs, 1)


def apply_xfade(path: str, seconds: float, gain_db: float, dest: str) -> None:
    """等功率交叉淡化：把尾部与开头叠化，消除尾部纯静音造成的接缝。

    尾部若是纯静音（常见于"录完就停"的录音），直接循环会听到明显的"咔"。
    这里用 sin/cos 等功率曲线交叉淡化，听感上波形连续。
    """
    raw = run(["ffmpeg", "-v", "error", "-i", path, "-af", f"volume={gain_db}dB",
               "-f", "s16le", "-ac", str(CHANNELS), "-ar", str(SAMPLE_RATE), "-"]).stdout
    s = list(struct.unpack(f"<{len(raw) // 2}h", raw))

    n = int(SAMPLE_RATE * seconds)
    if n * 4 >= len(s):                       # 淡化区过长，退回原样
        run(["ffmpeg", "-v", "error", "-i", path, "-af", f"volume={gain_db}dB",
             "-c:a", "libopus", "-b:a", OPUS_BITRATE, "-ac", str(CHANNELS),
             "-ar", str(SAMPLE_RATE), "-y", dest])
        return

    head = s[: 2 * n]                          # 开头 n 帧（双声道交错）
    tail = s[-2 * n:]                          # 结尾 n 帧
    out = s[: len(s) - 2 * n]                   # 主体去掉尾部淡化区

    for i in range(n):
        a = i / n
        th = math.sin(a * math.pi / 2)          # 0 -> 1
        tl = math.cos(a * math.pi / 2)          # 1 -> 0
        for ch in range(CHANNELS):
            v = int(tail[2 * i + ch] * tl + head[2 * i + ch] * th)
            out.append(max(-32768, min(32767, v)))

    p = subprocess.Popen(
        ["ffmpeg", "-v", "error", "-f", "s16le", "-ar", str(SAMPLE_RATE),
         "-ac", str(CHANNELS), "-i", "-", "-c:a", "libopus", "-b:a", OPUS_BITRATE,
         "-ar", str(SAMPLE_RATE), "-y", dest],
        stdin=subprocess.PIPE)
    p.communicate(struct.pack(f"<{len(out)}h", *out))


def inspect(path: str) -> dict:
    """回读成品，检查削波与循环接缝。"""
    s = read_pcm(path)
    n = len(s)
    peak = max(abs(x) for x in s) / 32768
    clip = sum(1 for x in s if abs(x) >= 32767)

    # 用 1/8 段窗口而非 0.5s，避免单点噪声误判
    w = n // 8
    head, tail = rms_db(s[:w]), rms_db(s[-w:])
    # 接缝跳变：首尾各 100ms 的均值差，> 6dB 听得出"咔"
    m = int(22050 * 0.1)
    seam = abs(rms_db(s[:m]) - rms_db(s[-m:]))

    return {
        "duration": n / 22050,
        "peak": peak,
        "clip": clip,
        "head_db": head,
        "tail_db": tail,
        "level_diff": abs(head - tail),
        "seam_db": seam,
        "loop_ok": abs(head - tail) < 4 and seam < 6,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="TailLimit 音频资源处理")
    ap.add_argument("--source", help="原始录音路径")
    ap.add_argument("--output", help="输出 ogg 路径")
    ap.add_argument("--gain", type=float, default=None, help="固定增益 dB，默认自动测量")
    ap.add_argument("--xfade", type=float, default=0.0, help="交叉淡化秒数，0 表示不处理")
    ap.add_argument("--inspect", help="仅检测已有文件")
    args = ap.parse_args()

    if args.inspect:
        if not os.path.exists(args.inspect):
            print(f"文件不存在：{args.inspect}", file=sys.stderr)
            return 1
        r = inspect(args.inspect)
        print(f"文件      : {args.inspect}")
        print(f"大小      : {os.path.getsize(args.inspect) / 1024:.1f} KB")
        print(f"时长      : {r['duration']:.1f}s")
        print(f"峰值      : {r['peak']:.2f}  削波样本: {r['clip']}")
        print(f"首/尾电平 : {r['head_db']:.0f} / {r['tail_db']:.0f} dB  差 {r['level_diff']:.1f} dB")
        print(f"接缝跳变  : {r['seam_db']:.1f} dB")
        print(f"循环判定  : {'自然循环' if r['loop_ok'] else '需要交叉淡化'}")
        return 0 if r["loop_ok"] and r["clip"] == 0 else 1

    if not args.source or not args.output:
        ap.error("需要 --source 与 --output，或用 --inspect")

    gain = args.gain if args.gain is not None else measure_gain(args.source)
    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)

    if args.xfade > 0:
        apply_xfade(args.source, args.xfade, gain, args.output)
    else:
        run(["ffmpeg", "-v", "error", "-i", args.source, "-af", f"volume={gain}dB",
             "-c:a", "libopus", "-b:a", OPUS_BITRATE, "-ac", str(CHANNELS),
             "-ar", str(SAMPLE_RATE), "-y", args.output])

    r = inspect(args.output)
    src_sz = os.path.getsize(args.source)
    out_sz = os.path.getsize(args.output)
    print(f"增益 {gain:+.1f} dB" + (f" | 交叉淡化 {args.xfade}s" if args.xfade else " | 无淡化"))
    print(f"{src_sz / 1024:.0f} KB -> {out_sz / 1024:.0f} KB ({out_sz * 100 // src_sz}%)")
    print(f"时长 {r['duration']:.1f}s | 峰值 {r['peak']:.2f} | 削波 {r['clip']}")
    print(f"首/尾 {r['head_db']:.0f}/{r['tail_db']:.0f} dB | 接缝 {r['seam_db']:.1f} dB")
    print("循环判定：" + ("自然循环" if r["loop_ok"] else "仍需处理"))
    return 0 if r["loop_ok"] and r["clip"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())