set -euo pipefail

env=`cat "${1}/env"`
shift

confirm=`echo "${env}" | { grep '^tidb.op.confirm' || test $? = 1; } | awk '{print $2}'`
if [ "${confirm}" == 'true' ] || [ "${confirm}" == 'on' ] || [ "${confirm}" == '1' ] || [ "${confirm}" == 'yes' ]; then
	confirm_str=''
else
	# skip confirm
	confirm_str=' --yes'
fi

name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

list=`tiup cluster list 2>/dev/null | \
	{ grep -v 'PrivateKey$' || test $? = 1; } | \
	{ grep -v '\-\-\-\-\-\-\-$' || test $? = 1; } | \
	{ grep "${name}" || test $? = 1; }`

if [ -z "${list}" ]; then
	echo "[:(] cluster name '${name}' not exists" >&2
else
	tiup cluster destroy "${name}"${confirm_str}
fi
