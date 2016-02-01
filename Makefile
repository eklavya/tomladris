all: install

install: build
	idris --install tomladris.ipkg

build: Tomli/*.idr
	idris --build tomladris.ipkg

clean:
	idris --clean tomladris.ipkg
