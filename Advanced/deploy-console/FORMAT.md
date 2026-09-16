# Fleet format

**exFAT** is the default for every North Forge stick we hand out, including
the 2 TB BLACK-NORTH unless a specific lab disk is NTFS on purpose.

| Why exFAT | Why not the other thing |
|---|---|
| Large files, Windows / macOS / many Linux | FAT32 dies at 4 GB files |
| One volume, one letter, Deploy Console is happy | Two partitions hide the second half on many PCs |
| Future Linux/Apple teammate sticks stay readable | NTFS is fine on Windows-only lab boxes |

Pinokio, if someone installs it later, prefers NTFS — on **their** disk,
not on the fleet volume. See PINOKIO.md.
