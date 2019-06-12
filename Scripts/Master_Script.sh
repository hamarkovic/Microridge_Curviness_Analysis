#!/bin/bash

bash concatenate.sh

Rscript --vanilla Point_Simplifier.R

Rscript --vanilla Curvature_Math.R
