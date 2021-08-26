set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

session="${1}"
env=`cat "${session}/env"`

name=`must_env_val "${env}" 'tidb.cluster'`
prometheus=`must_prometheus_addr "${name}"`
begin=`must_env_val "${env}" 'bench.run.begin'`
end=`must_env_val "${env}" 'bench.run.end'`

echo "metrics.prometheus.url=http://${prometheus}" >> "${session}/env"
echo "metrics.begin=${begin}000" >> "${session}/env"
echo "metrics.end=${end}000" >> "${session}/env"
