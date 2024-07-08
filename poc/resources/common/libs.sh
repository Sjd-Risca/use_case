
declare -a on_err_items=()

on_err() {
  for i in "${on_err_items[@]}"
  do
      echo "on_err: $i"
      eval $i
  done
}

add_on_err() {
  local n=${#on_err_items[*]}
  on_err_items=("$*" "${on_err_items[@]}")
  if [[ $n -eq 0 ]]; then
      echo "Setting trap"
      trap on_err ERR EXIT
  fi
}

cleanup() {
  local marker=$1
  on_err_run_till "${marker}"
}

on_err_run_till() {
  local marker=$1
  for i in "${on_err_items[@]}"
    do
    on_err_items=("${on_err_items[@]:1}")
    eval $i
    if [[ $i == *"$marker"* ]]; then
      break
    fi
    done
}
