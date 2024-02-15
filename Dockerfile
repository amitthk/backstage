# Use Red Hat UBI 8 as the base image
FROM registry.access.redhat.com/ubi8/ubi:8.4

# Maintainer
LABEL maintainer="amitthk <e.amitthakur@gmail.com>"

# Backstage version argument for building from a specific release
ARG BACKSTAGE_VERSION=v1.22.2

# Install necessary tools
RUN yum update -y && \
    yum install -y wget git tar gzip unzip which && \
    yum module enable nodejs:18 -y && \
    yum install -y nodejs java-21-openjdk-devel python39 && \
    yum clean all

# Update npm to the latest stable version
RUN npm install -g npm@latest

# Install Yarn and update the PATH
RUN npm install -g yarn --verbose && \
    echo "export PATH=$(npm config get prefix)/bin:$PATH" >> $HOME/.bashrc && \
    source $HOME/.bashrc

# Set the working directory for Backstage
WORKDIR /opt/backstage

# Download and extract the specified version of Backstage
RUN wget https://github.com/backstage/backstage/archive/refs/tags/${BACKSTAGE_VERSION}.tar.gz -O backstage.tar.gz && \
    tar -xzf backstage.tar.gz --strip-components=1 && \
    rm backstage.tar.gz

# Install Backstage dependencies using yarn
RUN yarn install --verbose

# Add Backstage plugins
RUN yarn add @backstage/plugin-bitbucket-cloud @backstage/plugin-ldap @backstage/plugin-jenkins @backstage/plugin-jira @backstage/plugin-catalog-backend-module-bitbucket-server

# Add any necessary plugin configuration to app-config.yaml manually or through automation

# Build the Backstage app
RUN yarn build

# Expose Backstage port
EXPOSE 3000

# Start Backstage
CMD ["yarn", "start"]
