#!/bin/bash

repos_dir="${HOME}/repos"
exclude_dir=("$@")

folders=$(find "${repos_dir}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
if [[ ${#exclude_dir[@]} -ne 0 ]]; then
  folders=$(echo "${folders}" | grep -v -E "$(IFS="|"; echo "${exclude_dir[*]}")")
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