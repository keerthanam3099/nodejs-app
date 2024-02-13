#slim base image
FROM node:lts-alpine

#create a system user
RUN adduser -D appuser 

# workdirectory for the conatiner
WORKDIR /usr/src/app

#ownership of the workdirectory
RUN chown -R appuser:appuser /usr/src/app

#Copy installation packages 
COPY package*.json .

#install the packages 
RUN npm ci --only=production 

# Copy source code
COPY . .

#Expose listener port 3000 
EXPOSE 3000

#execute the application
CMD ["node", "./app.js"]