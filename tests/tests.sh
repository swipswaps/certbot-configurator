#!/bin/bash
# file: tests/run.sh

set -e

[ ! -z ${TEST_SCRIPT} ] || TEST_SCRIPT=../install.sh
TEST_SCRIPT_FULL_PATH=$(cd $(dirname ${TEST_SCRIPT}); pwd | tr '\r\n' '/'; echo $(basename ${TEST_SCRIPT}))

# Scripts possible options
STANDALONE_MODE=standalone
WEBROOT_MODE=webroot
WEBROOT_FOLDER=/tmp
FAKE_MODE=fake
[ -z "${DOMAIN_NAME}" ] && DOMAIN_NAME=test.local.com
FAKE_DOMAIN_NAME=fake.local.com
IP_ADDRESS=127.0.0.1
ENABLE_DRY_RUN_MODE="export DRY_RUN=true;"
DISABLE_DRY_RUN_MODE="export DRY_RUN=false;"
CHECK_ONLY_OPTION="--check-only"
#
SUDO=sudo

# Check if ${TEST_SCRIPT} is available for testing
if [ ! -e "${TEST_SCRIPT}" ] || [ ! -x "${TEST_SCRIPT}" ]; then
    error "Can not be found script for testing! Was declared, that it is located by path: ${TEST_SCRIPT_FULL_PATH}; pwd).Please fix."
fi

testing_00_application_without_root_rights() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${TEST_SCRIPT} ${OPTIONS} -m ${STANDALONE_MODE} --domain-name ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_not_equals 0 ${rtrn} "Must be error without administrative rights."
    assert_equals "ERROR! Administrative rights are required." "${STDOUT}" "Checking root rights required failed."
}

testing_01_application_with_root_rights() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} --domain-name ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code by running application with root rights."
}

testing_02_fake_domain_name_option() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} -d ${FAKE_DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals "ERROR! Was defined incorrect domain name." "${STDOUT}" "Incorrect error message on checking domain name option with fake value."
    assert_equals 1 ${rtrn} "Incorrect exit code on testing domain name option with fake value."
}

testing_03_help_option() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} --help)
    rtrn=$?
    # TODO. Describe this test
}

testing_04_unknown_option() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} --test)
    rtrn=$?
    assert_equals "ERROR! Unknown option. See help." "${STDOUT}" "Incorrect error message when it is used unknown option."
    assert_equals 1 ${rtrn} "Incorrect exit code."
}

testing_05_mode_options_checking() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code by running application in ${STANDALONE_MODE} mode."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${WEBROOT_MODE} -r ${WEBROOT_FOLDER} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code by running application in ${WEBROOT_MODE} mode."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} --mode ${WEBROOT_MODE} --root ${WEBROOT_FOLDER} --domain-name ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code by running application in ${WEBROOT_MODE} mode by using long option name --mode."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${FAKE_MODE} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals "ERROR! Unsupported mode. See help." "${STDOUT}" "Incorrect message when it is specified incorrect mode."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals "ERROR! Domain name is required. See help." "${STDOUT}" "Incorrect message when domain name was not defined."
    assert_equals 1 ${rtrn} "Incorrect exit code by running application without defined domain name option."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${WEBROOT_MODE} -r ${WEBROOT_FOLDER} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code by running with a correct --root option in webroot mode."
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${WEBROOT_MODE} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_not_equals 0 ${rtrn} "Without option --root in webroot mode must fail."
}

testing_06_domain_name_option() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} -d ${DOMAIN_NAME} ${CHECK_ONLY_OPTION})
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code on testing domain name option."
}

testing_07_certbot_installation() {
    ${ENABLE_DRY_RUN_MODE}
    STDOUT=$(${SUDO} ${TEST_SCRIPT} -m ${STANDALONE_MODE} -d ${DOMAIN_NAME} --skip-certificate-retrieving)
    rtrn=$?
    assert_equals 0 ${rtrn} "Incorrect exit code of testing the installation."
}
