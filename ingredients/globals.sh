#
# colors for output
#
RED="\033[0;31m"
GREEN="\033[0;32m"
ORANGE="\033[0;33m"
NC="\033[0m"

#
# global variables
#
DOCKERMODE=
COMPOSERINSTALL=
COMPOSERINSTALLNODEV=
COMPOSERUPDATE=
COMPOSERSELFUPDATE=
SSHKEYUSERHOME=
UNITTESTS_INSTALLED=

#
# gitlab-ci variables
#
# $CI_SERVER = yes
# $CI_SERVER_NAME = GitLab CI
# $CI_SERVER_VERSION = GitlabCi::Version
# $CI_SERVER_REVISION = GitlabCi::Revision
# $CI_BUILD_REF = current revision
# $CI_BUILD_BEFORE_SHA = previous revision sha
# $CI_BUILD_REF_NAME = revision name aka branch name
# $CI_BUILD_ID = number of build [1 .. x]

# ################################################ #
# MODIFY THE LINES BELOW TO FIT THEM TO YOUR NEEDS #
# ################################################ #
#
# your git branches to listen to for deployment
#
BRANCH_PREVIEW="deploy/staging"
BRANCH_LIVE="deploy/production"

#
# path to your preview instance
#
PREVIEW_PATH="/var/www/kunden.uebb.de/htdocs/uebb"
