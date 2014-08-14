CC=arm-apple-darwin9-gcc
LD=$(CC)
LDFLAGS=-lobjc -dynamiclib -bind_at_load -F"/System/Library/PrivateFrameworks" -framework CoreTelephony -framework CoreFoundation -framework Foundation -framework UIKit -framework CoreGraphics -framework SystemConfiguration
CFLAGS=-fconstant-cfstrings -std=gnu99 -Wall -O2 -I/var/include -I..
VERSION=1.0

all:    Toggle.dylib

Toggle.dylib: Toggle.o
	$(LD) $(LDFLAGS) -o $@ $^
	/usr/bin/ldid -S Toggle.dylib

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
	   
%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o edge


