#!/bin/bash

choice_func(){
    read -r -n 1 -p "Enter Y|y or N|n: " choice
    echo
    while [[ $choice != 0 && $choice != 1 ]] 
    do
        if [[ $choice == [Yy] ]]; then
                choice=0
            elif [[ $choice == [Nn] ]]; then
                choice=1
            else
                echo "Invalid input, Try again."   
                read -r -n 1 -p "Enter Y|y or N|n: " choice
                echo
        fi
    done
}



deploy(){
VERSION=$1
COMMIT_HASH=$2
# Error handling must get 2 inputs from user
if [ $# -lt 1 ]
then
    echo "USAGE: $0 -de '<version>' ['<commit-hash>' OPTIONAL]"
    exit 1
fi

choice=0
# Tag & Build thin.dockerfile if not exists
if docker images -a | grep -E "me-west1-docker\.pkg\.dev/grunitech-mid-project/yuval-chat-app/chat-app-img[ ]+$VERSION" &> /dev/null 
then 
    echo "Image me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION already exists."
    echo
    echo "Use the existing image - [N|n] or rebuild and delete the existing one - [Y|y]"
    choice_func
fi

if [ $choice = 0 ]
then
    docker rmi -f me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION
    docker build -t me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION  -f thin.dockerfile .
fi
# Error handling: Checks if build is completed succefuly
if [ $? -eq 0 ]
then 
    echo
    echo "Build Succeeded/Exists"
    echo "Push to GCR?"
    choice_func
    if [ $choice = 0 ]
    then 
        gcloud config set auth/impersonate_service_account artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com
        docker push "me-west1-docker.pkg.dev/grunitech-mid-project/yuval-chat-app/chat-app-img:$VERSION"
        gcloud config unset auth/impersonate_service_account
        
    fi
    if [ $# -gt 1 ]
    then
        echo
        echo "Tag & push to GitHub repo?"
        choice_func 
        echo
        # Check the input character and display the corresponding message
        if [ $choice = 0 ]
        then
        # Tag & push commit hash
            git tag "v$VERSION" $COMMIT_HASH
            git push -u origin "v$VERSION"
        fi
    fi
else
    echo "Error: Build failed, Fix Dockerfile and try again"
fi


}