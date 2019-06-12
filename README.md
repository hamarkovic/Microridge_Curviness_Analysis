# Microridge Curviness Analysis
#### Hannah Markovic (hmarkovi@uoregon.edu) </br> June 12, 2019

This program takes pixel coordinate data from images of microridges and analyzes microridge 
curviness. Microridges are small ridges formed by actin protrusions on the surface of skin cells 
which are thought to function in mucus retention. These microridges are imaged on the surface 
of zebrafish skin cells by using LifeAct-GFP transgenic lines, making microridges 
fluorescent. Another member of the lab took these images and has a program that deconvolutes 
this data and turns it into a series of coordinates for each ridge. This program uses that 
existing data and returns an excel file containing a measure of curviness for each microridge.

### Introduction

Microridges are actin protrusions on the surface of skin cells. Our lab is interested in the development and function of these ridges in larval zebrafish. Images of ridges can be taken by labeling actin within the ridges with LifeAct-GFP, and imaging skin cells uing confocal microscopy. Some manipulations during development seem to increase the curviness of these ridges, so there was a need for an objective way to measure the "curviness" of the ridges of a cell. Therefore, I wrote the included scripts which output a measure of curvature of each ridge, both as a simple function of the total ridge length divided by the distance between the start and end points of each ridge, and as the sum of the mathematical curvature at each point divided by the total length of the ridge.

Additional information and images can be found at the [lab website](https://www.mcdb.ucla.edu/Research/Sagasti/Sagasti_lab_home.html), under Projects/Skin cell morphogenesis.

<img src="https://github.com/hamarkovic/Microridge_Curviness_Analysis/blob/master/Images/Microridges_from_Sagasti_website.gif" width="40%">

*Image from Sagasti lab website*

</br>

###  Program Workflow

There are 3 main scripts included in this repository, along with a master (wrapper) script which can run the program in Hoffman2.

#### Concatenate.sh
This is a bash script which concatenates the input csv files, and outputs a single csv with the concatenated information. It also adds a new column at the beginning of the csv storing each file name.

#### Point_Simplifier.rmd
This is an R script which uses the R package deldir to perform a [Voronoi tesselation](https://philogb.github.io/blog/2010/02/12/voronoi-tessellation/) with the input points (orange). It then uses the package rgeos to find the insersections of the polygons within the pixel boundaries (blue)

The R package PairViz (which requires having the packages TSP and graph installed) is used to perform an open Traveling Salesman Problem algorithm to order these points along the ridge (green), rather than by x value.

It loops this process over every ridge and cell, and saves the information as a csv which is the input for Curvature_Math.rmd

<img src="https://github.com/hamarkovic/Microridge_Curviness_Analysis/blob/master/Images/Voronoi%20after%20Viz%20green.gif">

#### Curvature_Math.rmd

This script calculates average slope and acceleration at each point of the ridge, and then uses the following formula to calculate curvature at each point. It adds these curvature values together, and then divides by the length of the ridge.

<img src="https://github.com/hamarkovic/Microridge_Curviness_Analysis/blob/master/W6_curvature_fomula.png" width="50%">

It also outputs a more simple measue of curvature obtained by dividing the total ridge length by the distance between the endpoints of the ridge.

<img src="https://github.com/hamarkovic/Microridge_Curviness_Analysis/blob/master/Sample_Curvature_Output.gif">

### Program Usage

#### Requirements
A Hoffman2 account, or another way to run bash scripts, is required to run this program over multiple files.
 * Alternatively, each file could be individually run through Point_Simplifier.rmd and Curvature_Math.rmd, but this would require changing file locations in the scripts every time you run the programs. </br>
 
You need to install these R packages, using the install.packages("*package*") command:  
 * [deldir](https://cran.r-project.org/web/packages/deldir/)
 * [graph](http://www.bioconductor.org/packages/3.4/bioc/html/graph.html) (For R 3.4)
 * [PairViz](https://cran.r-project.org/web/packages/PairViz/) 
 * [rgeos](https://cran.r-project.org/web/packages/rgeos/)
 * [sp](https://cran.r-project.org/web/packages/sp/)
 * [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)
 * [TSP](https://cran.r-project.org/web/packages/TSP/)

I wrote the program using the 3.3.2 version of R.  

The data must:
 * be in the form of x and y coordinates of the pixels of the skeletonized ridge, and with a column for ridge number.
 * be inputted in csv format.
 * There cannot be data files with identical names.
 * There cannot be spaces in file names.
 
#### Usage Instructions
These scripts can be individually run on your computer, or you can use the master script to run all of them.

All input files must be in the "Files_to_analyze" folder on Hoffman2; or, change the source of the files in the code, and run it on your computer with these files in a folder of your choosing.

To run the program in Hoffman2, follow these commands after cloning this github page and copying your files into Files_to_analyze, and removing delete_this from Files_to_analyze:

```{r}
cd Scripts/Vignette
cp *.csv ../Scripts/Files_to_analyze/
cd ../Scripts/Files_to_analyze
rm -i delete_this.txt
cd ../
module load R/3.5.1
R
install.packages("deldir")
install.packages("sp")
install.packages("rgeos")
install.packages("TSP")
source('http://bioconductor.org/biocLite.R')
biocLite('graph')
install.packages("PairViz")
install.packages("tidyverse")
q()
bash Master_Script.sh
```

#### Outputs
The program outputs a single csv file. The two columns of this file contain the cell ID and number of the ridge within that cell. The third column contains the ridge length. The fourth column contains a simple measure of curvature obtained by dividing the total length of the ridge by the distance between the endpoints of the ridge. The fifth column contains a curvature measure derived by calculating the curvature at each point using the first and second derivates, adding these values for each point of the ridge, and didviding by the length of the ridge.

#### Vignette
Vignette instructions are in the directory named Vignette.
1. To run this test file, you first need to follow the directions for how to run the program, and install the required packages.
2. Change the input in the file Point_Simplifier.rmd (read.csv command) to be the file "Ridge5_test.csv" in the appropriate location on your computer.
3. Change the ouput of the file (write.csv command) to be in the appropiate location on your computer.
4. Run the file Point_Simplifier in R.
5. The ouput will be the file "Points5.csv".
6. If you graph the points of the input and ouput, the input should look identical to the orange points in the file "Voronoi after Viz green.gif", and the output should look identical to the green points.

### Author
* Hannah Markovic
    * Biology PhD student at the University of Oregon
    * B.S. in Molecular, Cell and Developmental Biology with minor in Biomedical Research, UCLA
    * contact: hmarkovi@uoregon.edu
* This program was created as the final project for the class EEB 177, Spring 2019, UCLA

### Acknowledgements
* Aaron van Loon - microridge deconvolution program
* Kaiser Atai - sample data
* Dr. Emily Curd and Daniel Chavez - guidance

### References
* https://rstudio-pubs-static.s3.amazonaws.com/202536_7a122ff56e9f4062b6b012d9921afd80.html
* http://tutorial.math.lamar.edu/Classes/CalcIII/Curvature.aspx
* https://stackoverflow.com/questions/9595117/identify-a-linear-feature-on-a-raster-map-and-return-a-linear-shape-object-using
* https://cran.r-project.org/web/packages/deldir/
* https://cran.r-project.org/web/packages/rgeos/
* https://cran.r-project.org/web/packages/sp/
* https://cran.r-project.org/web/packages/PairViz/
* https://cran.r-project.org/web/packages/TSP/
* http://www.bioconductor.org/packages/release/bioc/html/graph.html
