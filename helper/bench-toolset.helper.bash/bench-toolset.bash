function metrics_jitter()
{
    local query="${1}"
    local bt=`build_bt "${here}/../repos/bench-toolset"`
    local res=`"${bt}" metrics jitter -u "${url}" -q "${query}" -b "${begin}" -e "${end}" | grep jitter | awk '{print $2,$4,$6}' | tr -d ,`
    echo "${res}"
}

function metrics_aggregate()
{
    local query="${1}"
    local bt=`build_bt "${here}/../repos/bench-toolset"`
    local res=`"${bt}" metrics aggregate -u "${url}" -q "${query}" -b "${begin}" -e "${end}" | awk '{print $2,$4,$6}' | tr -d ,`
    echo "${res}"
}

function build_bin()
{
	local dir="${1}"
	local bin_path="${2}"
	local make_cmd="${3}"
	(
		cd "${dir}"
		if [ -f "${bin_path}" ]; then
			echo "[:)] found pre-built '${bin_path}' in build dir: '${dir}'" >&2
			return
		fi
		${make_cmd} 1>&2
		if [ ! -f "${bin_path}" ]; then
			echo "[:(] can't build '${bin_path}' from build dir: '${dir}'" >&2
			exit 1
		fi
	)
	echo "${dir}/${bin_path}"
}

function build_bt()
{
	local dir="${1}"
	build_bin "${dir}" 'bin/bench-toolset' 'make'
}
