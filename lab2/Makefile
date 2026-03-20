CC = gcc
CFLAGS = -Wall -Wextra -g

all: shell_mode1 shell_mode2 shell_mode2_opt

shell_mode1: shell_mode1.c
	$(CC) $(CFLAGS) -o $@ $^

shell_mode2: shell_mode2.c
	$(CC) $(CFLAGS) -o $@ $^

shell_mode2_opt: shell_mode2_opt.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f shell_mode1 shell_mode2 shell_mode2_opt
