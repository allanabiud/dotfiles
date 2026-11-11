#!/usr/bin/env python3
import concurrent.futures
import logging
import os
import pathlib
import re
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

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".jxl", ".png", ".gif", ".bmp", ".webp"}
CONVERTIBLE_EXTENSIONS = IMAGE_EXTENSIONS - {".webp"}
ARCHIVE_EXTENSIONS = {".cbr", ".cbz", ".cb7", ".cbt", ".zip", ".rar", ".7z"}
JUNK_FILES = {"thumbs.db", ".ds_store", "desktop.ini", "metroninfo.xml"}
JUNK_DIRS = {"__macosx"}
TOOL_ENVIRONMENT = {
    "7z": "WEBP_7Z",
    "unrar": "WEBP_UNRAR",
    "cwebp": "WEBP_CWEBP",
    "gif2webp": "WEBP_GIF2WEBP",
}


def resolveTool(name: str):
    configured_path = os.getenv(TOOL_ENVIRONMENT[name])
    if configured_path and pathlib.Path(configured_path).is_file():
        return configured_path

    executable = shutil.which(name) or shutil.which(f"{name}.exe")
    if executable:
        return executable

    if os.name == "nt":
        program_files = [
            os.getenv("ProgramFiles"),
            os.getenv("ProgramFiles(x86)"),
            os.getenv("LOCALAPPDATA"),
        ]
        common_paths = {
            "7z": ["7-Zip/7z.exe"],
            "unrar": ["WinRAR/UnRAR.exe", "UnRAR/UnRAR.exe"],
            "cwebp": ["libwebp/bin/cwebp.exe", "WebP/bin/cwebp.exe"],
            "gif2webp": ["libwebp/bin/gif2webp.exe", "WebP/bin/gif2webp.exe"],
        }
        for root in filter(None, program_files):
            for relative_path in common_paths[name]:
                candidate = pathlib.Path(root) / relative_path
                if candidate.is_file():
                    return str(candidate)

    script_dir = pathlib.Path(__file__).resolve().parent
    for directory in (script_dir, script_dir / "bin", script_dir / "tools"):
        candidate = directory / (f"{name}.exe" if os.name == "nt" else name)
        if candidate.is_file():
            return str(candidate)
    return None


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
        seven_zip = resolveTool("7z")
        if filetype == "rar":
            unrar = resolveTool("unrar")
            if unrar:
                extract_command = [
                    unrar,
                    "x",
                    "-y",
                    "-o+",
                    str(filename.resolve()),
                    str(work_path.resolve()),
                ]
            elif seven_zip:
                extract_command = [
                    seven_zip,
                    "x",
                    f"-o{work_path.resolve()}",
                    "-y",
                    str(filename.resolve()),
                ]
            else:
                raise FileNotFoundError(
                    "No archive extractor found. Install 7-Zip or set WEBP_7Z."
                )

        else:
            if not seven_zip:
                raise FileNotFoundError(
                    "7z was not found. Install 7-Zip or set WEBP_7Z to 7z.exe."
                )
            extract_command = [
                seven_zip,
                "x",
                f"-o{work_path.resolve()}",
                "-y",
                str(filename.resolve()),
            ]

        if filetype == "rar" and unrar:
            res = subprocess.run(
                extract_command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            if res.returncode != 0:
                if res.stdout:
                    logger.debug("unrar output: %s", res.stdout.strip())
                subprocess.run(
                    [
                        seven_zip,
                        "e",
                        f"-o{work_path.resolve()}",
                        "-y",
                        str(filename.resolve()),
                    ],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    check=True,
                )
        else:
            subprocess.run(
                extract_command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                check=True,
            )
    except Exception as e:
        logger.error(f"Extraction error: {e}")
        return False
    return True


def naturalSortKey(path: pathlib.Path):
    return [
        int(part) if part.isdigit() else part.casefold()
        for part in re.split(r"(\d+)", str(path))
    ]


def cleanArchiveContents(work_path: pathlib.Path) -> None:
    for root, dirs, files in os.walk(work_path, topdown=False):
        root_path = pathlib.Path(root)
        for file_name in files:
            if file_name.casefold() in JUNK_FILES or file_name.startswith("._"):
                (root_path / file_name).unlink(missing_ok=True)
        for directory_name in dirs:
            if directory_name.casefold() in JUNK_DIRS:
                shutil.rmtree(root_path / directory_name, ignore_errors=True)


def removeEmptyDirectories(work_path: pathlib.Path) -> None:
    for root, dirs, _ in os.walk(work_path, topdown=False):
        for directory_name in dirs:
            directory = pathlib.Path(root) / directory_name
            try:
                directory.rmdir()
            except OSError:
                pass


def renameImages(work_path: pathlib.Path) -> None:
    image_files = sorted(
        (
            file
            for file in work_path.rglob("*")
            if file.is_file() and file.suffix.casefold() in IMAGE_EXTENSIONS
        ),
        key=naturalSortKey,
    )
    if not image_files:
        return

    width = len(str(len(image_files)))
    temporary_files = []
    for index, file in enumerate(image_files):
        temporary = file.with_name(f".webp-convert-{index:0{width}d}{file.suffix}")
        file.rename(temporary)
        temporary_files.append((temporary, file.with_name(f"{index:0{width}d}{file.suffix}")))

    for temporary, target in temporary_files:
        temporary.rename(target)

    logger.info("Normalized %d image filename(s)", len(image_files))


def convertSingleFile(file: pathlib.Path, work_path: pathlib.Path):
    if file.suffix.lower() not in CONVERTIBLE_EXTENSIONS:
        return True
    try:
        out_file = file.with_suffix(".webp")
        if file.suffix.lower() == ".gif":
            tool = resolveTool("gif2webp")
        else:
            tool = resolveTool("cwebp")
        if not tool:
            logger.error("Conversion tool is unavailable for %s", file.name)
            return False
        cmd = [tool, "-quiet", "-q", "80", str(file.resolve()), "-o", str(out_file.resolve())]

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
    files = [
        f
        for f in work_path.rglob("*")
        if f.is_file() and f.suffix.lower() in CONVERTIBLE_EXTENSIONS
    ]
    if not files:
        webp_files = [
            f
            for f in work_path.rglob("*")
            if f.is_file() and f.suffix.lower() == ".webp"
        ]
        if webp_files:
            logger.info("Archive already contains only WebP images; skipping conversion")
            return True
        logger.error("No supported images were found in the comic archive.")
        return False

    required_tools = {"cwebp" if f.suffix.lower() != ".gif" else "gif2webp" for f in files}
    resolved_tools = {tool: resolveTool(tool) for tool in required_tools}
    missing_tools = sorted(tool for tool, path in resolved_tools.items() if path is None)
    if missing_tools:
        logger.error(
            "Required WebP tool(s) not found in PATH: %s. "
            "Install them or add their directory to the PATH used by Mylar.",
            ", ".join(missing_tools),
        )
        return False

    logger.info("WebP tools available: %s", ", ".join(sorted(required_tools)))
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(convertSingleFile, f, work_path) for f in files]
        if not all(future.result() for future in futures):
            return False

    # Clean up any lingering original images to guarantee only .webp & metadata remain
    for f in work_path.rglob("*"):
        if f.is_file() and f.suffix.lower() in CONVERTIBLE_EXTENSIONS:
            f.unlink(missing_ok=True)
    return True


def createProcessedComic(work_path: pathlib.Path, output_path: pathlib.Path) -> bool:
    logger.info(f"Creating converted file under {output_path}")
    output_cbz = output_path.with_suffix(".cbz")

    # Package into a clean temporary archive first to avoid appending to an existing CBZ
    temp_cbz = work_path.parent / f"{output_path.stem}_fresh.cbz"
    if temp_cbz.exists():
        temp_cbz.unlink()

    seven_zip = resolveTool("7z")
    if not seven_zip:
        logger.error("7z was not found. Install 7-Zip or set WEBP_7Z to 7z.exe.")
        return False

    cmd = [
        seven_zip,
        "a",
        "-tzip",
        "-mx=9",
        str(temp_cbz.resolve()),
        ".",
    ]
    try:
        subprocess.run(
            cmd,
            cwd=str(work_path.resolve()),
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

    try:
        subprocess.run(
            [seven_zip, "t", str(temp_cbz.resolve())],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        logger.error("Archive integrity check failed: %s", e)
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


def archiveEntries(archive_path: pathlib.Path):
    seven_zip = resolveTool("7z")
    if not seven_zip:
        return None
    try:
        result = subprocess.run(
            [seven_zip, "l", "-slt", str(archive_path.resolve())],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        logger.warning("Could not inspect %s: %s", archive_path.name, error)
        return None

    entries = []
    for line in result.stdout.splitlines():
        if line.startswith("Path = "):
            entry = line[7:].strip().replace("\\", "/")
            if (
                entry
                and pathlib.PurePosixPath(entry).name != archive_path.name
                and not entry.endswith("/")
            ):
                entries.append(pathlib.PurePosixPath(entry))
    return entries


def isAlreadyClean(archive_path: pathlib.Path) -> bool:
    if archive_path.suffix.casefold() != ".cbz":
        return False

    entries = archiveEntries(archive_path)
    if entries is None:
        return False

    image_entries = sorted(
        (entry for entry in entries if entry.suffix.casefold() in IMAGE_EXTENSIONS),
        key=lambda entry: naturalSortKey(pathlib.Path(str(entry))),
    )
    if not image_entries or any(entry.suffix.casefold() != ".webp" for entry in image_entries):
        return False

    if any(
        entry.name.casefold() in JUNK_FILES
        or entry.name.startswith("._")
        or any(part.casefold() in JUNK_DIRS for part in entry.parts)
        for entry in entries
    ):
        return False

    width = len(str(len(image_entries)))
    expected_names = {f"{index:0{width}d}.webp" for index in range(len(image_entries))}
    return {entry.name for entry in image_entries} == expected_names


def findComicArchives(folder: pathlib.Path):
    return sorted(
        (
            file
            for file in folder.rglob("*")
            if file.is_file() and file.suffix.lower() in ARCHIVE_EXTENSIONS
        ),
        key=lambda file: str(file).casefold(),
    )


def isComicArchive(path: pathlib.Path) -> bool:
    return path.is_file() and path.suffix.casefold() in ARCHIVE_EXTENSIONS


def resolveTargets(arguments):
    # Mylar extra scripts receive: nzb name, source folder, filename, output folder, metadata.
    if len(arguments) >= 5:
        output_folder = pathlib.Path(arguments[4])
        target = output_folder / arguments[3]
        if isComicArchive(target):
            return [target]
        if output_folder.is_dir():
            return findComicArchives(output_folder)

    for argument in arguments[1:]:
        target = pathlib.Path(argument)
        if isComicArchive(target):
            return [target]

    for argument in reversed(arguments[1:]):
        folder = pathlib.Path(argument)
        if folder.is_dir():
            return findComicArchives(folder)
    return []


if __name__ == "__main__":
    logger.info("Starting WebP post-processing script on %s", sys.platform)
    logger.info("Python executable: %s", sys.executable)
    logger.info("PATH: %s", os.environ.get("PATH", "<not set>"))
    for tool_name in ("7z", "unrar", "cwebp", "gif2webp"):
        logger.info("%s resolved to: %s", tool_name, resolveTool(tool_name) or "<not found>")
    dry_run = "--dry-run" in sys.argv[1:]
    arguments = [argument for argument in sys.argv if argument != "--dry-run"]
    targets = resolveTargets(arguments)

    if not targets:
        logger.error(
            "No comic archive found. Supported extensions: %s",
            ", ".join(sorted(ARCHIVE_EXTENSIONS)),
        )
        sys.exit(1)

    logger.info(
        "Found %d comic archive(s) to %s",
        len(targets),
        "inspect" if dry_run else "convert",
    )
    if dry_run:
        for target in targets:
            logger.info("DRY RUN: would process %s", target.resolve())
        sys.exit(0)

    for target in targets:
        if isAlreadyClean(target):
            logger.info("Skipping already-clean WebP CBZ: %s", target.resolve())
            continue
        logger.info(f"Converting {target.resolve()}")
        work_path = createWorkDir(target)
        try:
            if not extractComicFile(work_path, target):
                sys.exit(1)
            cleanArchiveContents(work_path)
            renameImages(work_path)
            if not convertToWebP(work_path):
                sys.exit(1)
            removeEmptyDirectories(work_path)
            if not createProcessedComic(work_path, target):
                sys.exit(1)
            logger.info("Conversion finished for %s", target.name)
        finally:
            cleanUp(work_path)
