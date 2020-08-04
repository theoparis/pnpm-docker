#!/bin/ash
mkdir -p /mnt/server
cd /mnt/server

if [[ ! ${INSTALL_REPO} = *\.git ]]; then
    INSTALL_REPO=$(echo -e ${INSTALL_REPO} | sed 's:/*$::')
    INSTALL_REPO="${INSTALL_REPO}.git"
fi

echo "working on installing a node project from ${INSTALL_REPO}"

if [ ! ${INSTALL_REPO} ]; then
    echo "assuming user will add files manually."
else
    if [ "$(ls -A /mnt/server)" ]; then
        echo "/mnt/server directory is not empty."
        if [ -d .git ]; then
            echo ".git directory exists"
            if [ -f .git/config ]; then
                echo "loading info from git config"
                ORIGIN=$(git config --get remote.origin.url)
            else
                echo "files found with no git config"
                echo "closing out without touching things to not break anything"
                exit 10
            fi
        fi
        if [ "${ORIGIN}" == "${INSTALL_REPO}" ]; then
            echo "pulling latest from github"
            git pull
        fi
    else
        echo "/mnt/server is empty.\ncloning files into repo"
        if [ -z ${INSTALL_BRANCH} ]; then
            echo "assuming master branch"
            INSTALL_BRANCH=master
        fi
        
        echo "running 'git clone --single-branch --branch ${INSTALL_BRANCH} ${INSTALL_REPO} .'"
        git clone --single-branch --branch ${INSTALL_BRANCH} ${INSTALL_REPO} .
    fi
fi

if [ -f ${INDEX_JS} ]; then
    pnpm i
    echo "install complete"
    node ${INDEX_JS}
else
    echo "No node.js file found to run."
fi