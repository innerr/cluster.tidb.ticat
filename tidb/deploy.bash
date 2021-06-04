set -euo pipefail

env=`cat "${1}/env"`
here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../utils/base.bash" "${env}"

confirm=`confirm_str "${env}"`
yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`
name=`must_env_val "${env}" 'tidb.cluster'`

ver=`env_val "${env}" 'tidb.version'`
if [ -z "${ver}" ]; then
	ver='nightly'
	echo "[:-] no env val 'tidb.version', use '${ver}'" >&2
fi

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}
