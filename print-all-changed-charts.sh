ECHO="${ECHO:-echo}"
declare -a all_charts
for chartpath in $(gfind charts -name Chart.yaml); do curdir=$(dirname "$chartpath"); ${ECHO} $curdir; all_charts+=($curdir); done
for item in ${all_charts[@]}; do ${ECHO} -e "Key: $item"; done
sorted_charts=( $(printf "%s\\n" "${all_charts[@]}" | sort) )

declare -a all_dirs
for changedfile in $(git diff --name-only HEAD~1); do curdir=$(dirname "$changedfile"); ${ECHO} $curdir; all_dirs+=($curdir); done
for item in ${all_dirs[@]}; do ${ECHO} -e "Key: $item"; done
sorted_changed_dirs=( $(printf "%s\\n" "${all_dirs[@]}" | sort| uniq) )
${ECHO} "printing all directories with helm charts" && for item in ${sorted_charts[@]}; do ${ECHO} -e "Key: $item"; done
${ECHO} "printing all directories that changed in the current HEAD" && for item in ${sorted_changed_dirs[@]}; do ${ECHO} -e "Key: $item"; done

declare -a changed_charts
tot_helm_chart=${#sorted_charts[@]}
tot_changed_dirs=${#sorted_changed_dirs[@]}
cur_helm_chart_idx=0
cur_changed_dirs_idx=0
${ECHO} "${sorted_charts}"

${ECHO} "tot_helm_chart: $tot_helm_chart tot_changed_dirs: $tot_changed_dirs"

while [[ $cur_helm_chart_idx -lt $tot_helm_chart ]]; do
  cur_helm_chart=${sorted_charts[$cur_helm_chart_idx]}
  ${ECHO} "TESTING: cur_helm_chart_idx: $cur_helm_chart_idx, cur_helm_chart: $cur_helm_chart"
  cur_changed_dirs_idx=0
  while [[ $cur_changed_dirs_idx -lt $tot_changed_dirs ]]; do
    cur_dir=${sorted_changed_dirs[$cur_changed_dirs_idx]}
    ${ECHO} "cur_changed_dirs_idx: $cur_changed_dirs_idx, cur_dir: $cur_dir"
    if [[ "$cur_helm_chart" > "$cur_dir" ]]; then
      ${ECHO} "$cur_helm_chart' > $cur_dir, try next cur_dir"
      cur_changed_dirs_idx=$((cur_changed_dirs_idx + 1))
    else
      if [[ "$cur_dir" == "$cur_helm_chart"* ]]; then
        ${ECHO} "$cur_dir starts with $cur_helm_chart"
        if [[ "$cur_dir" == "${cur_helm_chart}chart/"*  ]]; then
          cur_changed_dirs_idx=$((cur_changed_dirs_idx + 1))
	else
          ${ECHO} "adding $cur_helm_chart due to $cur_dir and BREAKING"
          changed_charts=($cur_helm_chart)
          break 1
	fi
      else
          ${ECHO} "$cur_helm_chart is not a prefix for $cur_dir and so it cannot be a prefix for ones that come later - BREAKING"
          break 1
      fi
    fi
  done
  cur_helm_chart_idx=$((cur_helm_chart_idx + 1))
done
echo '['| tr -d '\n' && for item in ${changed_charts[@]}; do echo "${item}, "; done | gsed 's/, $//'|tr -d '\n' && echo ']'
