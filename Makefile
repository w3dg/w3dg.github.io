.PHONY: serve content commit-and-deploy theme-update clean

serve:
	hugo server -D
content:
	@echo Try any of the following -
	@echo hugo new content content/posts/filename.md
	@echo hugo new content content/posts/dirname/index.md
	@echo hugo new content content/page.md
push-and-deploy: clean
	git switch main # ensure on main branch
	git push origin main
	# wait for actions to complete and publish to gh-pages branch
theme-update:
	hugo mod get -u
clean:
	rm -rf public resources/ &2>/dev/null
	# delete public and generated resources folder if there, it will be generated on the actions.

help:
	@echo "make serve           - Run the local hugo server in draft mode"
	@echo "make content         - Create a new content file"
	@echo "make push-and-deploy - Push final committed code to Github for deployment"
	@echo "make theme-update    - Update theme with hugo submodule"
	@echo "make clean           - Clean the public folder and resources generated folders"
	@echo "make help            - Display this help message"
