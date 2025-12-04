serve:
	hugo server --buildDrafts
content:
	@echo Try any of the following:
	@echo hugo new content content/posts/filename.md
	@echo hugo new content content/posts/dirname/index.md
	@echo hugo new content content/page.md
theme-update:
	hugo mod get -u
