# declaring an array, components []
declare -a components=()

# we are only interested in the last merged commit in this repository, 
# if the git show output is not a merged commit, this script will do nothing
from=$(git show | awk '{if($1=="Merge:"){print $2}}')
to=$(git show | awk '{if($1=="Merge:"){print $3}}')

# we need the last commit and the commit previous to it
# we use git diff --name-status tool to get the names of the changed files
if [[ ! -z "$from" ]] && [[ ! -z "$to" ]]; then
  while IFS= read -r line; do
    echo "$line"

    # fetching the commit status of each file in the commit
    gstatus=$(echo "$line" | awk '{print $1}')

    # but we are only interested in Renamed or Modified files, not the deleted ones
    # place the renamed and modified file names in the declared components array above accordingly
    if [[ "$gstatus" == "R"* ]]; then
      gfile=$(echo "$line" | awk '{print $3}')
      components+=("$gfile")
    elif [[ "$gstatus" != "D" ]]; then
      gfile=$(echo "$line" | awk '{print $2}')
      components+=("$gfile")
    fi
  done < <(git diff --name-status $from $to)

  # cluster spin up functions are called on the changed files
  manage_kong_admin 
  manage_kong_manager 
  manage_kong_portal 
  #manage_apic ${components[@]}
else
  echo "Warning: Nothing to apply!!"
fi

manage_kong_admin()
{
cd ../admin/ && touch a
echo "run the admin-api code"
}
manage_kong_manager()
{
echo "run a  kong-manager-code"

cd ../manager/ && touch a
}
manage_kong_portal()
{
echo "run a kong portal code"

cd ../portal/ && touch a
}
