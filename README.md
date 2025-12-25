# Keelson Base Image

A lean base image based on the latest debian slim that has kubectl and yq 4 available along with a few other tools.

# Squash Every Image

The Dockerfile is written with squash in mind - it's cleaner and easier to understand and more natural this way as well as maximally light and fast to load in use. Writing Dockerfiles in this way also makes it much easier to diagnose failures since every command is in its own RUN execution you get to see exactly where it failed - not always easy with compound RUN lines full of double ampersands.
