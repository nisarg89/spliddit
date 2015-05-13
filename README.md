# Spliddit.org
[Spliddit](http://www.spliddit.org) enables users to get quick, fair solutions to a variety of disputes. Our free suite of fair division mechanisms applies cutting-edge research in computer science, economics, and mathematics. Currently, solutions are offered for rent division, divorce settlement, and coauthor ordering (assigning credit).

For an introduction to Spliddit, including technical details, read our letter in [SIGecom Exchanges](http://www.cs.cmu.edu/~arielpro/papers/spliddit.sigecom.pdf).

## Software Overview

Spliddit runs on Rails 3.2.13 and Ruby 1.9.3p125. It uses [Delayed Job](https://github.com/collectiveidea/delayed_job) for running the algorithms for each application, as well as for sending email. Some of the algorithms (/lib) are written in Java and require the [IBM CPLEX Optimizer](http://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/). 

## Server Architecture

Spliddit runs on the AWS Cloud, and is deployed using Elastic Beanstalk. Each EC2 instance runs both a copy of the rails server and a delayed job queue. The RDS instance runs a Postgresql database.

![Spliddit AWS Diagram](http://i.imgur.com/jXGp8WH.png)

## Running Spliddit

Begin with a bundle install, and then rails s. To process the task queue, run bundle exec rake jobs:work. To clear the job queue, run rake jobs:clear. In order to use some of the algorithms (currently the Dividing Goods algorithm), Spliddit expects Rails.configuration.cplex_lib to point to the CPLEX binary.

## Deploying Spliddit

Spliddit uses [EbDeployer](https://github.com/ThoughtWorksStudios/eb_deployer) for deploying to Elastic Beanstalk using Blue-Green deployments. See [the wiki](https://github.com/ThoughtWorksStudios/eb_deployer/wiki/Rails-3-Support) for instructions on using EbDeployer with Rails 3.

## Contributing to Spliddit

Email jogo279@gmail.com if interested. More formal instructions will be posted in the future.