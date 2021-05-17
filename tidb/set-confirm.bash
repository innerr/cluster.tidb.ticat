set -uo pipefail

env_file="${1}/env"
shift

confirm="${1}"

echo "tidb.op.confirm	${confirm}" >> "${env_file}"
echo "[:)] set confirm flag to env:"
echo "    - tidb.op.confirm = ${confirm}"
