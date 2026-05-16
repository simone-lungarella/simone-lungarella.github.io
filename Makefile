MD_DIR := md
ARTICLES_DIR := docs/articles
TEMPLATE := templates/article.html

MD_FILES := $(wildcard $(MD_DIR)/*.md)
HTML_FILES := $(patsubst $(MD_DIR)/%.md,$(ARTICLES_DIR)/%.html,$(MD_FILES))

.PHONY: all clean list

all: $(HTML_FILES)

$(ARTICLES_DIR)/%.html: $(MD_DIR)/%.md $(TEMPLATE) | $(ARTICLES_DIR)
	pandoc $< \
		--template=$(TEMPLATE) \
		--standalone \
		-o $@

$(ARTICLES_DIR):
	mkdir -p $(ARTICLES_DIR)

clean:
	rm -f $(ARTICLES_DIR)/*.html

list:
	@printf '%s\n' $(HTML_FILES)
