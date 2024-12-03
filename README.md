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
   4. If step 3 fails, you may need to make `run_docker.sh` friendly with Ubuntu. If so, run the following commands: `sudo apt-get update`, `sudo apt-get install dos2unix`, `dos2unix run_docker.sh`. Now, repeat step 3.

Your container will now be running `R`. If you want open the `RStudio` server, navigate to [localhost:8787](localhost:8787) in your browser with username `rstudio` and password `password`. You can easily stop the container by sending the kill signal, CTRL + C, into the `bash` terminal.

## Data Investigated

This report investigates a dataset of over 5,000 aviation accidents since the early 1900s. All data is scraped from [Plane Crash Info](https://www.planecrashinfo.com/), a website maintained by [Richard Kebabjian](mailto:kebab@planecrashinfo.com).

As the website states on its [database overview page](https://www.planecrashinfo.com/database.htm), this dataset includes all (or maybe most, according to the website's [disclaimer](https://www.planecrashinfo.com/disclaim.htm)) aviation accidents that meet the following criteria:

- All civil and commercial aviation accidents of scheduled and non-scheduled passenger airliners worldwide, which resulted in a fatality (including all U.S. Part 121 and Part 135 fatal accidents)

- All cargo, positioning, ferry and test flight fatal accidents.

- All military transport accidents with 10 or more fatalities.

- All commercial and military helicopter accidents with greater than 10 fatalities.

- All civil and military airship accidents involving fatalities.

- Aviation accidents involving the death of famous people.

- Aviation accidents or incidents of noteworthy interest.

## Create Report

To fully re-create the final report, you can run a simple `Make` command in the container. In the `run_docker.sh` helper script, there are easy helper calls to enter a bash terminal inside the container. Run the following in a `bash` console in the the repository folder, after you have started `Docker` in the background:

```bash
./run_docker.sh bash
make report.pdf

# To exit:
kill 1
```

To create the final report from scratch, even if you have created the report in the past, run the following commands in a bash environment in the repository folder, after you have started `Docker` in the background:

```bash
./run_docker.sh bash
make clean
make report.pdf

# To exit:
kill 1
```

The above `Make` call does not rebuild the scraped data, as it takes about 8 hours. If you want to build that first, you can call the following commands in a bash environment in the repository folder, after you have started `Docker` in the background:

```bash
./run_docker.sh bash
make full_clean
make make_data
make report.pdf

# To exit:
kill 1
```
