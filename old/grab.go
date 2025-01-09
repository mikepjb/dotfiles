package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"unicode"

	"golang.org/x/sys/unix"
)

func main() {

	restoreFunc, err := rawMode()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err)
		os.Exit(1)
	}
	defer restoreFunc()

	r := bufio.NewReader(os.Stdin)

	for {
		ru, _, err := r.ReadRune()

		if err == io.EOF {
			break
		} else if err != nil {
			fmt.Fprintf(os.Stderr, "Error: reading key from Stdin: %s\n", err)
			os.Exit(1)
		}
		if unicode.IsControl(ru) {
			fmt.Printf("%d\n", ru)
		} else {
			fmt.Printf("%d (%c)\n", ru, ru)
		}

		if ru == 'q' {
			break
		}
	}
}

// rawMode modifies terminal settings to enable raw mode in a platform specific
// way. It returns a function that can be invoked to restore previous settings.
func rawMode() (func(), error) {

	termios, err := unix.IoctlGetTermios(unix.Stdin, unix.TCGETS)
	if err != nil {
		return nil, fmt.Errorf("rawMode: error getting terminal flags: %w", err)
	}

	copy := *termios

	termios.Lflag = termios.Lflag &^ (unix.ECHO | unix.ICANON | unix.ISIG)

	if err := unix.IoctlSetTermios(unix.Stdin, unix.TCSETSF, termios); err != nil {
		return nil, fmt.Errorf("rawMode: error setting terminal flags: %w", err)
	}

	return func() {
		if err := unix.IoctlSetTermios(unix.Stdin, unix.TCSETSF, &copy); err != nil {
			fmt.Fprintf(os.Stderr, "rawMode: error restoring originl console settings: %s", err)
		}
	}, nil
}
