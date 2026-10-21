alias free='free -m'                      # show sizes in MB

# Run a single command with an unlimited stack (deep recursion), e.g. `bigstack ./solution`
bigstack() { (ulimit -s unlimited && "$@") }
