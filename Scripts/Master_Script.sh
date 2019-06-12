#!/bin/bash

bash concatenate.sh

Rscript Point_Simplifier.rmd

Rscript Curvature_Math.rmd
