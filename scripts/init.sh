#!/bin/bash

init(){
if [ $# -eq 0 ]
then 
    VERSION="debug"
else
    VERSION=$1
fi 

        
gcloud compute ssh --zone "me-west1-a" "yuval-first-instance" --project "grunitech-mid-project" --command "gcloud auth configure-docker me-west1-docker.pkg.dev && docker run -d -p 8000:5000  --name chat-app-cont me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION"

}