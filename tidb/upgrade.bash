set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`
shift

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`
ver=`must_env_val "${env}" 'tidb.version'`

shift 3

read ver path < <(expand_version_and_path "${ver}")
current_version=`tiup cluster display "${name}" --version 2>/dev/null`
if [[ "${ver}" < "${current_version}" ]]; then
	echo "[:(] please specify a higher version than ${current_version}" >&2
	exit 1
fi

force=`enable_opt "${1}" '--force'`
ignore_config_check=`enable_opt "${2}" '--ignore-config-check'`
offline=`enable_opt "${3}" '--offline'`

tiup cluster upgrade "${name}" "${ver}" ${force}${ignore_config_check}${offline}${confirm}

if [ ! -z "${path}" ]; then
	path_patch "${path}"
fi
