# Set verbose=1 for command output
ifeq ($(verbose),1)
  q =
else
  q = @
endif

.PHONY: all clean dist

all: dist

dist:
	$(q)mkdir -p dist
	$(q)cp *.html dist/
	$(q)cp *.css dist/
	$(q)cp favicon.svg dist/
	$(q)cp -r fonts dist/

clean:
	$(q)rm -rf dist/
