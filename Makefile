serve:
	hugo server --buildDrafts
build:
	hugo build -d docs --minify
content:
	hugo new content <SECTIONNAME>/<FILENAME>.<FORMAT>
theme-update:
	hugo mod get -u
