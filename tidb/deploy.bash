set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`
shift

confirm=`confirm_str "${env}"`
yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`
name=`must_env_val "${env}" 'tidb.cluster'`
ver=`must_env_val "${env}" 'tidb.version'`

shift 4
skip_exist=`to_true "${1}"`
if [ "${skip_exist}" == 'true' ]; then
	exist=`cluster_exist "${name}"`
	if [ "${exist}" == 'true' ]; then
		echo "[:-] cluster name '${name}' exists, skipped"
		exit
	fi
fi

ver_path=`expr "${ver}" : '\(.*+\)' || true`
if [ "${ver_path}" ]; then
	path="${ver#*+}"
	ver="${ver_path%+}"
else
	path=''
fi

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}

if [ -z "${path}" ]; then
	exit
fi
path_patch "${path}"
