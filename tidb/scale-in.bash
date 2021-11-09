set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

session="${1}"
env_file="${session}/env"
env=`cat "${env_file}"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
nodes=(`must_env_val "${env}" 'tidb.select-nodes'`)

for node in ${nodes[*]}
do
    tiup cluster scale-in -y "${name}" --node "${node}"
done

