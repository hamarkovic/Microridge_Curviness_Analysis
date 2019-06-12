## Vignette Information

The Vignette runs the entire program, but with a small data set consisting of only 2 cells. One cell has microridges which appear more curved (Curved_test.csv), while the other has normal microridges (Not_curved_test.csv). The outputs will be __, and they should match the output files in the directory Sample_Outputs. Averaging the values over the cells shows that the Curved_test cell has a greater curvature according to curvature_bylength (1.77 vs 1.13), but is in fact less curved based on curvature_formula (92.20 vs 188.86).

## Running the Vignette:

Log in to Hoffman2, then use these commands to run the Vignette:
```{r}
git clone https://github.com/hamarkovic/Microridge_Curviness_Analysis
cd Microridge_Curviness_Analysis
cd Vignette
cp *.csv ../Scripts/Files_to_analyze/
cd ../Scripts/Files_to_analyze
rm delete_this.txt
cd ../
module load R/3.5.0
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
Some notes:
 * If you already have R loaded on your terminal, it's sometimes necessary to repeat the line: module load R/3.5.0
 * The first time you install a package, it will ask you to select a CRAN mirror
 * If it asks to update any packages, say "n".
 * It's not necessary to save the workspace image after quitting R.
