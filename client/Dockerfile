# Use an official node image as the base
FROM node:16 as build

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY ./package*.json ./
RUN npm install

# Copy the rest of the app and build it
COPY ./ ./
RUN npm run build


FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built React app to Nginx's web server directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the Nginx server
EXPOSE 80

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]