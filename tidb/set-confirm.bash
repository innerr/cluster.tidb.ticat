set -euo pipefail

env_file="${1}/env"
shift

confirm="${1}"

falses=('false' 'f' 'no' 'n' 'off' '0')

for s in ${falses[@]}; do
	if [ "${s}" == "${confirm}" ]; then
		confirm='false'
		break
	fi
done

if [ "${confirm}" != 'false' ]; then
	confirm='true'
fi

echo "tidb.op.confirm	${confirm}" >> "${env_file}"
echo "[:)] set confirm flag to env:"
echo "    - tidb.op.confirm = ${confirm}"
