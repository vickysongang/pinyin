version = $(shell cat package.json | grep version | awk -F'"' '{print $$4}')

install:
	@spm install
	@npm install

build:
	@spm build

publish: build publish-doc
	@spm publish
	@npm publish
	@git tag $(version)
	@git push origin $(version)

build-doc:
	@spm doc build

watch:
	@spm doc watch

publish-doc: clean build-doc
	@ghp-import _site
	@git push origin gh-pages

clean:
	@rm -fr _site


runner = _site/tests/runner.html

test-npm:
	@mocha -R spec tests/test.js

test-spm:
	@spm test

test: test-npm test-spm

output = _site/coverage.html
coverage: build-doc
	@rm -fr _site/src-cov
	@jscoverage --encoding=utf8 src _site/src-cov
	@mocha-browser ${runner}?cov -S -R html-cov > ${output}
	@echo "Build coverage to ${output}"


ZI_DICT_FREQUENT = ./tools/dict/zi-frequent.js
ZI_DICT_INFREQUENT = ./tools/dict/zi-infrequent.js
ZI_DICT= ./tools/dict/dict-zi.js

dict-web:
	@echo 'module.exports = {'        >  $(ZI_DICT_FREQUENT)
	@node ./tools/robot-frequent.js   >> $(ZI_DICT_FREQUENT)
	@echo '};'                        >> $(ZI_DICT_FREQUENT)
	@echo 'module.exports = {'        >  $(ZI_DICT_INFREQUENT)
	@node ./tools/robot-infrequent.js >> $(ZI_DICT_INFREQUENT)
	@echo '};'                        >> $(ZI_DICT_INFREQUENT)

dict-node:
	@echo 'var dict = [];'            >  $(ZI_DICT)
	@node ./tools/robot-zdic-zi.js    >> $(ZI_DICT)
	@echo 'module.exports = dict;'    >> $(ZI_DICT)

infrequent:
	@node ./tools/infrequent.js > ./tools/zi/infrequent.js

.PHONY: build-doc publish-doc server clean test coverage
