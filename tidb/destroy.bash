set -uo pipefail

env=`cat "${1}/env"`
shift

confirm=`echo "${env}" | grep '^tidb.op.confirm' | awk '{print $2}'`
if [ "${confirm}" == 'true' ] || [ "${confirm}" == 'on' ] || [ "${confirm}" == '1' ] || [ "${confirm}" == 'yes' ]; then
	confirm_str=''
else
	# skip confirm
	confirm_str=' --yes'
fi

name=`echo "${env}" | grep '^tidb.cluster' | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

list=`tiup cluster list 2>/dev/null | grep -v 'PrivateKey$' | grep -v '\-\-\-\-\-\-\-$' | grep "${name}"`

if [ -z "${list}" ]; then
	echo "[:(] cluster name '${name}' not exists" >&2
else
	set -e
	tiup cluster destroy "${name}"${confirm_str}
fi
