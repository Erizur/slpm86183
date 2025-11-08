#!/usr/bin/env python3

import argparse
import os
import sys
import subprocess
import tempfile

script_dir = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.abspath(os.path.join(script_dir, ".."))
src_dir = os.path.join(root_dir, "src")

# Project flags
CPP_FLAGS = [
    "-Iinclude",
    "-Iinclude/psyq",
    "-Isrc",
    "-D_LANGUAGE_C",
    "-D_MIPS_SZLONG=32",
    "-DSCRIPT(...)={}",
    "-D__attribute__(...)=",
    "-D__asm__(...)=",
    "-ffreestanding",
    "-DM2CTX",
    # PSX defines
    "-D__GNUC__",
    "-D__mips__",
]

def import_c_file(in_file) -> str:
    in_file = os.path.relpath(in_file, root_dir)
    cpp_command = ["gcc", "-E", "-P", "-dM", *CPP_FLAGS, in_file]
    cpp_command2 = ["gcc", "-E", "-P", *CPP_FLAGS, in_file]

    with tempfile.NamedTemporaryFile(suffix=".c") as tmp:
        stock_macros = subprocess.check_output(
            ["gcc", "-E", "-P", "-dM", tmp.name],
            cwd=root_dir,
            encoding="utf-8"
        )

    out_text = ""
    try:
        out_text += subprocess.check_output(cpp_command, cwd=root_dir, encoding="utf-8")
        out_text += subprocess.check_output(cpp_command2, cwd=root_dir, encoding="utf-8")
    except subprocess.CalledProcessError:
        print(
            "Failed to preprocess input file, when running command:\n"
            + ' '.join(cpp_command),
            file=sys.stderr,
        )
        sys.exit(1)

    if not out_text:
        print("Output is empty - aborting")
        sys.exit(1)

    # Remove stock GCC macros
    for line in stock_macros.strip().splitlines():
        out_text = out_text.replace(line + "\n", "")

    return out_text

def main():
    parser = argparse.ArgumentParser(
        description="Create a context file for mips_to_c (m2c) decompilation"
    )
    parser.add_argument(
        "c_file",
        help="C source file from which to create context",
    )
    parser.add_argument(
        "-o", "--output",
        default="ctx.c",
        help="Output context file (default: ctx.c)",
    )
    args = parser.parse_args()

    output = import_c_file(args.c_file)

    output_path = os.path.join(root_dir, args.output)
    with open(output_path, "w", encoding="UTF-8") as f:
        f.write(output)

    print(f"Context written to {output_path}")

if __name__ == "__main__":
    main()
