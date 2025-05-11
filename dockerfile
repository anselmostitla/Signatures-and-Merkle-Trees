# 1. FIRST CONNECT OR RUN YOUR... DOCKER DESKTOP

# 2. Create a new directory
# --> mkdir merkle-airdrop && cd merkle-airdrop

# 3. Install git in the container
# --> apk update && apk add git

# 4. Since Git, inside the container, doesn't know your name and email, run these two commands inside the container:
# --> git config --global user.name "Your Name"
# --> git config --global user.email "you@example.com"

# 5. Run this security command inside the container
# --> git config --global --add safe.directory /workspace

# 6. Now you can initialize a foundry project
# --> forge init . --force

FROM shidaxi/foundry-rs:2024-01-09-alpine-3.19

# Install git
RUN apk update && apk add git

# Configure Git identity
RUN git config --global user.name "Anselmo Ramon Sanchez Titla" && \
    git config --global user.email "anselmostitla@gmail.com"

# Set safe directory for Git (useful for mounted volumes)
RUN git config --global --add safe.directory /workspace

# Set the default working directory
WORKDIR /workspace



# Build the image (pay attention to the dot at the end)
# docker build -t merkle-airdrop .

# Run the container
# docker run -it --rm -v $(pwd):/workspace merkle-airdrop sh

# forge init . --force

# To exit 
# exit or ctrl + d

# To remove a container an an image
# --> docker rm [containerId]
# --> docker rmi [imageId or imageName] 

# To see containers or images
# --> docker ps -a
# --> docker images