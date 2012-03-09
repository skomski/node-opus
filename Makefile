export REPORTER = BashTapReporter

build:
	@NODE_ENV=test ./node_modules/.bin/coffee --compile --output lib/ src/

test:
	@NODE_ENV=test ./node_modules/.bin/coffee test/run.coffee

.PHONY: test build
