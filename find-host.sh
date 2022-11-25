#!/usr/bin/env bash

usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Search for hosts on a subnet."
		echo "Usage: ${script_name} [flags]"
		echo "Option flags:"
		echo "  -t --host     - Host to search for. Can be {all, any}.  Default: '${host}'."
		echo "  -s --subnet   - Subnet to search.  Default: '${subnet}'."
		echo "  -u --user     - User. Default: '${user}'."
		echo "  -c --config   - Configuration file. Default: '${config_file}'."
		echo "  -h --help     - Show this help and exit."
		echo "  -v --verbose  - Verbose execution. Default: '${verbose}'."
		echo "  -g --debug    - Extra verbose execution. Default: '${debug}'."
		echo "  -d --dry-run  - Dry run, don't do logins."
		echo "Info:"
		echo "  ${script_name} - Version: @PACKAGE_VERSION@"
		echo "  Project Home: @PACKAGE_URL@"
	} >&2
	eval "${old_xtrace}"
}

process_opts() {
	local short_opts="t:s:u:c:hvgd"
	local long_opts="host:,subnet:,user:,config:,help,verbose,debug,dry-run"

	local opts
	opts=$(getopt --options ${short_opts} --long ${long_opts} -n "${script_name}" -- "$@")

	eval set -- "${opts}"

	while true ; do
		# echo "${FUNCNAME[0]}: (${#}) '${*}'"
		case "${1}" in
		-t | --host)
			host="${2}"
			shift 2
			;;
		-s | --subnet)
			subnet="${2}"
			shift 2
			;;
		-u | --user)
			user="${2}"
			shift 2
			;;
		-c | --config)
			config_file="${2}"
			shift 2
			;;
		-h | --help)
			usage=1
			shift
			;;
		-v | --verbose)
			verbose=1
			shift
			;;
		-g | --debug)
			verbose=1
			debug=1
			keep_tmp_dir=1
			set -x
			shift
			;;
		-d | --dry-run)
			dry_run=1
			shift
			;;
		--)
			shift
			extra_args="${*}"
			break
			;;
		*)
			echo "${script_name}: ERROR: Internal opts: '${*}'" >&2
			exit 1
			;;
		esac
	done
}

#===============================================================================
export PS4='\[\e[0;33m\]+ ${BASH_SOURCE##*/}:${LINENO}:(${FUNCNAME[0]:-main}):\[\e[0m\] '

script_name="${0##*/}"

SECONDS=0
start_time="$(date +%Y.%m.%d-%H.%M.%S)"

real_source="$(realpath "${BASH_SOURCE}")"
SCRIPT_TOP="$(realpath "${SCRIPT_TOP:-${real_source%/*}}")"

trap "on_exit 'Failed'" EXIT
trap 'on_err ${FUNCNAME[0]:-main} ${LINENO} ${?}' ERR
trap 'on_err SIGUSR1 ? 3' SIGUSR1

set -eE
set -o pipefail
set -o nounset

source "${SCRIPT_TOP}/vpn-start-lib.sh"

host='all'
subnet=''
user=''
config_file_default="${HOME}/find-host.conf"
config_file="${config_file_default}"
usage=''
verbose=''
debug=''
dry_run=''

user_extra=''

process_opts "${@}"

if [[ "${config_file}" == '-' ]]; then
	config_file=''
else
	if [[ "${config_file}" != "${config_file_default}" ]]; then
		check_file '--config file' "${config_file}"
	fi
fi

if [[ -f "${config_file}" ]]; then
	source "${config_file}"
fi

if [[ ${usage} ]]; then
	usage
	trap - EXIT
	exit 0
fi

print_project_banner

if [[ ${extra_args} ]]; then
	set +o xtrace
	echo "${script_name}: ERROR: Got extra args: '${extra_args}'." >&2
	usage
	exit 1
fi

if [[ ! ${host} ]]; then
	echo "${script_name}: ERROR: No host given." >&2
	usage
	exit 1
fi

nmap="${nmap:-nmap}"

check_program "nmap" "${nmap}"

if [[ "${subnet}" == '-' ]]; then
	subnet=''
fi

if [[ ! ${subnet} ]]; then
	get_subnet subnet
	echo "INFO: No subnet specified, using '${subnet}'"
fi

echo "INFO: Searching for host '${host}' on subnet '${subnet}'."

eval 'sudo true'

cmd='sudo nmap -PE -sn --randomize-hosts ${subnet}'

readarray -t nmap_array < <( eval "${cmd}" \
	|| { echo "${script_name}: ERROR: nmap_array readarray failed, function=${FUNCNAME[0]:-main}, line=${LINENO}, result=${?}" >&2; \
	kill -SIGUSR1 $$; } )

line_count="${#nmap_array[@]}"

if (( ${line_count} == 0 )); then
	echo "${script_name}: ERROR: nmap failed" >&2
	exit 1
fi

# 'Nmap scan report for 11.22.33.44'
# 'Nmap scan report for host.domain.net (11.22.33.44)'

regex_ip='([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'
regex_line="Nmap scan report for.* \(?(${regex_ip})\)?"

declare -a ip_array=()

for (( id = 1; id <= ${line_count}; id++ )); do
	line="${nmap_array[$(( id - 1 ))]}"

	if [[ ${verbose} ]]; then
		echo '-----------------------------'
		echo "${id}: '${line}'"
	fi

	if [[ "${line}" =~ ${regex_line} ]]; then
		if [[ ${verbose} ]]; then
			echo "IP = '${BASH_REMATCH[1]}'"
		fi
		ip_array+=("${BASH_REMATCH[1]}")
	else
		if [[ ${verbose} ]]; then
			echo "no match: '${line}'"
		fi
	fi
done

if [[ ${verbose} ]]; then
	echo '============================='
fi

ip_count="${#ip_array[@]}"

if (( ${ip_count} == 0 )); then
	echo "${script_name}: ERROR: No IP's found." >&2
	exit 1
fi

if [[ ${dry_run} ]]; then
	echo "Trying ${ip_count} machines (DRY RUN)."
else
	echo "Trying ${ip_count} machines."
fi
echo '-----------------------------'

if [[ ${user} ]]; then
	user_extra="${user}@"
fi

for (( id = 1; id <= ${ip_count}; id++ )); do
	ip_addr="${ip_array[$(( id - 1 ))]}"

# 	cmd="ping -c2 ${ip_addr}"
	cmd="ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=publickey ${user_extra}${ip_addr} hostname"

	echo "${id}: Trying '${ip_addr}'"

	if [[ ${dry_run} ]]; then
		data=''
	else
		data="$(eval "${cmd}" 2> /dev/null)" || :
	fi

	if [[ ${data} ]]; then
		if [[ ${verbose} ]]; then
			echo "Got data: '${data}'"
		fi

		if [[ "${host}" == 'all' ]]; then
			echo "Found host '${data}' at '${ip_addr}'"
		elif [[ "${host}" == 'any' ]]; then
			echo "Found host '${data}' at '${ip_addr}'"
			break
		elif [[ "${data}" == *"${host}"* ]]; then
			echo "Found host at '${ip_addr}'"
			break
		fi
	fi

	if [[ ${verbose} ]]; then
		echo '-----------------------------'
	fi
done

trap "on_exit 'Success'" EXIT
exit 0
