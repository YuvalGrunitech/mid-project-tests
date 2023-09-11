# Use Alpine Linux as a base image
FROM python:3.9.18-alpine3.18 as builder

# Copy your corrected repositories file into the image
RUN apk --no-cache --update-cache add g++
# Copy the rest
COPY requirements.txt .

# Install the required Python packages using pip
RUN pip3 install --user -r requirements.txt

# Start a new stage for the final image
FROM python:3.9.18-alpine3.18

# Copy the necessary files from the builder stage
COPY --from=builder /root/.local /root/.local

# Install libstdc++
RUN apk add --no-cache libstdc++

# Set the working directory in the container
WORKDIR /app

# Set the environment to development
ENV FLASK_ENV=development

# Set room path environment variable
ENV ROOMS_PATH="/app/rooms"

# Set users path environment variable
ENV USERS_PATH="/app/docs/users.csv"

# Copy the rest of your application files
COPY . .

# Expose the port your application will run on
EXPOSE 5000

# Start the Flask application
CMD ["python", "./src/chatApp.py"]
