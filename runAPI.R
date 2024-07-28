#Run my final API

library(plumber)
r <- plumb("finalAPI.R")

#run it on the port in the Dockerfile
r$run(port=90, host="0.0.0.0")

