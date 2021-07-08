set -euo pipefail

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../../helper/helper.bash"

shift

yaml="${1}"
name="${2}"
ver="${3}"
confirm=`to_false "${4}"`
skip_exist=`to_true "${5}"`

if [ -f "${here}/../yaml/${yaml}.yaml" ]; then
	yaml="${here}/../yaml/${yaml}.yaml"
else
	if [ -f "${yaml}" ]; then
		echo "[:-] predefined-name '${yaml}' is a yaml file"
	else
		echo "[:(] topology file not found for predefined-name '${yaml}'" >&2
		exit 1
	fi
fi

if [ "${confirm}" != 'false' ]; then
	confirm=''
else
	confirm=' --yes'
fi

if [ "${skip_exist}" != 'true' ] || [ `cluster_exist "${name}"` != 'true' ]; then
	tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}
fi

tiup cluster start "${name}"
