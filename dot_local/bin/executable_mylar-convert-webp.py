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
logger.propagate = False
formatter = logging.Formatter(
    "[WebPConverter] %(asctime)s %(levelname)s : %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
streamhandler = logging.StreamHandler(sys.stdout)
streamhandler.setFormatter(formatter)
logger.addHandler(streamhandler)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".jxl", ".png", ".gif", ".bmp"}


def detectArchiveType(file_path: pathlib.Path) -> str:
    """Detect zip vs rar using magic bytes or extension fallback."""
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


def extractComicFile(work_path: pathlib.Path, filename: pathlib.Path) -> bool:
    logger.info(f"Extracting {filename.resolve()} to {work_path.resolve()}")
    filetype = detectArchiveType(filename)
    try:
        if filetype == "rar":
            res = subprocess.run(
                ["unrar", "e", "-y", "-o+", str(filename.resolve()), str(work_path.resolve())],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            if res.returncode != 0:
                if res.stdout:
                    logger.debug("unrar output: %s", res.stdout.strip())
                subprocess.run(
                    ["7z", "e", f"-o{work_path.resolve()}", "-y", str(filename.resolve())],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    check=True,
                )
        else:
            subprocess.run(
                ["7z", "e", f"-o{work_path.resolve()}", "-y", str(filename.resolve())],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                check=True,
            )
    except Exception as e:
        logger.error(f"Extraction error: {e}")
        return False
    return True


def convertSingleFile(file: pathlib.Path, work_path: pathlib.Path):
    if file.suffix.lower() not in IMAGE_EXTENSIONS:
        return True
    try:
        out_file = work_path / f"{file.stem}.webp"
        if file.suffix.lower() == ".gif":
            cmd = ["gif2webp", "-quiet", "-q", "80", str(file.resolve()), "-o", str(out_file.resolve())]
        else:
            cmd = ["cwebp", "-quiet", "-q", "80", str(file.resolve()), "-o", str(out_file.resolve())]

        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if res.returncode == 0:
            file.unlink(missing_ok=True)
            return True
        else:
            logger.warning("Conversion failed for %s: %s", file.name, res.stdout.strip())
            return False
    except Exception as e:
        logger.error(f"Error converting {file.name}: {e}")
        return False


def convertToWebP(work_path: pathlib.Path, workers: int = 4) -> bool:
    logger.info("Starting multithreaded conversion to WebP")
    files = [f for f in work_path.iterdir() if f.is_file() and f.suffix.lower() in IMAGE_EXTENSIONS]
    if not files:
        logger.error("No supported images were found in the comic archive.")
        return False
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(convertSingleFile, f, work_path) for f in files]
        if not all(future.result() for future in futures):
            return False

    # Clean up any lingering original images to guarantee only .webp & metadata remain
    for f in list(work_path.iterdir()):
        if f.is_file() and f.suffix.lower() in IMAGE_EXTENSIONS:
            f.unlink(missing_ok=True)
    return True


def createProcessedComic(work_path: pathlib.Path, output_path: pathlib.Path) -> bool:
    logger.info(f"Creating converted file under {output_path}")
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
        str(work_path.resolve() / "*"),
    ]
    try:
        subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        logger.error("Error in compression subprocess: %s", e)
        if e.stdout:
            logger.error("7z output: %s", e.stdout.strip())
        return False

    # Replace the target archive after the new archive has been created.
    try:
        os.replace(temp_cbz, output_cbz)
    except OSError as e:
        logger.error(f"Could not replace the target archive: {e}")
        return False
    if output_path.exists() and output_path.resolve() != output_cbz.resolve():
        output_path.unlink()
    logger.info("Successfully replaced %s with clean WebP CBZ", output_cbz.name)
    return True


def cleanUp(work_path: pathlib.Path):
    shutil.rmtree(work_path.absolute(), ignore_errors=True)


def resolveTarget(arguments):
    # Mylar extra scripts receive: nzb name, source folder, filename, output folder, metadata.
    if len(arguments) >= 5:
        target = pathlib.Path(arguments[4]) / arguments[3]
        if target.is_file():
            return target

    for argument in arguments[1:]:
        target = pathlib.Path(argument)
        if target.is_file():
            return target
    return None


if __name__ == "__main__":
    target = resolveTarget(sys.argv)

    if not target or not target.exists():
        logger.error("No valid comic file path provided.")
        sys.exit(1)

    logger.info(f"Converting {target.resolve()}")
    work_path = createWorkDir(target)
    try:
        if not extractComicFile(work_path, target):
            sys.exit(1)
        if not convertToWebP(work_path):
            sys.exit(1)
        if not createProcessedComic(work_path, target):
            sys.exit(1)
        logger.info("Conversion finished")
    finally:
        cleanUp(work_path)
