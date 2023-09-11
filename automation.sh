#!/bin/bash
#Import all bash files
# Specify the directory containing your Bash files
bash_files_dir="scripts"

# Check if the directory exists
if [ -d "$bash_files_dir" ]; then
  # Iterate through the Bash files in the directory
  for file in "$bash_files_dir"/*.sh; do
    if [ -f "$file" ]; then
      # Source (import) the Bash file
      source "$file"
    fi
  done
else
  echo "Error: Directory $bash_files_dir not found."
fi

# Function to display usage information
show_usage() {
  echo "Usage: $0 <-i|-d|-e|-de|-p|-in> <arguments>"
  echo "Options:"
  echo "  -i, --init   <Version> Build chat-app image with the version provided and run the chat-app container with mounted volumes"
  echo "  -d, --delete <Version> Delete chat-app container and the specified chat-app image"
  echo "  -e, --exec             Open a bash shell as root inside the chat-app container"
  echo "  -de,--deploy <version> <commit-hash>"
  echo "                         Build, tag, and push the chat-app image with the specified tag to GCR and [OPTIONAL]tag and push the commit hash"
  echo "  -p, --prune            Prune all Docker resources"
  echo "  -in, --info            Show all Docker resources"
  exit 1
}


if [ $# -eq 0 ]
then
    show_usage
fi
flag=$1
shift

case $flag in
  -i|--init)
    init $@
    ;;
  -d|--delete)
    delete $@
    ;;
  -e|--exec)
    debug
    ;;
  -de|--deploy)
    deploy $@
    ;;
  -p|--prune)
    prune
    ;;
  -in|--info)
    info
    ;;
  *)
    echo "Invalid option: $1" >&2
    show_usage
    ;;
esac