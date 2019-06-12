```{r}
print("Curvature math begun.")

library(tidyverse)

testing <- read.csv("OrderedPoints.csv", header = TRUE)
names(testing) <- c("cell", "ridge", "x", "y")

rows <- nrow(testing)
length_df <- data.frame(length = c(replicate(rows, 0)))
slope_df <- data.frame(slope = c(replicate(rows, 0)))

#calculate slope and length at each point of every ridge:
i <- 1
while (i < rows) {
    #If the next row is not of the same ridge, or same cell, skip that point.
    if (testing$cell[i] != testing$cell[i + 1]) {
        length_df$length[i] <- 0
        slope_df$slope[i] <- 0
    }
    else if (testing$ridge[i] != testing$ridge[i + 1]) {
        length_df$length[i] <- 0
        slope_df$slope[i] <- 0
    }
    else {
        #Calculate distance between the current and next point
        a <- testing$y[i + 1]
        b <- testing$y[i]
        c <- testing$x[i + 1]
        d <- testing$x[i]

        this_length <- sqrt((a - b) ^ 2 + (c - d) ^ 2)
        length_df$length[i] <- this_length

        #Calculate the slope between the current and next point
        if ((c - d) == 0) {
            this_slope <- 0
        }
        else {
            this_slope <- ((a - b) / (c - d))
        }
        slope_df$slope[i] <- this_slope
        #print(paste("Length is", this_length, "and slope is", this_slope))
    }
    i <- i + 1
}

print("All ridge lengths and instantaneous slopes calculated.")
#This actually isn't needed since I initialize with zeros but it doesn't hurt.
length_df$length[rows] <- 0
slope_df$slope[rows] <- 0

#create new data frame with data, length, and slope of each ridge.
bindedlength <- bind_cols(testing, length_df, slope_df)

#calculate acceleration
acceleration_df <- data.frame(av_slope = c(replicate(rows, 0)), acceleration = c(replicate(rows, 0)))
i <- 1
while (i < (rows - 1)) {
    #The cell and ridge IDs must match both the next point and 2 points ahead in order to calculate acceleration.
    if (bindedlength$cell[i] != bindedlength$cell[i + 1] | bindedlength$ridge[i] != bindedlength$ridge[i + 1] |
        bindedlength$cell[i] != bindedlength$cell[i + 2] | bindedlength$ridge[i] != bindedlength$ridge[i + 2]) {
        print("This is the next ridge")
        acceleration_df$acceleration[i] <- 0
        acceleration_df$av_slope[i] <- 0
    }
    else {
        print("I am in the else")
        #calculate average slope (to use for curvature calculation)
        acceleration_df$av_slope[i] <- (bindedlength$slope[i] + bindedlength$slope[i + 1]) / 2

        #calculate acceleration:
        a <- bindedlength$slope[i + 1]
        b <- bindedlength$slope[i]
        c <- bindedlength$x[i + 1]
        d <- bindedlength$x[i]
        if ((c - d) == 0) {
            this_accel <- 0
        }
        else {
            this_accel <- ((a - b) / (c - d))
        }
        acceleration_df$acceleration[i] <- this_accel
    }
    i <- i + 1
}
acceleration_df$acceleration[rows] <- 0
acceleration_df$av_slope[rows] <- 0
print("All instantaneous acceleration values and average slopes have been calculated")

bindedaccel <- bind_cols(bindedlength, acceleration_df)

#calculate curvature of each ridge:
all_curvatures_df <- data.frame(curvature = c(replicate(rows, 0)))
i <- 1
while (i < (rows-1)) {
    #if ridge # or cell # doesn't equal next one or 2 in front then skip
    if (bindedaccel$cell[i] != bindedaccel$cell[i + 1] | bindedaccel$cell[i] != bindedaccel$cell[i + 2]) {
        all_curvatures_df$curvature[i] <- 0
    }
    else if (bindedaccel$ridge[i] != bindedaccel$ridge[i + 1] | bindedaccel$ridge[i] != bindedaccel$ridge[i + 2]) {
        all_curvatures_df$curvature[i] <- 0
    }
    #remove errors from infinite values
    else if (((1 + (bindedaccel$av_slope[i] ^ 2)) ^ 1.5) == 0) {
        all_curvatures_df$curvature[i] <- 0
    }
    else {
        #calculate curvature by formula
        this_curvature <- abs(bindedaccel$acceleration[i]) / ((1 + (bindedaccel$av_slope[i] ^ 2)) ^ 1.5)
        all_curvatures_df$curvature[i] <- this_curvature
    }
    i = i + 1
}

print("All curvature values by formula calculated.")

bindedcurves <- bind_cols(bindedaccel, all_curvatures_df)
print(bindedcurves[c(1:25),])
    
#count the total number of ridges so I can initialize a data frame with zeros
i <- 1
ridge_counter <- 1
while (i < rows) {
    if (bindedaccel$ridge[i] == bindedaccel$ridge[i + 1]) {
        i = i + 1
    }
    else {
        ridge_counter = ridge_counter + 1
        i = i + 1
    }
}


ridge_position_list <- data.frame(position = c(replicate(ridge_counter, 0)))
#Get positions of the last row of each ridge:
i <- 1
counter <- 1
while (i < rows) {
    if (bindedaccel$ridge[i] == bindedaccel$ridge[i + 1]) {
        i = i + 1
    }
    else {
        ridge_position_list$position[counter] <- i
        counter = counter + 1
        i = i + 1
    }
}
ridge_position_list$position[ridge_counter] <- rows

ridge_curvatures <- data.frame(cell = c(replicate(ridge_counter, 0)), ridge = c(replicate(ridge_counter, 0)), length = c(replicate(ridge_counter, 0)), dist_endpoints = c(replicate(ridge_counter, 0)), curvature_bylength = c(replicate(ridge_counter, 0)), curvature_formula = c(replicate(ridge_counter, 0)))
pegs_to_remove <- c()
last_row <- 1
for (i in 1:ridge_counter) {
    #store cell ID and ridge number in first 2 columns
    ridge_curvatures$cell[i] <- as.vector(bindedcurves$cell[ridge_position_list$position[i]])
    ridge_curvatures$ridge[i] <- bindedcurves$ridge[ridge_position_list$position[i]]

    this_row <- ridge_position_list$position[i]

    #add curvatures over the ridge
    this_sum <- 0
    ridge_length <- 0
    for (a in last_row:this_row) {
        this_sum <- this_sum + bindedcurves$curvature[a]
        ridge_length <- ridge_length + bindedcurves$length[a]
    }

    #get distance between first and last point of the ridge to calculate the "simplified" curvature
    FL_dist <- sqrt((bindedcurves$x[last_row] - bindedcurves$x[this_row]) ^ 2 + (bindedcurves$y[last_row] - bindedcurves$y[this_row]) ^ 2)
    ridge_curvatures$dist_endpoints[i] <- FL_dist
    #calculate "simple" curvature by dividing length of the ridge by the distance between its endpoints
    if (FL_dist == 0) {
        ridge_curvatures$curvature_bylength[i] <- 0
    }
    else {
        ridge_curvatures$curvature_bylength[i] <- ridge_length / FL_dist
    }
    ridge_curvatures$length[i] <- ridge_length
    ridge_curvatures$curvature_formula[i] <- this_sum

    #change this to be <1 to take out only pegs. Right now, takes out pegs and ridges only 2 pixels long.
    if ((this_row - last_row) < 2) {
        pegs_to_remove <- c(pegs_to_remove, i)
    }

    last_row <- this_row + 1
}

print("Curvatures summed for each ridge and curvature by length calculated.")

#remove the ridges which were only or 2 pixels
ridge_curvatures_nopegs <- ridge_curvatures[-pegs_to_remove,]
print(ridge_curvatures_nopegs[c(1:25),])

print("Curvature math finished")

write.table(ridge_curvatures_nopegs, "OutputCurvatures.csv", row.names = FALSE, sep = ",")

print("Ridge curvatures saved in file OutputCurvature.csv")

```
