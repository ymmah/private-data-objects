#!/bin/bash

# Copyright 2018 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPTDIR="$(dirname $(readlink --canonicalize ${BASH_SOURCE}))"
PDO_SOURCE_ROOT="$(realpath ${SCRIPTDIR}/..)"

typeset -a env_key_sort
typeset -A env_val env_desc
typeset -i i

# Note: this is function so we can delay until optional -r is evaluated ...
var_set() {

	i=0

	env_val[TINY_SCHEME_SRC]="${TINY_SCHEME_SRC:-/}"
	env_desc[TINY_SCHEME_SRC]="
		TINY_SCHEME_SRC points to the installation of the tinyscheme
		source in order to build the library used to debug and test
		contracts outside of the contract enclave
	"
	env_key_sort[$i]="TINY_SCHEME_SRC"; i=$i+1; export TINY_SCHEME_SRC=${env_val[TINY_SCHEME_SRC]};

	env_val[SGX_MODE]="${SGX_MODE:-SIM}"
	env_desc[SGX_MODE]="
		SGX_MODE determines the SGX mode of operation. When the variable is
		set to 'SIM', then the SGX enclaves will be compiled for simulator
		mode. When the variable is set to 'HW', the enclaves will be compiled
		to run in a real SGX enclave.
	"
	env_key_sort[$i]="SGX_MODE"; i=$i+1; export SGX_MODE=${env_val[SGX_MODE]}

	env_val[SGX_DEBUG]="${SGX_DEBUG:-1}"
	env_desc[SGX_DEBUG]="
		SGX_DEBUG determines whether additional debugging functions
		will be compiled into the enclaves. Since SGX_DEBUG potentially
		exposes information about what is happening inside a contract, do
		not use with confidential contracts.
	"
	env_key_sort[$i]="SGX_DEBUG"; i=$i+1; export SGX_DEBUG=${env_val[SGX_DEBUG]}

	env_val[PDO_LEDGER_URL]="${PDO_LEDGER_URL:-http://127.0.0.1:8008}"
	env_desc[PDO_LEDGER_URL]="
		PDO_PDO_LEDGER_URL is the URL is to submit transactions to the
		Sawtooth ledger.
	"
	env_key_sort[$i]="PDO_LEDGER_URL"; i=$i+1; export PDO_LEDGER_URL=${env_val[PDO_LEDGER_URL]}

	env_val[PDO_INSTALL_ROOT]="${PDO_INSTALL_ROOT:-${SCRIPTDIR}/_dev}"
	env_desc[PDO_INSTALL_ROOT]="
		PDO_INSTALL_ROOT is the root of the directory in which the virtual
		enviroment will be built; this is equivalent to the old DSTDIR,
		generally PDO_HOME will point to PDO_INSTALL_ROOT/opt/pdo
	"
	env_key_sort[$i]="PDO_INSTALL_ROOT"; i=$i+1; export PDO_INSTALL_ROOT=${env_val[PDO_INSTALL_ROOT]}

	env_val[PDO_HOME]="${PDO_HOME:-${PDO_INSTALL_ROOT}/opt/pdo}"
	env_desc[PDO_HOME]="
		PDO_HOME is the directory where PDO-specific files
		are stored include configuration files, data files, compiled
		contracts, contract user keys and service scripts.
	"
	env_key_sort[$i]="PDO_HOME"; i=$i+1; export PDO_HOME=${env_val[PDO_HOME]}

	env_val[PDO_SGX_KEY_ROOT]="${PDO_SGX_KEY_ROOT:-${SCRIPTDIR}/keys/sgx_simulation/}"
	env_desc[PDO_SGX_KEY_ROOT]="
		PDO_SGX_KEY_ROOT is the root directory where SGX & IAS related keys are stored.
		The default points to a directory which contains values which are good
		enough for SGX simulator mode.  However, for SGX HW mode you
		should provide your own version, at least for PDO_SPID and PDO_SPID_KEY_CERT_FILE_PEM
	"
	env_key_sort[$i]="PDO_SGX_KEY_ROOT"; i=$i+1; export PDO_SGX_KEY_ROOT=${env_val[PDO_SGX_KEY_ROOT]}

	env_val[PDO_ENCLAVE_CODE_SIGN_PEM]="${PDO_ENCLAVE_CODE_SIGN_PEM:-${PDO_SGX_KEY_ROOT}/enclave_code_sign.pem}"
	env_desc[PDO_ENCLAVE_CODE_SIGN_PEM]="
		PDO_ENCLAVE_CODE_SIGN_PEM contains the name of the file containing the key
		used to sign the enclave. This key must be white-listed with IAS to work for
                production-mode/default launch-control.  For non-production use, in simulator or HW mode,
                the key can generated by the command:
		    openssl genrsa -3 -out ${PDO_ENCLAVE_CODE_SIGN_PEM} 3072.
                The default path points to a key which is generated during built on-demand.
	"
	env_key_sort[$i]="PDO_ENCLAVE_CODE_SIGN_PEM"; i=$i+1; export PDO_ENCLAVE_CODE_SIGN_PEM=${env_val[PDO_ENCLAVE_CODE_SIGN_PEM]}

	env_val[PDO_IAS_KEY_PEM]="${PDO_IAS_KEY_PEM:-${PDO_SGX_KEY_ROOT}/sgx_ias_key.pem}"
	env_desc[PDO_IAS_KEY_PEM]="
		The path of the PEM file containing the public key used to verify
		attestation verification reports from the Intel Attestation Service.
		Note this is _not_ the IAS root CA's key but directly the key of the
		signing authority, i.e., the key contained in the first certificate
		contained in the 'x-iasreport-signing-certificate' header of the
		response from IAS.
		Easiest way to get it is from the sawtooth poet git repo as https://raw.githubusercontent.com/hyperledger/sawtooth-poet/master/sgx/packaging/ias_rk_pub.pem
	"
	env_key_sort[$i]="PDO_IAS_KEY_PEM"; i=$i+1; export PDO_IAS_KEY_PEM=${env_val[PDO_IAS_KEY_PEM]}

	env_val[PDO_SPID]="${PDO_SPID:-$(cat ${PDO_SGX_KEY_ROOT}/sgx_spid.txt)}"
	env_desc[PDO_SPID]="
		PDO_SPID is the ID that accompanies the certificate registered
		with the Intel Attestation Service. This should be a 32 character
		hex string.
	"
	env_key_sort[$i]="PDO_SPID"; i=$i+1; export PDO_SPID=${env_val[PDO_SPID]}

	env_val[PDO_SPID_KEY_CERT_FILE_PEM]="${PDO_SPID_KEY_CERT_FILE_PEM:-${PDO_SGX_KEY_ROOT}/sgx_spid_key_cert.pem}"
	env_desc[PDO_SPID_KEY_CERT_FILE_PEM]="
		PDO_SPID_KEY_CERT_FILE_PEM is the name of the file that contains the
		PEM-encoded certificate, that was submitted to Intel in order to
		obtain the SPID, as well as the corresponding private key.
	"
	env_key_sort[$i]="PDO_SPID_KEY_CERT_FILE_PEM"; i=$i+1; export PDO_SPID_KEY_CERT_FILE_PEM=${env_val[PDO_SPID_KEY_CERT_FILE_PEM]}

	env_val[PDO_STL_KEY_ROOT]="${PDO_STL_KEY_ROOT:-${PDO_INSTALL_ROOT}/opt/pdo/etc/keys/sawtooth}"
	env_desc[PDO_STL_KEY_ROOT]="
		PDO_STL_KEY_ROOT is the root directory where the system keys are stored
		for Sawtooth integration; files in this directory
		are not automatically generated.
	"
	env_key_sort[$i]="PDO_STL_KEY_ROOT"; i=$i+1; export PDO_STL_KEY_ROOT=${env_val[PDO_STL_KEY_ROOT]}

	env_val[PDO_LEDGER_KEY_SKF]="${PDO_LEDGER_KEY_SKF:-${PDO_STL_KEY_ROOT}/pdo_validator.priv}"
	env_desc[PDO_LEDGER_KEY_SKF]="
		PDO_LEDGER_KEY_SKF is used to update settings in the Sawtooth validator.
		This is the key used by the Sawtooth ledger and is generally
		found in the file .sawtooth/keys/sawtooth.priv in the
		Sawtooth installation directory hiearchy.
	"
	env_key_sort[$i]="PDO_LEDGER_KEY_SKF"; i=$i+1; export PDO_LEDGER_KEY_SKF=${env_val[PDO_LEDGER_KEY_SKF]}
	}

do_export() {
	for i in "${!env_key_sort[@]}"
	do
		ki="${env_key_sort[$i]}"
		export "$ki=${env_val[$ki]}"
	done
}

print_export() {
	for i in "${!env_key_sort[@]}"
	do
		ki="${env_key_sort[$i]}"
		echo "export $ki=${env_val[$ki]}"
	done
}

help() {
    echo 'common-config.sh -[--reset-keys|-r] [--evalable-export|-e] [--help|-h|-?]

This script can be used to set the environment variables that are
used in the build, installation & execution process. While the build should
progress with only the default values specified, commonly four
variables are set and then this file is evaluated. These four
variables are: TINY_SCHEME_SRC, PDO_LEDGER_URL, PDO_INSTALL_ROOT,
and PDO_STL_KEY_ROOT. In case you run in SGX HW mode you usally
will define PDO_SGX_KEY_ROOT. See further down information on these
variables and others you could override from defaults.

The default usage of this script is to be sourced. For example,
local configuration file may be constructed as:

   export PDO_STL_KEY_ROOT=${HOME}/keys
   export PDO_INSTALL_ROOT=${HOME}/pdo-test-env
   export PDO_LEDGER_URL=http://127.0.0.1:8008
   export TINY_SCHEME_SRC=${HOME}/tinyscheme-1.41

and before buidling it you call script as

   source ${SCRIPTDIR}/common-config.sh

If passed the parameter --evalable-export it will
return a list of export commands of the variables
instead of directly exporting them to the environment.
Passing parameter --reset-keys will unset keying variables
PDO_ENCLAVE_CODE_SIGN_PEM, PDO_IAS_KEY_PEM, PDO_LEDGER_KEY_SKF,
PDO_SPID and PDO_SPID_KEY_CERT_FILE_PEM before setting variables.

The list of variables set (in order they are defined, their defaults
and semantics is as follows:

'

	for i in "${!env_key_sort[@]}"
	do
		ki="${env_key_sort[$i]}"
		echo "$ki (default: ${env_val[$ki]}): ${env_desc[$ki]}"
	done
}

is_sourced=1

while [[ $# > 0 ]]
do
    opt=$1
    case $opt in
        --reset-keys|-r)
	    # -----------------------------------------------------------------
	    # if you change either PDO_SGX_KEY_ROOT or PDO_STL_KEY_ROOT variable
            # and re-source this file you should unset all of the variables that
            # depend on those variables
	    # -----------------------------------------------------------------
	    unset PDO_ENCLAVE_CODE_SIGN_PEM
	    unset PDO_IAS_KEY_PEM
	    unset PDO_LEDGER_KEY_SKF
	    unset PDO_SPID
	    unset PDO_SPID_KEY_CERT_FILE_PEM
            ;;
        --evalable-export|-e)
	    is_sourced=0
	    ;;
        --help|-h|-\?)
	    var_set
	    help
	    exit 0
	    ;;
	*)
            echo "ERROR: unknown option $opt. Run with option -h to get valid options"
	    exit 1
    esac
    shift # past argument or value
done

var_set
if [ $is_sourced == 1 ]; then
    do_export
else
    print_export
fi
