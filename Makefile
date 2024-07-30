ADAFRUIT_INDEX = --additional-urls https://adafruit.github.io/arduino-board-index/package_adafruit_index.json
SKETCH = main/main.ino

sketch:
	@if [ ! -f "main/hekate.h" ]; then \
        echo "hekate.h not found! Building payload..."; \
        make payload; \
    fi
	@echo "Building firmware..."
	arduino-cli core install adafruit:samd $(ADAFRUIT_INDEX)
	arduino-cli lib install "Adafruit DotStar" $(ADAFRUIT_INDEX)
	arduino-cli compile --fqbn adafruit:samd:adafruit_trinket_m0 $(SKETCH) --output-dir build
	@echo "Firmware built!"

uf2:
	@if [ ! -d "build" ]; then \
        echo "build folder does not exist! Building sketch..."; \
        make sketch; \
    fi
	@echo "Building UF2..."
	wget -q -nc https://raw.githubusercontent.com/microsoft/uf2/master/utils/uf2conv.py -P tmp
	wget -q -nc https://raw.githubusercontent.com/microsoft/uf2/master/utils/uf2families.json -P tmp
	python3 tmp/uf2conv.py build/main.ino.hex -f 0x68ed2b88 --output build/firmware.uf2
	@echo "UF2 built!"

payload:
	@echo "Building payload..."
	python3 tools/hekateDownloader.py
	python3 tools/binConverter.py hekate/hekate.bin
	mv hekate/hekate.h main/hekate.h
	@echo "Payload built!"

release:
	mkdir release
	cp build/firmware.uf2 release/firmware.uf2
	@echo "uf2 release finalized!"

clean:
	rm -rf build hekate tmp release

clean-header:
	rm main/hekate.h

clean-all:
	make clean
	make clean-header

all:
	make payload
	make sketch
	make uf2
	make release
