.PHONY: help cleanup

.DEFAULT_GOAL := help
BLUE := \033[34m
RESET := \033[0m

help: ## Show this help message
	@echo 'Usage:'
	@echo '  make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

cleanup: ## Clean up build artifacts and dependencies
	@echo "Cleaning up project..."
	@flutter clean
	@rm -rf pubspec.lock
	@rm -rf ios/.symlinks
	@rm -rf ios/Pods
	@rm -f ios/Podfile.lock
	@flutter pub get
	@echo "Cleanup complete"

run-android: ## Run the application inside the default Android emulator
	@echo "Running application inside the default Android emulator..."
	@flutter run --device-id=emulator-5554

build-android: cleanup ## Build the application for Android
	@echo "Building Android application (app bundle)..."
	@flutter build appbundle --release --obfuscate --split-debug-info=./symbols
	@say "Android build complete"

run-ios: ## Run the app on the first available iOS device
	@echo "Running on iOS device..."
	@flutter run --device-id=$(shell flutter devices | awk -F'• ' '/ios/ {print $$2}' | head -n1)

build-ios: cleanup ## Build the application for iOS
	@echo "Building iOS application IPA..."
	@flutter build ipa --release --obfuscate --split-debug-info=./symbols
	@say "iOS build complete"