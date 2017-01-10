#!/bin/bash

#
# include config arrays
#
source ../status.sh
source ../globals.sh


#
# check unit tests
#
function unitTestsCheck {
	if [ -d "testing" ] && [ -d "testing/unittests" ] && [ -f "testing/unittests.sh" ]; then
		UNITTESTS_INSTALLED=1
	fi
}

function unitTestsSwitchToBasePath {
	if [ -n "${PREVIEW_PATH}" ] && [ -d "${PREVIEW_PATH}" ]; then
		cd "${PREVIEW_PATH}/testing/unittests/"
		echo "Preview path set, using `pwd` for unit tests."
	else
		cd "testing/unittests/"
		echo "No preview path set or path is invalid (${PREVIEW_PATH}), using `pwd` for unit tests."
	fi
}

function unitTestsInstall {
	if [ ! "${UNITTESTS_INSTALLED}" ]; then
		unitTestsPrepare
	fi

	./unittests.sh install
}

function unitTestsPrepare {
	if [ "${UNITTESTS_INSTALLED}" ]; then
		echo "Unit tests are already installed. Aborting.";
		exit 1;
	fi

	mkdir testing
	mkdir testing/tests
	touch testing/tests/.gitkeep
	mkdir testing/results
	touch testing/tests/.gitkeep

	git submodule add --force ssh://git@git.uebb.de:12022/typo3/unittests.git testing/unittests

	cd testing
	ln -s unittests/_.htaccess .htaccess
	cp unittests/unittests.json unittests.json

	cd tests
	ln -s ../unittests/common.php common.inc.php
	cd ../..

	echo "TYPO3 Unit testing prepared!"
	echo "Please edit project settings in \"testing/unittests/unittests.json\"."
	echo
	echo "Installing dependencies now ..."

	unitTestsCheck
	unitTestsInstall
}

function unitTestsUpdate {
	if [ ! "${UNITTESTS_INSTALLED}" ]; then
		echo "Unit tests are not yet prepared. Use \"./boil.sh unittests prepare\"."
		exit 1;
	fi

	./unittests.sh update
}

function unitTestsRun {
	if [ ! "${UNITTESTS_INSTALLED}" ]; then
		echo "Unit tests are not yet prepared. Use \"./boil.sh unittests prepare\"."
		exit 1;
	fi

	if [ -n "${CI_SERVER}" ]; then
		UNITTESTS_FILE="${CI_BUILD_REF:0:8}_${CI_BUILD_ID}"
	fi

	./unittests.sh run "${UNITTESTS_FILE}"
}
