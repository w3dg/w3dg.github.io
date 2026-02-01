.PHONY: serve content commit-and-deploy theme-update

serve:
	hugo server -D
content:
	@echo Try any of the following -
	@echo hugo new content content/posts/filename.md
	@echo hugo new content content/posts/dirname/index.md
	@echo hugo new content content/page.md
push-and-deploy:
	git switch main # ensure on main branch
	rm -rf public/ &2>/dev/null # delete public folder if there, it will be generated on the actions.
	git push origin main
	# wait for actions to complete and publish to gh-pages branch
theme-update:
	hugo mod get -u

help:
	@echo "make serve           - Run the local hugo server in draft mode"
	@echo "make content         - Create a new content file"
	@echo "make push-and-deploy - Push final committed code to Github for deployment"
	@echo "make theme-update    - Update theme with hugo submodule"
	@echo "make help            - Display this help message"
