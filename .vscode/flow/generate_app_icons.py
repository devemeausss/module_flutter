#!/usr/bin/env python3
"""Generate Android/iOS app icon assets from a source PNG."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from collections import deque

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/images/icon_source.png"
PRIMARY_RGB = (0x48, 0xB5, 0xAE)

MIPMAP_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

LAUNCH_PORTRAIT = {
    "LaunchImage.png": ((375, 812), 220),
    "LaunchImage@2x.png": ((750, 1624), 440),
    "LaunchImage@3x.png": ((1125, 2436), 660),
}


def fit_on_canvas(source: Image.Image, canvas_size: int) -> Image.Image:
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    src = source.convert("RGBA")
    scale = min(canvas_size / src.width, canvas_size / src.height)
    new_w = max(1, int(round(src.width * scale)))
    new_h = max(1, int(round(src.height * scale)))
    resized = src.resize((new_w, new_h), Image.Resampling.LANCZOS)
    offset = ((canvas_size - new_w) // 2, (canvas_size - new_h) // 2)
    canvas.paste(resized, offset, resized)
    return canvas


def apply_round_mask(image: Image.Image) -> Image.Image:
    size = image.size[0]
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    rounded = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rounded.paste(image, (0, 0), mask)
    return rounded


def white_silhouette(image: Image.Image, size: int = 96) -> Image.Image:
    """White animal shapes on transparent — for logos with white on colored bg."""
    fitted = fit_on_canvas(image.convert("RGBA"), size)
    pixels = fitted.load()
    width, height = fitted.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a > 64 and r > 180 and g > 180 and b > 180:
                pixels[x, y] = (255, 255, 255, 255)
            else:
                pixels[x, y] = (255, 255, 255, 0)
    return fitted


def splash_icon(image: Image.Image, canvas_size: int, icon_max: int) -> Image.Image:
    """Centered splash icon — keeps full logo (no background stripping)."""
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    inner = fit_on_canvas(image.convert("RGBA"), icon_max)
    offset = ((canvas_size - icon_max) // 2, (canvas_size - icon_max) // 2)
    canvas.paste(inner, offset, inner)
    return canvas


def cover_crop_portrait(source: Image.Image, width: int, height: int) -> Image.Image:
    """Full-screen launch: scale to fill portrait canvas, center crop."""
    src = source.convert("RGBA")
    scale = max(width / src.width, height / src.height)
    new_w = max(1, int(round(src.width * scale)))
    new_h = max(1, int(round(src.height * scale)))
    resized = src.resize((new_w, new_h), Image.Resampling.LANCZOS)
    left = (new_w - width) // 2
    top = (new_h - height) // 2
    cropped = resized.crop((left, top, left + width, top + height))
    return cropped.convert("RGB")


def strip_edge_flat_background(
    image: Image.Image, tolerance: int = 30
) -> Image.Image:
    """Remove near-white or near-black pixels connected to image edges."""
    src = image.convert("RGBA")
    width, height = src.size
    pixels = src.load()

    def is_flat_bg(r: int, g: int, b: int) -> bool:
        if r >= 255 - tolerance and g >= 255 - tolerance and b >= 255 - tolerance:
            return True
        return r <= tolerance and g <= tolerance and b <= tolerance

    visited: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height:
            continue
        if (x, y) in visited:
            continue
        visited.add((x, y))
        r, g, b, a = pixels[x, y]
        if a == 0 or not is_flat_bg(r, g, b):
            continue
        pixels[x, y] = (r, g, b, 0)
        queue.extend([(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)])

    return src


def centered_icon_portrait(
    source: Image.Image,
    width: int,
    height: int,
    icon_max: int,
) -> Image.Image:
    """Centered splash icon — user image only; transparent outside; white from storyboard."""
    canvas = Image.new("RGBA", (width, height), (255, 255, 255, 0))
    prepared = strip_edge_flat_background(source)
    logo = fit_on_canvas(prepared.convert("RGBA"), icon_max)
    offset = ((width - icon_max) // 2, (height - icon_max) // 2)
    canvas.paste(logo, offset, logo)
    return canvas


def flatten_on_background(
    image: Image.Image, size: int, bg_rgb: tuple[int, int, int]
) -> Image.Image:
    fitted = fit_on_canvas(image, size)
    background = Image.new("RGB", (size, size), bg_rgb)
    background.paste(fitted, (0, 0), fitted)
    return background


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if image.mode == "RGBA" and "1024" in path.name:
        bg = Image.new("RGB", image.size, PRIMARY_RGB)
        bg.paste(image, (0, 0), image)
        bg.save(path, "PNG")
    elif image.mode == "RGBA":
        image.save(path, "PNG")
    else:
        image.save(path, "PNG")


def generate_launch_full(
    sources: dict[str, Path],
    default_source: Path,
) -> None:
    launch_dir = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for filename, ((width, height), _) in LAUNCH_PORTRAIT.items():
        src_path = sources.get(filename, default_source)
        src = Image.open(src_path)
        out = cover_crop_portrait(src, width, height)
        out.save(launch_dir / filename, "PNG")


def generate_launch_centered(
    sources: dict[str, Path],
    default_source: Path,
) -> None:
    launch_dir = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for filename, ((width, height), icon_max) in LAUNCH_PORTRAIT.items():
        src_path = sources.get(filename, default_source)
        src = Image.open(src_path)
        out = centered_icon_portrait(src, width, height, icon_max)
        out.save(launch_dir / filename, "PNG")


def generate_app_icons(source_path: Path) -> None:
    source = Image.open(source_path)
    res_android = ROOT / "android/app/src/main/res"

    for folder, size in MIPMAP_SIZES.items():
        launcher = fit_on_canvas(source, size)
        round_icon = apply_round_mask(launcher)
        save_png(launcher, res_android / folder / "ic_launcher.png")
        save_png(round_icon, res_android / folder / "ic_launcher_round.png")

    android12 = splash_icon(source, 512, 300)
    for drawable in ("drawable", "drawable-v21"):
        save_png(android12, res_android / drawable / "android12.png")

    notification = white_silhouette(source, 96)
    for drawable in ("drawable", "drawable-v21"):
        save_png(notification, res_android / drawable / "icon_notification.png")

    ios_icon_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in IOS_ICONS.items():
        if size == 1024:
            icon = flatten_on_background(source, size, PRIMARY_RGB)
        else:
            icon = fit_on_canvas(source, size)
        save_png(icon, ios_icon_dir / filename)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate app icon assets")
    parser.add_argument(
        "icon_source",
        nargs="?",
        default=str(SOURCE),
        help="Path to app icon source PNG",
    )
    parser.add_argument(
        "--launch-full",
        metavar="PATH",
        help="Full-screen LaunchImage source (cover-crop per scale)",
    )
    parser.add_argument("--launch-full-1x", metavar="PATH")
    parser.add_argument("--launch-full-2x", metavar="PATH")
    parser.add_argument("--launch-full-3x", metavar="PATH")
    parser.add_argument(
        "--launch-centered",
        metavar="PATH",
        help="Centered-logo LaunchImage source",
    )
    parser.add_argument("--launch-centered-1x", metavar="PATH")
    parser.add_argument("--launch-centered-2x", metavar="PATH")
    parser.add_argument("--launch-centered-3x", metavar="PATH")
    return parser.parse_args(argv)


def main() -> int:
    args = parse_args(sys.argv[1:])
    source_path = Path(args.icon_source)
    if not source_path.exists():
        print(f"Source icon not found: {source_path}", file=sys.stderr)
        return 1

    generate_app_icons(source_path)

    if args.launch_full:
        default = Path(args.launch_full)
        sources = {
            "LaunchImage.png": Path(args.launch_full_1x or default),
            "LaunchImage@2x.png": Path(args.launch_full_2x or default),
            "LaunchImage@3x.png": Path(args.launch_full_3x or default),
        }
        generate_launch_full(sources, default)
        print("Generated LaunchImage (full_screen).")

    if args.launch_centered:
        default = Path(args.launch_centered)
        sources = {
            "LaunchImage.png": Path(args.launch_centered_1x or default),
            "LaunchImage@2x.png": Path(args.launch_centered_2x or default),
            "LaunchImage@3x.png": Path(args.launch_centered_3x or default),
        }
        generate_launch_centered(sources, default)
        print("Generated LaunchImage (centered_icon).")

    print("Generated all app icon assets.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
