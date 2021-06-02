set -euo pipefail

env=`cat "${1}/env"`
shift

confirm=`echo "${env}" | { grep '^tidb.op.confirm' || test $? = 1; } | awk '{print $2}'`

yaml=`echo "${env}" | { grep '^tidb.tiup.yaml' || test $? = 1; } | awk '{print $2}'`
if [ -z "${yaml}" ]; then
	echo "[:(] no env val 'tidb.tiup.yaml'" >&2
	exit 1
fi

name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

ver=`echo "${env}" | { grep '^tidb.version' || test $? = 1; } | awk '{print $2}'`
if [ -z "${ver}" ]; then
	ver='nightly'
	echo "[:-] no env val 'tidb.version', use '${ver}'" >&2
fi

if [ "${confirm}" != 'false' ]; then
	confirm_str=''
else
	# skip confirm
	confirm_str=' --yes'
fi

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm_str}
