# Use a lightweight Python base image
FROM python:3.9-slim as builder

# Copy the rest of the application code into the container
COPY requirements.txt .

# Install the required packages
RUN pip install --user -r requirements.txt

FROM python:3.9-slim
# Set the working directory in the container
WORKDIR /app

# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local

# Copy the rest of the app
COPY . .

# Set the environment to development
ENV FLASK_ENV=development
# Set room path environment variable
ENV ROOMS_PATH="/app/rooms"
# Set users path environment variable
ENV USERS_PATH="/app/docs/users.csv"


RUN apt-get -y update
RUN apt-get -y install curl

HEALTHCHECK --interval=10s --timeout=3s CMD curl -f http://localhost:5000/health || exit 1

# Expose the port your application will run on
EXPOSE 5000
# Start the Flask application
CMD ["python", "./src/chatApp.py"]
