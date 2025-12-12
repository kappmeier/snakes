# SnakeS

A DOS Snake clone.

## Running

The binaries require MS-DOS 6 (or later). It is typically difficult to obtain current machines able
to execute such binaries. There are alternatives to execute the game.

### Running in a virtual machine

The binary can be executed in MS-DOS 6.22 within a VirtualBox virtual machine. To transfer the
binary to the virtual machine, you can use the following method:

1. Create a disk image and mount it as a loop device on your host system.
2. Copy the binary onto the mounted disk image.
3. Unmount the disk image from the host system.
4. Attach the disk image to the VirtualBox VM as a floppy or hard disk.

Once the disk is attached, boot the VM and access the binary from the mounted disk to execute it in
MS-DOS 6.22.

### In a Browser within js-dos

A js-dos bundle in a `.jsdos` zip archive can be loaded in a server hosted website (see
[getting started guide](https://js-dos.com/dos-api.html)). A
[template](./release/jsdos/template.html) is included to see easy integration of the emulator in
websites. There no further files needed to execute the DOS game inside a browser.

## Releasing

Creating a new binary version is done using Turbo Pascal 6.0. This is best done from within a
virtual machine. Next, a [release] can be created.

### Releasing a `js-dos` binary

A bundle as `.jsdos` archive is needed to execute the game in `js-dos`, as described in the
[documentation](https://js-dos.com/dos-games.html). The file should contain
[dosbox.conf](./release/jsdos/dosbox.conf), [jsdos.json](./release/jsdos/jsdos.json),
[readme.txt](./release/jsdos/readme.txt), and a [release] in the following structure:

```console
├── .jsdos
│   ├── dosbox.conf
│   ├── jsdos.json
│   └── readme.txt
└── JSSNAKE.EXE
```

© Jan-Philipp Kappmeier 1999

[release]: https://github.com/kappmeier/snakes/releases

