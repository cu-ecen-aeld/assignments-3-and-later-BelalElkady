CC = gcc
SRC = writer.c
OBJ = writer

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