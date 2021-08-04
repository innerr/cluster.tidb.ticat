set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`
shift

confirm=`confirm_str "${env}"`
yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`
name=`must_env_val "${env}" 'tidb.cluster'`
ver=`must_env_val "${env}" 'tidb.version'`

shift 4
skip_exist=`to_true "${1}"`
if [ "${skip_exist}" == 'true' ]; then
	exist=`cluster_exist "${name}"`
	if [ "${exist}" == 'true' ]; then
		echo "[:-] cluster name '${name}' exists, skipped"
		exit
	fi
fi

ver_path=`expr "${ver}" : '\(.*+\)' || true`
if [ $ver_path ]; then
    path=${ver#*+}
    ver=${ver_path%+}
else
	path=
fi

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os=linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    os=darwin
else
    os=win
fi

case $(uname -m) in
    i386)   arch="386" ;;
    i686)   arch="386" ;;
    x86_64) arch="amd64" ;;
    arm)    arch="arm64" ;;
esac

if [ ${path} ]; then
    if [ -d "${path}" ]; then
		cd ${path}
        if [ -x "${path}/tidb-server" ]; then
            tar -czvf tidb-nightly-${os}-${arch}.tar.gz tidb-server
            tiup cluster patch "${name}" tidb-nightly-${os}-${arch}.tar.gz -R tidb
        fi
        if [ -x "${path}/tikv-server" ]; then
            tar -czvf tikv-nightly-${os}-${arch}.tar.gz ${path}/tikv-server
            tiup cluster patch "${name}" tidb-nightly-${os}-${arch}.tar.gz -R tikv
        fi
        if [ -x "${path}/pd-server" ]; then
            tar -czvf pd-nightly-${os}-${arch}.tar.gz ${path}/pd-server
            tiup cluster patch "${name}" tidb-nightly-${os}-${arch}.tar.gz -R pd
        fi
		cd -
    elif [ -x "${path}" ]; then
        base=`basename ${path}`
		dir=`dirname ${path}`
        role=${base%*-server}
		cd ${dir}
        tar -czvf tidb-nightly-${os}-${arch}.tar.gz base
        tiup cluster patch "${name}" ${role}-nightly-${os}-${arch}.tar.gz -R ${role}
		cd -
    fi
fi