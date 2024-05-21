CC = gcc
SRC = writer.c
OBJ = output.o

ifeq ($(CROSS_COMPILE),)
	CC = gcc
else
	CC =$(CROSS_COMPILE)gcc
endif

all:
	$(CC) $(SRC) -o  $(OBJ)
clean:
	rm -f $(OBJ)
print-CC:
	@echo $(CC)