#!/bin/bash
IMAGE_NAME=$(yq r data.yaml data.image-name)
SEMVER=$(yq r data.yaml data.semver)

wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ./chrome.json

export SCRAPE_URL=https://en.wikipedia.org/wiki/General_Data_Protection_Regulation
docker run --rm -e "SCRAPE_URL=${SCRAPE_URL}" --security-opt seccomp=chrome.json ${IMAGE_NAME}:v${SEMVER}

#node main.js https://medium.com/@jaeger.rob/ibm-watson-tone-analysis-of-web-scraped-data-edc7fa83d817
#node main.js https://en.wikipedia.org/wiki/General_Data_Protection_Regulation
#node main.js https://krebsonsecurity.com/2019/02/a-deep-dive-on-the-recent-widespread-dns-hijacking-attacks/
