# Final Project

## Setup

First, make sure Docker is installed, with the following steps:

1. If you are on Windows, you'll need to install `WSL`. Open `PowerShell`, and enter `wsl --install`.
2. After you have `WSL`, or immediately if on Linux/Apple, install [Docker Desktop](https://docs.docker.com/desktop/install/). Follow all instructions on the `.exe`.

Now, you can run the Docker environment associated with this project.

1. Open up a PowerShell  environment (if on Windows) in whatever folder you've cloned this repo. You can either `cd` to the folder, or you can `shift + right click` in the folder and choose `Open PowerShell window here`. If you have a Linux distribution, open your command prompt and skip to step 2.
2. Enter the following commands:
   1. `bash`
   2. If you haven't run the shell script before, you need to change the file permissions to make it an executable. Run this command to do so: `chmod +x run_docker.sh`.
   3. Run the shell script: `./run_docker.sh`.

Your container will now be running `R`. If you want open the `RStudio` server, navigate to [localhost:8787](localhost:8787) in your browser with username `rstudio` and password `password`.

## Create Report

To fully re-create the final report, you can simply run the following in a bash environment, which will give you access to the docker bash environment:

```bash
docker exec -it project_env bash
make report.pdf
```

To create the final report from scratch, even if you have created the report in the past, run the following commands in a bash environment:

```bash
docker exec -it project_env bash
make clean
make report.pdf
```
