##################################################################
# Stage 0: Set the Base Primary Image of the App
##################################################################
FROM node:15-buster-slim AS base

# Install prerequisites
RUN npm install -g http-server

WORKDIR /app

EXPOSE 80
EXPOSE 443

##################################################################
# Stage 1: Build the Node App
##################################################################
FROM base as publish

# Environment Variables that Affect the Build
ARG ADE__APIGATEWAYURI
ARG APPINSIGHTS_CONNECTIONSTRING

ENV REACT_APP_APIGATEWAYURI $ADE__APIGATEWAYURI
ENV REACT_APP_APPINSIGHTS $APPINSIGHTS_CONNECTIONSTRING

# Copy package files and npm install
COPY ./package*.json ./
RUN npm install

# Copy Remaining Files and Run the build command
COPY ./ ./
RUN npm run build

##################################################################
# Stage 3: Copy Into a Clean Runtime Image
##################################################################
FROM base AS final

# Copy artifacts from the previous stage into this stage
COPY --from=publish /app/build ./

# TODO: add a script that starts the http server, but first updates the configured connection endpoints

# Setting the executable that will run in the lifetime of this container
ENTRYPOINT ["http-server", "./", "-p", "80"]