#!/usr/bin/env python3
"""
align_elf_16k.py — Rebuild ELF .so files to be 16 KB page-size compatible.

Android 16 (API 36) enforces 16 KB page alignment for all LOAD segments:
  - p_align >= 16384 (0x4000)
  - p_vaddr % p_align == 0

This script rebuilds the ELF file, inserting padding between segments so every
LOAD segment's virtual address is 16 KB-aligned, and updates all program and
section headers accordingly.

Usage:
    python3 align_elf_16k.py input.so output.so [--page-size 16384]

Exit codes:
    0 — success (file was written)
    1 — error
    2 — file was already aligned, output is a copy of input
"""

import argparse
import struct
import sys
import os
import shutil

PAGE_SIZE_DEFAULT = 16384  # 16 KB


# ── ELF constants ─────────────────────────────────────────────────────────────

ELFMAG = b'\x7fELF'
ELFCLASS64 = 2
ELFDATA2LSB = 1  # little-endian

PT_LOAD   = 1
PT_PHDR   = 6
PT_NULL   = 0

SHT_NULL     = 0
SHT_NOBITS   = 8  # .bss — no file content


# ── Struct helpers ─────────────────────────────────────────────────────────────

def align_up(val, alignment):
    if alignment == 0:
        return val
    return (val + alignment - 1) & ~(alignment - 1)


class ELF64Header:
    SIZE = 64
    FMT  = '<4sBBBBBxxxxxxx'   # e_ident[16]
    FMT2 = '<HHIQQQIHHHHHH'    # rest of header

    def __init__(self, data):
        ident_raw = data[:16]
        ident = struct.unpack_from(self.FMT, ident_raw)
        if ident[0] != ELFMAG:
            raise ValueError("Not an ELF file")
        if ident[1] != ELFCLASS64:
            raise ValueError(f"ELF32 detected — 16KB alignment only required for 64-bit ABIs, skipping")
        if ident[2] != ELFDATA2LSB:
            raise ValueError("Only little-endian ELF supported")
        self.e_ident = ident_raw

        (self.e_type, self.e_machine, self.e_version,
         self.e_entry, self.e_phoff, self.e_shoff,
         self.e_flags, self.e_ehsize,
         self.e_phentsize, self.e_phnum,
         self.e_shentsize, self.e_shnum,
         self.e_shstrndx) = struct.unpack_from(self.FMT2, data, 16)

    def pack(self):
        return self.e_ident + struct.pack(
            self.FMT2,
            self.e_type, self.e_machine, self.e_version,
            self.e_entry, self.e_phoff, self.e_shoff,
            self.e_flags, self.e_ehsize,
            self.e_phentsize, self.e_phnum,
            self.e_shentsize, self.e_shnum,
            self.e_shstrndx)


class ELF64Phdr:
    SIZE = 56
    FMT  = '<IIQQQQQQ'

    def __init__(self, data, offset=0):
        (self.p_type, self.p_flags,
         self.p_offset, self.p_vaddr, self.p_paddr,
         self.p_filesz, self.p_memsz,
         self.p_align) = struct.unpack_from(self.FMT, data, offset)

    def pack(self):
        return struct.pack(
            self.FMT,
            self.p_type, self.p_flags,
            self.p_offset, self.p_vaddr, self.p_paddr,
            self.p_filesz, self.p_memsz,
            self.p_align)


class ELF64Shdr:
    SIZE = 64
    FMT  = '<IIQQQQIIQQ'

    def __init__(self, data, offset=0):
        (self.sh_name, self.sh_type, self.sh_flags,
         self.sh_addr, self.sh_offset, self.sh_size,
         self.sh_link, self.sh_info,
         self.sh_addralign, self.sh_entsize) = struct.unpack_from(self.FMT, data, offset)

    def pack(self):
        return struct.pack(
            self.FMT,
            self.sh_name, self.sh_type, self.sh_flags,
            self.sh_addr, self.sh_offset, self.sh_size,
            self.sh_link, self.sh_info,
            self.sh_addralign, self.sh_entsize)


# ── Core logic ────────────────────────────────────────────────────────────────

def is_already_aligned(phdrs, page_size):
    """Return True if all LOAD segments already satisfy page_size alignment."""
    for ph in phdrs:
        if ph.p_type == PT_LOAD:
            if ph.p_align < page_size:
                return False
            if ph.p_vaddr % page_size != 0:
                return False
    return True


def rebuild_elf(data, page_size):
    """
    Rebuild ELF binary so every LOAD segment is page_size-aligned.

    Strategy:
      1. Parse all program headers and section headers.
      2. For each LOAD segment (in order), compute the new file offset by
         aligning the previous segment's end up to page_size.
      3. Copy each segment's content with padding.
      4. Copy any section data that lives OUTSIDE LOAD segments (e.g. .shstrtab)
         to the end of the file and update those section headers.
      5. Fix up non-LOAD program headers.
      6. Append section headers and update the ELF header (e_shoff).
    """
    ehdr = ELF64Header(data)

    # Read program headers
    phdrs = []
    for i in range(ehdr.e_phnum):
        off = ehdr.e_phoff + i * ehdr.e_phentsize
        phdrs.append(ELF64Phdr(data, off))

    # Read section headers
    shdrs = []
    for i in range(ehdr.e_shnum):
        off = ehdr.e_shoff + i * ehdr.e_shentsize
        shdrs.append(ELF64Shdr(data, off))

    # ── Build new file layout ──────────────────────────────────────────────────
    pht_end = ehdr.e_phoff + ehdr.e_phnum * ehdr.e_phentsize
    new_file = bytearray(data[:pht_end])

    # Align to page boundary for first segment
    new_cursor = align_up(len(new_file), page_size)
    new_file += b'\x00' * (new_cursor - len(new_file))

    new_vaddr = 0
    offset_map  = {}   # old_p_offset -> delta (new_offset - old_offset)
    load_ranges = []   # [(old_file_start, old_file_end), ...]

    load_segments = [(i, ph) for i, ph in enumerate(phdrs) if ph.p_type == PT_LOAD]

    for idx, (ph_idx, ph) in enumerate(load_segments):
        seg_data  = data[ph.p_offset: ph.p_offset + ph.p_filesz]
        old_start = ph.p_offset
        old_end   = ph.p_offset + ph.p_filesz

        load_ranges.append((old_start, old_end))
        offset_map[old_start] = new_cursor - old_start

        ph.p_offset = new_cursor
        ph.p_vaddr  = new_vaddr
        ph.p_paddr  = new_vaddr
        ph.p_align  = page_size

        new_file  += seg_data
        new_cursor += ph.p_filesz
        new_vaddr  += ph.p_memsz

        if idx < len(load_segments) - 1:
            nc_aligned  = align_up(new_cursor, page_size)
            new_file   += b'\x00' * (nc_aligned - new_cursor)
            new_cursor  = nc_aligned
            new_vaddr   = align_up(new_vaddr, page_size)

    # ── Helper: find delta for an offset that is inside a LOAD segment ────────
    def find_delta(sh_offset):
        best = (0, 0)  # (old_start, delta)
        for old_start, delta in offset_map.items():
            if old_start <= sh_offset and old_start >= best[0]:
                best = (old_start, delta)
        return best[1]

    def is_in_load(sh_offset, sh_size):
        """Return True if the section's file content is fully inside a LOAD segment."""
        for (start, end) in load_ranges:
            if start <= sh_offset and sh_offset + sh_size <= end:
                return True
        return False

    # ── Fix up non-LOAD program headers ───────────────────────────────────────
    for ph in phdrs:
        if ph.p_type in (PT_LOAD, PT_NULL):
            continue
        delta = find_delta(ph.p_offset)
        ph.p_offset += delta
        ph.p_vaddr  += delta
        ph.p_paddr  += delta

    # ── Fix section headers ───────────────────────────────────────────────────
    # Sections whose data is INSIDE a LOAD segment: update offset via delta.
    # Sections whose data is OUTSIDE all LOAD segments (e.g. .shstrtab, debug):
    #   copy their content to the end of new_file and update sh_offset directly.
    for i, sh in enumerate(shdrs):
        if sh.sh_type == SHT_NULL:
            continue
        if sh.sh_type == SHT_NOBITS or sh.sh_size == 0:
            # .bss or empty — no file content, just update virtual address
            if sh.sh_type == SHT_NOBITS:
                sh.sh_addr += find_delta(sh.sh_offset)
            continue

        if is_in_load(sh.sh_offset, sh.sh_size):
            # Data lives inside a LOAD segment — shift by the LOAD segment's delta
            delta = find_delta(sh.sh_offset)
            sh.sh_offset += delta
            sh.sh_addr   += delta
        else:
            # Data lives OUTSIDE all LOAD segments (e.g. .shstrtab, .comment)
            # Copy it explicitly to the end of the new file
            section_data = data[sh.sh_offset: sh.sh_offset + sh.sh_size]
            align_to     = max(sh.sh_addralign, 1)
            nc           = align_up(len(new_file), align_to)
            new_file    += b'\x00' * (nc - len(new_file))
            sh.sh_offset = len(new_file)
            # sh_addr intentionally not changed (non-loaded section, addr stays 0)
            new_file    += section_data

    # ── Append section headers at end ─────────────────────────────────────────
    nc       = align_up(len(new_file), 8)
    new_file += b'\x00' * (nc - len(new_file))
    new_shoff = len(new_file)

    for sh in shdrs:
        new_file += sh.pack()

    # ── Rewrite ELF header ────────────────────────────────────────────────────
    ehdr.e_shoff = new_shoff
    new_file[:ehdr.e_ehsize] = ehdr.pack()

    # ── Rewrite PHT ───────────────────────────────────────────────────────────
    pht_bytes = b''.join(ph.pack() for ph in phdrs)
    new_file[ehdr.e_phoff: ehdr.e_phoff + len(pht_bytes)] = pht_bytes

    return bytes(new_file)


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description='Rebuild ELF .so files to be 16 KB page-size compatible.')
    parser.add_argument('input',  help='Input .so file')
    parser.add_argument('output', help='Output .so file (can be same as input)')
    parser.add_argument('--page-size', type=int, default=PAGE_SIZE_DEFAULT,
                        help=f'Target page size in bytes (default: {PAGE_SIZE_DEFAULT})')
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f'ERROR: Input file not found: {args.input}', file=sys.stderr)
        sys.exit(1)

    with open(args.input, 'rb') as f:
        data = f.read()

    # Quick sanity check
    if data[:4] != ELFMAG:
        print(f'ERROR: Not an ELF file: {args.input}', file=sys.stderr)
        sys.exit(1)

    # ELF32 (armeabi-v7a, x86) — 16KB alignment not required for 32-bit ABIs
    try:
        ehdr = ELF64Header(data)
    except ValueError as e:
        print(f'INFO: {os.path.basename(args.input)}: {e}. Skipping.')
        if args.input != args.output:
            shutil.copy2(args.input, args.output)
        sys.exit(2)
    phdrs = []
    for i in range(ehdr.e_phnum):
        off = ehdr.e_phoff + i * ehdr.e_phentsize
        phdrs.append(ELF64Phdr(data, off))

    if is_already_aligned(phdrs, args.page_size):
        print(f'INFO: {os.path.basename(args.input)} already {args.page_size}-byte aligned. Copying.')
        if args.input != args.output:
            shutil.copy2(args.input, args.output)
        sys.exit(2)

    print(f'Aligning {os.path.basename(args.input)} to {args.page_size}-byte pages...')
    new_data = rebuild_elf(data, args.page_size)

    # Write output (atomic: write to temp, then rename)
    tmp_out = args.output + '.tmp'
    with open(tmp_out, 'wb') as f:
        f.write(new_data)
    os.replace(tmp_out, args.output)

    # Verify
    ehdr2 = ELF64Header(new_data)
    phdrs2 = []
    for i in range(ehdr2.e_phnum):
        off = ehdr2.e_phoff + i * ehdr2.e_phentsize
        phdrs2.append(ELF64Phdr(new_data, off))

    ok = is_already_aligned(phdrs2, args.page_size)
    if ok:
        orig_kb = len(data) // 1024
        new_kb  = len(new_data) // 1024
        print(f'  OK: {orig_kb} KB -> {new_kb} KB. All LOAD segments now {args.page_size}-byte aligned.')
    else:
        print('WARNING: Alignment verification failed — check your ELF manually.', file=sys.stderr)
        for ph in phdrs2:
            if ph.p_type == PT_LOAD:
                print(f'  LOAD: p_vaddr={hex(ph.p_vaddr)} p_align={hex(ph.p_align)}', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
