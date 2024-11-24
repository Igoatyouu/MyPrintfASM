# MyPrintfASM

A printf implementation written in x86_64 assembly (NASM syntax) with buffered output. This library provides a lightweight alternative to the standard printf function, supporting basic format specifiers.

## Features

- Written entirely in x86_64 assembly
- Buffered output with automatic flush
- Supports the following format specifiers:
  - `%s`: String output
  - `%c`: Character output
  - `%d`: Decimal integer output
  - `%f`: Floating-point output with precision control

## Project Structure

```
.
├── README.md
├── Makefile
├── src/
│   ├── my_buffchar.asm
│   └── my_printf.asm
├── examples/
│   ├── basic_usage.c
│   ├── float_precision.c
│   └── Makefile
└── tests/
    └── functional/
        ├── test_basic.c
        ├── test_float.c
        └── Makefile
```

## Building

To build the library:

```bash
make        # Builds libmyprintfasm.so
make clean  # Removes object files
make fclean # Removes everything including the library
make re     # Rebuilds everything
```

## Usage

1. Build the library using `make`
2. Link your program with the library using:
   ```bash
   gcc your_program.c -L. -lmyprintfasm -o your_program
   ```
3. Run your program:
   ```bash
   LD_LIBRARY_PATH=. ./your_program
   ```

### Example

```c
#include <stdarg.h>

int _my_printf(const char *format, ...); // Function prototype

int main(void)
{
    _my_printf("Hello %s!\n", "world");
    _my_printf("Number: %d\n", 42);
    _my_printf("Float with 2 decimals: %f\n", 3.14159, 2);
    return 0;
}
```

### Format Specifiers

- `%s`: Prints a null-terminated string
- `%c`: Prints a single character
- `%d`: Prints a decimal integer
- `%f`: Prints a floating-point number with precision
  - Requires an additional integer argument for precision
  - Example: `my_printf("%.3f\n", 3.14159, 3)` prints "3.142"

## Technical Details

### Buffer System

The output is buffered using an internal buffer system that automatically flushes:
- When the buffer is full
- When encountering a newline character
- When the program exits (using GCC's `_fini` mechanism)

### Assembly Implementation

The library is implemented in NASM syntax for x86_64 architecture. Key features include:
- SSE instructions for floating-point operations
- System calls for I/O operations
- Stack frame manipulation for handling variadic arguments

## Building from Source

Requirements:
- NASM assembler
- GCC compiler
- GNU Make
- Linux x86_64 system
