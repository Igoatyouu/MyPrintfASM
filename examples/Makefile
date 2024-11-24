
CC = gcc
CFLAGS = -Wall -Wextra
LDFLAGS = -L.. -lmyprintfasm

SRCS = basic_usage.c float_precision.c
BINS = $(SRCS:.c=)

all: $(BINS)

%: %.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
	rm -f $(BINS)

.PHONY: all clean
