set -euo pipefail

env=`cat ${1}/env`
shift

host=`echo "${env}" | grep 'mysql.host' | awk '{print $2}'`
port=`echo "${env}" | grep 'mysql.port' | awk '{print $2}'`

mysql -h "${host}" -P "${port}" -u root -e "${1}"
