FROM node:11.10.0-stretch-slim

#TODO: update to incorporate https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md

# following are labels to be carried with the image's manifest so they are discoverable in running environment not just in container registry
# source of container image (regardless of mirroring that occurs)
ARG IMAGE_SRC=unspecified
LABEL image_src=${IMAGE_SRC}
# traceability info about where the build occurred
ARG BUILT_BY=unspecified
LABEL built_by=${BUILT_BY}
# semver string
ARG SEMVER=unspecified
LABEL semver=${SEMVER}
# git repo built from
ARG GIT_REPO=unspecified
LABEL git_repo=${GIT_REPO}
# git branch built from
ARG GIT_BRANCH=unspecified
LABEL git_branch=${GIT_BRANCH}
# git commit id
ARG GIT_COMMIT=unspecified
LABEL git_commit=${GIT_COMMIT}
# short description of any changes present in git repo clone - helps us ensure pipeline builds are not dirty and gives some traceability in local builds
ARG GIT_STATUS=unspecified
LABEL git_status=${GIT_STATUS}

# Puppeteer dependencies per https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

ENV DIR=/opt/lukesiler/url2text
WORKDIR ${DIR}
# Install app dependencies.
COPY package.json .
COPY package-lock.json .
COPY main.js .

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN npm install

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser ${DIR}

# Run everything after as non-privileged user.
USER pptruser

ENV SCRAPE_URL unspecified
# see https://www.elastic.io/nodejs-as-pid-1-under-docker-images/
CMD dumb-init node main.js ${SCRAPE_URL}
