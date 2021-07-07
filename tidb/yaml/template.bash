set -euo pipefail

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../../helper/helper.bash"

env_file="${1}/env"
env=`cat "${env_file}"`
shift

yaml=`must_env_val "${env}" 'tidb.tiup.yaml.predefined'`
file="${here}/${yaml}.yaml"
if [ ! -f "${file}" ]; then
	echo "[:(] topology file not found for predifined-name '${yaml}'" >&2
	exit 1
else
	yaml="${file}"
fi

echo "tidb.tiup.yaml=${yaml}" >> "${env_file}"
echo "[:)] set topology file path to env:"
echo "    - tidb.tiup.yaml = ${yaml}"
