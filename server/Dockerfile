# Use an official node image as the base
FROM node:16

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY ./package*.json ./
RUN npm install

# Copy the rest of the server files
COPY ./ ./

EXPOSE 8080

# Start the server
CMD ["node", "server.js"]