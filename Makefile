.PHONY: help serve build clean deploy preview new-post update-theme check-links format

# Default target
help:
	@echo "Available targets:"
	@echo "  serve        - Run Hugo development server with drafts"
	@echo "  build        - Build production site"
	@echo "  clean        - Clean public directory"
	@echo "  deploy       - Deploy to Netlify (requires Netlify CLI)"
	@echo "  preview      - Preview Netlify deploy locally"
	@echo "  new-post     - Create a new blog post (usage: make new-post TITLE=\"My Post\")"
	@echo "  update-theme - Update PaperMod theme"
	@echo "  check-links  - Check for broken links"
	@echo "  format       - Format markdown files"

# Development server
serve:
	hugo server -D --bind 0.0.0.0

# Build production site
build:
	hugo --minify

# Clean build artifacts
clean:
	rm -rf public/ resources/_gen/

# Deploy to Netlify
deploy: build
	netlify deploy --prod --dir=public

# Preview Netlify deploy
preview: build
	netlify deploy --dir=public

# Create new blog post
new-post:
	@if [ -z "$(TITLE)" ]; then \
		echo "Error: TITLE is required. Usage: make new-post TITLE=\"My Post\""; \
		exit 1; \
	fi
	hugo new posts/$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-').md

# Update theme
update-theme:
	git submodule update --init --recursive
	git submodule update --remote --merge

# Check for broken links
check-links: build
	@echo "Checking for broken links..."
	@command -v htmltest >/dev/null 2>&1 || { echo "htmltest not installed. Install with: curl https://htmltest.wjdp.uk | bash"; exit 1; }
	htmltest public/

# Format markdown files
format:
	@command -v prettier >/dev/null 2>&1 || { echo "prettier not installed. Install with: npm install -g prettier"; exit 1; }
	prettier --write "content/**/*.md" "README.md" "CONTRIBUTING.md"