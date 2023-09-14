#!/bin/bash
delete(){
if [ $# -eq 0 ]
then 
    VERSION="debug"
else
    VERSION=$1
fi 

gcloud compute ssh --zone "me-west1-a" "yuval-first-instance" --project "grunitech-mid-project" --command "docker rm -f chat-app-cont && docker rmi -f me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION"

}