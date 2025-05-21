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

run-android-emulator: ## Run the application inside the default Android emulator
	@echo "Running application inside the default Android emulator..."
	@flutter run --device-id=emulator-5554