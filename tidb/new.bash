set -euo pipefail

session="${1}"
shift
env=`cat "${session}/env"`

ticat=`echo "${env}" | { grep '^sys.paths.ticat' || test $? = 1; } | tail -n 1 | awk '{print $2}'`

yaml="${1}"
name="${2}"
version="${3}"
confirm="${4}"

if [ -z "${yaml}" ]; then
	echo "[:(] no arg 'topology-file-or-predefined-name', alias 'topology|yaml|yam|name|file|path|p|P|f|F|n|N|y|Y'" >&2
	yaml=`echo "${env}" | { grep '^tidb.tiup.yaml' || test $? = 1; } | awk '{print $2}'`
	if [ -z "${yaml}" ]; then
		echo "    [:(] no env val 'tidb.tiup.yaml'" >&2
		exit 1
	else
		echo "    [:)] got it from env val 'tidb.tiup.yaml'"
	fi
fi

if [ -z "${name}" ]; then
	echo "[:(] no arg 'cluster-name', alias 'cluster|name|n|N'" >&2
	name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
	if [ -z "${name}" ]; then
		echo "    [:(] env val 'tidb.cluster' not found" >&2
		exit 1
	else
		echo "    [:)] got it from env val 'tidb.cluster'"
	fi
fi

"${ticat}" {session="${session}"} : \
	tidb.link.yaml name="${yaml}" : \
	tidb.deploy confirm="${confirm}" version="${version}" name="${name}" : \
	tidb.up : \
	mysql.link.tidb : \
	env.save
