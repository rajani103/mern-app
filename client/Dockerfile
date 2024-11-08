# # Use an official node image as the base
# FROM node:16 as build

# # Set the working directory
# WORKDIR /app

# # Copy package.json and install dependencies
# COPY ./package*.json ./
# RUN npm install

# # Copy the rest of the app and build it
# COPY ./ ./

# ARG REACT_APP_YOUR_HOSTNAME
# ENV REACT_APP_YOUR_HOSTNAME=$REACT_APP_YOUR_HOSTNAME

# RUN npm run build


# FROM nginx:alpine

# # Copy the built React app to Nginx's web server directory
# COPY --from=build /app/build /usr/share/nginx/html
# COPY nginx.conf /etc/nginx/default.conf
# # Expose port 80 for the Nginx server
# EXPOSE 8080


# # Start Nginx when the container runs
# CMD ["nginx", "-g", "daemon off;"]
#---
# # Use an official Node runtime as a parent image
FROM node:16

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json to the working directory
COPY ./package*.json ./

# Install the dependencies
RUN npm install

# Copy the remaining application files to the working directory
COPY . .

# Build the application
RUN npm run build

# Expose port 3000 for the application
EXPOSE 3000

# Start the application
CMD [ "npm", "run", "start" ]