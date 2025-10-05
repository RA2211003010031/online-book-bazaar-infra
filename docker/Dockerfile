# Dockerfile for Online Book Bazaar Website
# This file tells Docker how to package your website

# Use Node.js as base image (adjust based on your website technology)
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all application files
COPY . .

# Create directory for logs
RUN mkdir -p /app/logs

# Expose port 3000 (adjust based on your application port)
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["npm", "start"]
