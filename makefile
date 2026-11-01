ifeq ($(OS),Windows_NT)
    OPENSCAD ?= "C:/Program Files/OpenSCAD (Nightly)/openscad.exe"
    MKDIR     = powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '$(@D)' | Out-Null"
else
    SHELL    := /bin/bash
    OPENSCAD ?= openscad
    MKDIR     = mkdir -p "$(@D)"
endif

.PHONY: help setup build build-c3 build-c6 flash-c3 flash-c6 config-c3 config-c6 \
	logs-c6 flash-wait-c6 stl 3mf rev1 retro_futurist faceted rugged organic \
	base clamp button

help:
	@echo "Available targets:"
	@echo "  make base_rev1    - Build STLs for base_rev1"
	@echo "  make rev2         - Build STLs for rev2"
	@echo "  make stl          - Build all variant STLs"
	@echo

setup: ## Create venv and install ESPHome
	rm -rf .venv && \
	python3 -m venv .venv && \
	source .venv/bin/activate && \
	pip install esphome

build: build-c3 build-c6 ## Build C3 and C6 factory images

build-c3: ## Compile ESP32-C3 firmware
	source .venv/bin/activate && \
	esphome compile esphome-c3.yaml && \
	cp .esphome/build/single-button/build/firmware.factory.bin firmware-c3.bin

build-c6: ## Compile ESP32-C6 firmware
	source .venv/bin/activate && \
	esphome compile esphome-c6.yaml && \
	cp .esphome/build/single-button/build/firmware.factory.bin firmware-c6.bin

flash-c3: ## Flash ESP32-C3 (default /dev/ttyACM0)
	source .venv/bin/activate && \
	esphome upload esphome-c3.yaml --device /dev/ttyACM0

flash-c6: ## Flash ESP32-C6 (default /dev/ttyACM0)
	source .venv/bin/activate && \
	esphome upload esphome-c6.yaml --device /dev/ttyACM0

config-c3: ## Validate ESP32-C3 YAML
	source .venv/bin/activate && \
	esphome config esphome-c3.yaml

config-c6: ## Validate ESP32-C6 YAML
	source .venv/bin/activate && \
	esphome config esphome-c6.yaml

logs-c6: ## Stream serial logs from C6
	source .venv/bin/activate && \
	esphome logs esphome-c6.yaml --device /dev/ttyACM0

flash-wait-c6: ## Flash C6 repeatedly when /dev/ttyACM0 appears
	@source .venv/bin/activate && \
	PORT=/dev/ttyACM0; \
	YAML=esphome-c6.yaml; \
	echo "Waiting for $$PORT (Ctrl+C to stop)..."; \
	while true; do \
		while [[ ! -e $$PORT ]]; do sleep 0.5; done; \
		echo "Device detected — flashing C6..."; \
		if esphome upload $$YAML --device $$PORT; then \
			echo "Flash OK — unplug for next unit"; \
		else \
			echo "Flash FAILED"; \
		fi; \
		while [[ -e $$PORT ]]; do sleep 0.5; done; \
	done

# ==============================================================================
# OpenSCAD Rules
# ==============================================================================

case/%/models/base.stl: case/%/base.scad case/%/design.scad case/assets/common.scad
	@$(MKDIR)
	$(OPENSCAD) -o "$@" "$<"

case/%/models/clamp.stl: case/%/clamp.scad case/%/design.scad case/assets/common.scad
	@$(MKDIR)
	$(OPENSCAD) -o "$@" "$<"

case/%/models/button.stl: case/%/button.scad case/%/design.scad case/assets/common.scad
	@$(MKDIR)
	$(OPENSCAD) -o "$@" "$<"

# ==============================================================================
# Style & Part Targets (supports e.g. "make rugged", "make rugged button", "make button")
# ==============================================================================

STYLES := rev1 retro_futurist faceted rugged organic
PARTS  := base clamp button

SELECTED_STYLE := $(filter $(STYLES),$(MAKECMDGOALS))
SELECTED_PART  := $(filter $(PARTS),$(MAKECMDGOALS))

ifeq ($(words $(SELECTED_STYLE)),1)
  ifneq ($(SELECTED_PART),)
    # Both style and part specified: e.g. "make rugged button"
    $(SELECTED_STYLE): $(foreach p,$(SELECTED_PART),case/$(SELECTED_STYLE)/models/$(p).stl)
    $(SELECTED_PART):
	@:
  else
    # Style only: e.g. "make rugged"
    $(SELECTED_STYLE): case/$(SELECTED_STYLE)/models/base.stl case/$(SELECTED_STYLE)/models/clamp.stl case/$(SELECTED_STYLE)/models/button.stl
  endif
else
  # Default style targets
  rev1: case/rev1/models/base.stl case/rev1/models/clamp.stl case/rev1/models/button.stl ## Build rev1 STLs
  retro_futurist: case/retro_futurist/models/base.stl case/retro_futurist/models/clamp.stl case/retro_futurist/models/button.stl ## Build retro_futurist STLs
  faceted: case/faceted/models/base.stl case/faceted/models/clamp.stl case/faceted/models/button.stl ## Build faceted STLs
  rugged: case/rugged/models/base.stl case/rugged/models/clamp.stl case/rugged/models/button.stl ## Build rugged STLs
  organic: case/organic/models/base.stl case/organic/models/clamp.stl case/organic/models/button.stl ## Build organic STLs
endif

# Part-only targets: e.g. "make button" builds all buttons
ifeq ($(SELECTED_STYLE),)
base: $(foreach s,rev1 retro_futurist faceted rugged,case/$(s)/models/base.stl) ## Build base STLs for all styles
clamp: $(foreach s,rev1 retro_futurist faceted rugged,case/$(s)/models/clamp.stl) ## Build clamp STLs for all styles
button: $(foreach s,rev1 retro_futurist faceted rugged,case/$(s)/models/button.stl) ## Build button STLs for all styles
endif

# Global target
stl: rev1 retro_futurist faceted rugged ## Build all style STLs

3mf: ## Generate 3MF files