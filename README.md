# Basic MERN App

## Deployment using terraform to CloudRun
### Creating Dockerfiles
#### Frontend
```Docker
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
```

#### Backend
```Docker
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
```
### Terraform files
##### Configuration file `configs.tf`
```json
provider "google" {
  project = "heroviredacademics"
  region  = "us-central1"
}
variable "project"{
    default = "heroviredacademics"
}
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket293ehiuwei"
    prefix     = "terraform/state"              
  }
}
```

##### Applications terraform configuration
```json
# Build Docker image and push to Artifact Registry (You'll need to run this manually or with Cloud Build)
# docker build -t us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client ./client
# docker push us-central1-docker.pkg.dev/your-gcp-project-id/mern-repo/client

# Deploy Frontend to Cloud Run
resource "google_cloud_run_service" "mern_client_app" {
  name     = "mern-client"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/client:latest"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        env {
        name = "REACT_APP_YOUR_HOSTNAME"
        value = google_cloud_run_service.mern_server_app.status[0].url
      }
      }
      
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Deploy Backend to Cloud Run
resource "google_cloud_run_service" "mern_server_app" {
  name     = "mern-server"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/mern-repo/server:latest"
        env {
          name  = "ATLAS_URI"
          value = "mongodb+srv://rajnee:rajani103@cluster0.py2ov.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }

    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
resource "google_cloud_run_service_iam_member" "backend_iam_public" {
  service    = google_cloud_run_service.mern_server_app.name
  location   = google_cloud_run_service.mern_server_app.location
  role       = "roles/run.invoker"
  member     = "allUsers"
}
resource "google_cloud_run_service_iam_member" "frontend_iam_public" {
  service    = google_cloud_run_service.mern_client_app.name
  location   = google_cloud_run_service.mern_client_app.location
  role       = "roles/run.invoker"
  member     = "allUsers"
}
# Output Cloud Run URLs
output "client_url" {
  value = google_cloud_run_service.mern_client_app.status[0].url
}

output "server_url" {
  value = google_cloud_run_service.mern_server_app.status[0].url
}
```

### Cloudbuild trigger configuration
- create a cloudbuild trigger and connect your github repo
### Cloudbuild file
```yml
steps:
  # Step 1: Build the frontend Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/client', '-f', 'Dockerfile', '.']
    dir: './client'

  # Step 2: Push the frontend Docker image to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/client']

  # Step 3: Build the backend Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/server', '-f', 'Dockerfile', '.']
    dir: './server'

  # Step 4: Push the backend Docker image to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/server']

  # Step 5: Install Terraform and execute Terraform scripts
  - name: 'hashicorp/terraform:light'
    entrypoint: '/bin/sh'
    args:
      - '-c'
      - |
        rm -rf .terraform
        terraform init -reconfigure
        terraform apply -auto-approve
    dir: './tf-scripts'

# Define the images that will be created
images:
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/client'
  - 'us-central1-docker.pkg.dev/$PROJECT_ID/mern-repo/server'

options:
  logging: CLOUD_LOGGING_ONLY
```

### MongoDB Atlas
- setup mongodb atlas and get the connection url.

---

![my picture](https://doananhtingithub40102.github.io/MyData/mern/mypicture.png)

A full-stack [MERN](https://www.mongodb.com/mern-stack) application for managing information of employees.

## About the project

This is a full-stack MERN application that manages the basic information of employees. The app uses an employee database from the MongoDB Atlas database and then display it using a React.

## Tech Stack

**Client:** React, Bootstrap

**Server:** NodeJS, ExpressJS

**Database:** MongoDB

## Run Locally

Clone the project

```bash
  git clone https://github.com/doananhtingithub40102/mern-app.git
```

Go to the project directory

```bash
  cd mern-app
```

Create an Atlas URI connection parameter in `server/.env` with your Atlas URI:
```
ATLAS_URI="mongodb+srv://<username>:<password>@cluster0.6cgz2s1.mongodb.net/?retryWrites=true&w=majority"
PORT=5000
```

Create an hostname on server enviroment variable in `client/.env` with your hostname on server:
```
REACT_APP_YOUR_HOSTNAME="http://localhost:5000"
```

Install dependencies

```bash
  cd server
  npm install
```

```bash
  cd client
  npm install
```

Start the server

```bash
  cd server
  node server.js
```
Start the Client

```bash
  cd client
  npm start
```
  

## Features in the project

- The user can **create** the information of a employee, and managing it.

- **Displaying** the information of employees, including the name, position, and level of the employee.

- Includes **Update** and **Delete** actions.

## Learn More

**FrontEnd**

* To learn React, check out the [React documentation](https://reactjs.org/).

* You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

* Get started with [Bootstrap](https://www.w3schools.com/bootstrap5/index.php), the world's most popular framework for building responsive, mobile-first websites.

**BackEnd**

* [Node.js Tutorial](https://www.w3schools.com/nodejs/default.asp)

* [ExpressJS Tutorial](https://www.tutorialspoint.com/expressjs/index.htm)

**Database**

* [MongoDB Tutorial](https://www.w3schools.com/mongodb/)

* Follow the [Get Started with MongoDB Atlas](https://www.mongodb.com/docs/atlas/getting-started/) guide to create an Atlas cluter, connecting to it, and loading your data.

**Fullstack**

* Learn all about the [MERN stack](https://www.mongodb.com/languages/mern-stack-tutorial) in this step-by-step guide on how to use it by developing a simple CRUD application from scratch.

## Live app

<a href="https://employee-manager-tindoan-xu3i.onrender.com/">Live fullstack MERN app</a>
