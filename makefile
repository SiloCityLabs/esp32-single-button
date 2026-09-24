.PHONY: help
SHELL := /bin/bash

help:
	@echo "Available targets:"
	@echo
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
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
		echo "[$$(date '+%H:%M:%S')] Device detected — flashing C6..."; \
		if esphome upload $$YAML --device $$PORT; then \
			echo "[$$(date '+%H:%M:%S')] Flash OK — unplug for next unit"; \
		else \
			echo "[$$(date '+%H:%M:%S')] Flash FAILED"; \
		fi; \
		while [[ -e $$PORT ]]; do sleep 0.5; done; \
	done
