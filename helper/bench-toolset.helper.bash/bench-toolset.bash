function metrics_jitter()
{
    local query="${1}"
    local res=`bench-toolset metrics jitter -u "${url}" -q "${query}" -b "${begin}" -e "${end}" | grep jitter | awk '{print $2,$4,$6}' | tr -d ,`
    echo "${res}"
}

function metrics_aggregate()
{
    local query="${1}"
    local res=`bench-toolset metrics aggregate -u "${url}" -q "${query}" -b "${begin}" -e "${end}" | awk '{print $2,$4,$6}' | tr -d ,`
    echo "${res}"
}
