#!/usr/bin/env python3
import concurrent.futures
import logging
import os
import pathlib
import shutil
import subprocess
import sys

logger = logging.getLogger("webp")
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("[WebPConverter-Win] %(levelname)s : %(message)s")
streamhandler = logging.StreamHandler()
streamhandler.setFormatter(formatter)
logger.addHandler(streamhandler)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".jxl", ".png", ".gif", ".bmp"}


def detectArchiveType(file_path: pathlib.Path) -> str:
    """Detect zip vs rar using magic header bytes (pure Python, cross-platform)."""
    try:
        with open(file_path, "rb") as f:
            header = f.read(7)
            if header.startswith(b"PK\x03\x04") or header.startswith(b"PK\x05\x06"):
                return "zip"
            elif header.startswith(b"Rar!\x1a\x07") or header.startswith(b"\x52\x61\x72\x21"):
                return "rar"
    except Exception as e:
        logger.warning(f"Could not read magic bytes from {file_path}: {e}")

    ext = file_path.suffix.lower()
    if ext in [".cbr", ".rar"]:
        return "rar"
    return "zip"


def createWorkDir(filename: pathlib.Path) -> pathlib.Path:
    default_dir = str(pathlib.Path(__file__).parent.resolve())
    cwd = pathlib.Path(os.getenv("C2W_PATH", default_dir))
    work_path = cwd.joinpath("work", filename.stem.replace("'", ""))
    logger.info(f"Working directory: {work_path}")
    if work_path.exists():
        logger.info("Working directory already exists. Cleaning up.")
        shutil.rmtree(work_path, ignore_errors=True)
    work_path.mkdir(mode=0o775, parents=True)
    return work_path


def extractComicFile(work_path: pathlib.Path, filename: pathlib.Path):
    logger.info(f"Extracting {filename.resolve()} to {work_path.resolve()}")
    filetype = detectArchiveType(filename)
    try:
        if filetype == "rar":
            res = subprocess.run(
                ["unrar", "e", "-y", "-o+", str(filename.resolve()), str(work_path.resolve())],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            if res.returncode != 0:
                subprocess.run(
                    ["7z", "e", f"-o{work_path.resolve()}", "-y", str(filename.resolve())],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=True,
                )
        else:
            subprocess.run(
                ["7z", "e", f"-o{work_path.resolve()}", "-y", str(filename.resolve())],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True,
            )
    except Exception as e:
        logger.error(f"Extraction error: {e}")


def convertSingleFile(file: pathlib.Path, work_path: pathlib.Path):
    if file.suffix.lower() not in IMAGE_EXTENSIONS:
        return
    try:
        out_file = work_path / f"{file.stem}.webp"
        if file.suffix.lower() == ".gif":
            cmd = ["gif2webp", "-quiet", "-q", "80", str(file.resolve()), "-o", str(out_file.resolve())]
        else:
            cmd = ["cwebp", "-quiet", "-q", "80", str(file.resolve()), "-o", str(out_file.resolve())]

        res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode == 0:
            file.unlink(missing_ok=True)
        else:
            logger.warning(f"Conversion failed for {file.name}")
    except Exception as e:
        logger.error(f"Error converting {file.name}: {e}")


def convertToWebP(work_path: pathlib.Path, workers: int = 4):
    logger.info(f"Starting multithreaded WebP conversion (Workers: {workers})...")
    files = [f for f in work_path.iterdir() if f.is_file()]
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(convertSingleFile, f, work_path) for f in files]
        concurrent.futures.wait(futures)

    # Clean up any lingering original images to guarantee only .webp & metadata remain
    for f in list(work_path.iterdir()):
        if f.is_file() and f.suffix.lower() in IMAGE_EXTENSIONS:
            f.unlink(missing_ok=True)


def createProcessedComic(work_path: pathlib.Path, output_path: pathlib.Path):
    logger.info(f"Creating converted CBZ file for {output_path}")
    output_cbz = output_path.with_suffix(".cbz")

    # Package into a clean temporary archive first to avoid appending to an existing CBZ
    temp_cbz = work_path.parent / f"{output_path.stem}_fresh.cbz"
    if temp_cbz.exists():
        temp_cbz.unlink()

    cmd = [
        "7z",
        "a",
        "-tzip",
        "-mx=9",
        str(temp_cbz.resolve()),
        f"{work_path.resolve()}\\*",
    ]
    try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Error in Compression subprocess: {e.stderr}")
        return

    # Delete original source file if different extension (.cbr)
    if output_path.exists() and output_path.resolve() != output_cbz.resolve():
        output_path.unlink(missing_ok=True)

    # Atomically replace target CBZ with the newly packaged WebP CBZ
    shutil.move(str(temp_cbz), str(output_cbz))
    logger.info(f"Successfully replaced {output_cbz.name} with clean WebP CBZ")


def cleanUp(work_path: pathlib.Path):
    shutil.rmtree(work_path, ignore_errors=True)


if __name__ == "__main__":
    target = None
    if len(sys.argv) >= 5:
        target = pathlib.Path(sys.argv[4])
    elif len(sys.argv) >= 2:
        target = pathlib.Path(sys.argv[1])

    if not target or not target.exists():
        logger.error("No valid comic file path provided.")
        sys.exit(1)

    logger.info(f"Converting {target.resolve()}")
    work_path = createWorkDir(target)
    extractComicFile(work_path, target)
    convertToWebP(work_path)
    createProcessedComic(work_path, target)
    logger.info("Conversion finished")
    cleanUp(work_path)
