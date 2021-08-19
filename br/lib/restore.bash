set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`

name=`must_env_val "${env}" 'tidb.cluster'`
pd=`must_cluster_pd "${name}"`

threads=`must_env_val "${env}" 'br.threads'`

tag=`must_env_val "${env}" 'tidb.backup.tag'`
dir_root=`must_env_val "${env}" 'br.backup-dir'`
dir="${dir_root}/${tag}"

echo tiup br restore full --pd "${pd}" -s "${dir}" --check-requirements=false --concurrency "${threads}"
tiup br restore full --pd "${pd}" -s "${dir}" --check-requirements=false --concurrency "${threads}"
