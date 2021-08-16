set -euo pipefail

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../../helper/helper.bash"

env_file="${1}/env"
env=`cat "${env_file}"`
shift

old_yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`
yaml="${old_yaml}"
file="${here}/${yaml}.yaml"
if [ ! -f "${file}" ]; then
	if [ -f "${yaml}" ]; then
		echo "[:-] predefined-name '${yaml}' is a yaml file"
	else
		echo "[:(] topology file not exists, and not found in predefined-names: '${yaml}'" >&2
		exit 1
	fi
else
	yaml="${file}"
fi

if [ "${old_yaml}" == "${yaml}" ]; then
	exit
fi

echo "tidb.tiup.yaml=${yaml}" >> "${env_file}"
echo "[:)] set topology file path to env:"
echo "    - tidb.tiup.yaml = ${yaml}"
