
CC	=	gcc

SRC	=	$(addprefix src/,	\
		_my_printf.asm	\
		_my_buffchar.asm)

RM	=	rm -rf

OBJ	=	$(SRC:.asm=.o)

NAME	=	libmyprintfasm.so

all	:	$(NAME)

$(NAME)	:	$(OBJ)
	$(CC) -shared -nostdlib -o $(NAME) -fPIC $(OBJ)

clean	:
	$(RM) *~
	$(RM) $(OBJ)

fclean	:	clean
	$(RM) $(NAME)

re	:	fclean all

examples: $(NAME)
	$(MAKE) -C examples

%.o	:	%.asm
	nasm -f elf64 -o $@ $<

.PHONY	:	all clean fclean re %.o
