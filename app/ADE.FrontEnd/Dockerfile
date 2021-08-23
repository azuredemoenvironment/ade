##################################################################
# Stage 0: Set the Base Primary Image of the App
##################################################################
FROM node:15-buster-slim AS base

# Install prerequisites
RUN npm install -g http-server

# Create App directory
WORKDIR /app

# Setup base server requirements
RUN npm install @azure/app-configuration
COPY configuration.js ./
COPY env.sh ./
COPY server.sh ./

EXPOSE 80
EXPOSE 443

##################################################################
# Stage 1: Build the Node App
##################################################################
FROM base as publish

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

# Setting the executable that will run in the lifetime of this container
ENTRYPOINT ["/app/server.sh"]