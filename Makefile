# ===============================
# Config
# ===============================

# Source directory containing markdown files
MD_DIR := md

# Output directory for generated HTML articles
ARTICLES_DIR := docs/articles

# HTML template used by Pandoc
TEMPLATE := templates/article.html

# RSS feed output file
FEED := docs/feed.xml

# Script that generates the RSS feed
FEED_SCRIPT := scripts/generate-feed.py

# ===============================
# File discovery
# ===============================

# All markdown files
MD_FILES := $(wildcard $(MD_DIR)/*.md)

# Map markdown → html (same filename, different path/extension)
HTML_FILES := $(patsubst $(MD_DIR)/%.md,$(ARTICLES_DIR)/%.html,$(MD_FILES))

# ===============================
# Phony targets (not real files)
# ===============================

.PHONY: all clean list help

# Default target
all: $(HTML_FILES) $(FEED)

# ===============================
# Build rules
# ===============================

# Rule: build each HTML article from its Markdown source
#
# $< = first dependency (the .md file)
# $@ = target file (the .html file)
#
# Order-only dependency (|) ensures directory exists
# but does NOT trigger rebuilds if directory timestamp changes
$(ARTICLES_DIR)/%.html: $(MD_DIR)/%.md $(TEMPLATE) | $(ARTICLES_DIR)
	pandoc $< \
		--template=$(TEMPLATE) \
		--standalone \
		-o $@

# Ensure output directory exists
$(ARTICLES_DIR):
	mkdir -p $(ARTICLES_DIR)

# ===============================
# RSS feed generation
# ===============================

# Feed depends on:
# - all markdown files (content changes)
# - feed generator script (logic changes)
#
# If any of these change → feed is regenerated
$(FEED): $(MD_FILES) $(FEED_SCRIPT)
	$(FEED_SCRIPT)

# ===============================
# Utility targets
# ===============================

# Remove generated files
clean:
	rm -f $(ARTICLES_DIR)/*.html $(FEED)

# List generated HTML targets
list:
	@printf '%s\n' $(HTML_FILES)

# Help target
help:
	@echo "Available targets:"
	@echo "  make        - Build all articles and RSS feed"
	@echo "  make clean  - Remove generated files"
	@echo "  make list   - List generated HTML files"
	@echo "  make help   - Show this message"
