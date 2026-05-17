MD_DIR := md
ARTICLES_DIR := docs/articles
TEMPLATE := templates/article.html

FEED := docs/feed.xml
FEED_SCRIPT := scripts/generate-feed.py

MD_FILES := $(wildcard $(MD_DIR)/*.md)
HTML_FILES := $(patsubst $(MD_DIR)/%.md,$(ARTICLES_DIR)/%.html,$(MD_FILES))

.PHONY: all clean list

all: $(HTML_FILES) $(FEED)

$(ARTICLES_DIR)/%.html: $(MD_DIR)/%.md $(TEMPLATE) | $(ARTICLES_DIR)
	pandoc $< \
		--template=$(TEMPLATE) \
		--standalone \
		-o $@

$(ARTICLES_DIR):
	mkdir -p $(ARTICLES_DIR)

# RSS feed generation
$(FEED): $(MD_FILES) $(FEED_SCRIPT)
	$(FEED_SCRIPT)

clean:
	rm -f $(ARTICLES_DIR)/*.html $(FEED)

list:
	@printf '%s\n' $(HTML_FILES)
