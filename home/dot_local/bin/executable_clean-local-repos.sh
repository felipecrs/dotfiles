#!/bin/bash
# ARG_OPTIONAL_SINGLE([repos_dir],[r],[Directory containing repositories],[.])
# ARG_OPTIONAL_REPEATED([exclude],[e],[Directories to exclude])
# ARG_HELP([Script to clean local git repositories])
# ARG_DEFAULTS_POS([])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='reh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_repos_dir="."
_arg_exclude=()


print_help()
{
	printf '%s\n' "Script to clean local git repositories"
	printf 'Usage: %s [-r|--repos_dir <arg>] [-e|--exclude <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "-r, --repos_dir: Directory containing repositories (default: '.')"
	printf '\t%s\n' "-e, --exclude: Directories to exclude (empty by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-r|--repos_dir)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_repos_dir="$2"
				shift
				;;
			--repos_dir=*)
				_arg_repos_dir="${_key##--repos_dir=}"
				;;
			-r*)
				_arg_repos_dir="${_key##-r}"
				;;
			-e|--exclude)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_exclude+=("$2")
				shift
				;;
			--exclude=*)
				_arg_exclude+=("${_key##--exclude=}")
				;;
			-e*)
				_arg_exclude+=("${_key##-e}")
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


set -eu

repos_dir="${_arg_repos_dir}"
exclude=("${_arg_exclude[@]}")

folders=$(find "${repos_dir}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
if [[ ${#exclude[@]} -ne 0 ]]; then
  folders=$(echo "${folders}" | grep -v -E "$(IFS="|"; echo "${exclude[*]}")")
fi

for folder in ${folders}; do
  echo "Updating folder: ${folder}"

  cd "${repos_dir}/${folder}" || { echo "Fail to access ${folder}"; continue; }

  branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
  git reset --hard origin/"${branch}"
  git checkout "${branch}"
  git pull

  echo "Update finished for: ${folder}"
done

# ] <-- needed because of Argbash
