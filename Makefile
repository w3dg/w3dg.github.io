.PHONY: serve content commit-and-deploy theme-update clean lint

serve:
	@# hugo server -D
	hugo server --disableFastRender --bind=0.0.0.0 --baseURL=http://0.0.0.0:1313 -D

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

lint-full:
	# vale sync
	fd --full-path './content' -e md  | xargs vale

lint:
	vale $(f)

help:
	@echo "make serve           - Run the local hugo server in draft mode"
	@echo "make content         - Create a new content file"
	@echo "make push-and-deploy - Push final committed code to Github for deployment"
	@echo "make theme-update    - Update theme with hugo submodule"
	@echo "make clean           - Clean the public folder and resources generated folders"
	@echo "make lint-full       - Run Vale with defined settings for linting in all dirs"
	@echo "make lint f=file.md  - Run Vale with defined settings for linting the file specfied"
	@echo "make help            - Display this help message"
