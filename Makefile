all: install

install: build
	idris --install tomladris.ipkg

build: 
	idris --build tomladris.ipkg

clean:
	idris --clean tomladris.ipkg
