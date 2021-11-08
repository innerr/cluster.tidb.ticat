set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

session="${1}"
env_file="${session}/env"
env=`cat "${env_file}"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
role=`must_env_val "${env}" 'tidb.select-nodes.role'`
cnt=`must_env_val "${env}" 'tidb.select-nodes.count'`


if [ "${role}" == "tidb" ];
then  
    nodes=`must_cluster_tidbs "${name}"`
elif [ "${role}" == "tikv" ];
then
    nodes=`must_cluster_tikvs "${name}"`
elif [ "${role}" == "tiflash" ];
then
    nodes=`must_cluster_tiflashs "${name}"`
else
	echo "[:(] role '${role}' unknown. try [tidb, tikv, tiflash] instead" >&2
	exit 1
fi

nodes_array=(${nodes})

if [ "${cnt}" -gt "${#nodes_array[*]}" ]
then
    echo "[:(] no ${cnt} '${role}' in '${name}'" >&2
	exit 1
fi

echo "tidb.select-nodes=${nodes_array[*]:0:${cnt}}" >> "${env_file}"
