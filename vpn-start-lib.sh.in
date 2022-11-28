#!/usr/bin/env bash
#
# vpn-start-lib.sh
# Home: https://github.com/glevand/vpn-start
#

on_exit() {
	local result=${1}

	local sec="${SECONDS}"

	echo "${script_name}: Done: ${result}, ${sec} sec." >&2
}

on_err() {
	local f_name=${1}
	local line_no=${2}
	local err_no=${3}

	echo "${script_name}: ERROR: function=${f_name}, line=${line_no}, result=${err_no}" >&2

	exit "${err_no}"
}

print_project_banner() {
	echo "${script_name} (@PACKAGE_NAME@) - ${start_time}"
}

check_file() {
	local msg="${1}"
	local file="${2}"

	if [[ ! -f "${file}" ]]; then
		echo "${script_name}: ERROR: ${msg} not found: '${file}'" >&2
		exit 1
	fi
}

check_program() {
	local prog="${1}"
	local path="${2}"

	if ! test -x "$(command -v "${path}")"; then
		echo "${script_name}: ERROR: Please install '${prog}'." >&2
		exit 1
	fi
}

get_subnet() {
	local -n _get_subnet__subnet="${1}"

	_get_subnet__subnet=''

	local regex_ip='((([[:digit:]]{1,3}\.){3})[[:digit:]]{1,3})'
	local regex_mask='(([[:digit:]]){1,2})'
	local regex_data="${regex_ip}/${regex_mask}"

	local -a data_array
	data_array=($(ip a))

	local data_count="${#data_array[@]}"

	local id
	local data

	for (( id = 1; id <= ${data_count}; id++ )); do
		data="${data_array[$(( id - 1 ))]}"

		if [[ "${data}" =~ ${regex_data} ]]; then

			if [[ ${verbose} ]]; then
				echo '------------------------'
				echo "${id}: ${data}"
				echo "${id}: addr   = '${BASH_REMATCH[1]}'"
				echo "${id}: subnet = '${BASH_REMATCH[2]}0'"
				echo "${id}: mask   = '${BASH_REMATCH[4]}'"
			fi

			if [[ "${BASH_REMATCH[1]}" == '127.0.0.1' ]]; then
				continue
			fi

			_get_subnet__subnet="${BASH_REMATCH[2]}0/${BASH_REMATCH[4]}"
			break
		fi
	done

	if [[ ${verbose} ]]; then
		echo '------------------------'
	fi

	if [[ ! ${_get_subnet__subnet} ]]; then
		echo 'ERROR: Could not detect subnet.' >&2
		exit 1
	fi
}
