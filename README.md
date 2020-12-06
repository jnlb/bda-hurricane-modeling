# bda-hurricane-modeling
Course project for the Aalto Bayesian Data Analysis 2020 course.

## Requirements

This project uses R 4.0.3 and should be compatible with any R version above 4.

It is recommended to use RStudio.

### Libraries

* rstan
* ggplot2
* mice
* parallel

## Initialize the R environment

To start using the project, in RStudio: `File > Open Project` then choose 
`bda-hurricane-modeling.Rproj`. This is only for setting the correct working 
directory and is not strictly necessary.

In the R console run the commands below to initialize the project environment.
```
source('init.r')
load_data()
```

By default this adds the SHIPS data and some variables to the global R environment.

## How to use load_data()

The function `load_data()` will by default create a variable `VMAX12` representing the 
`VMAX` value 12 hours in the future for each row. There are some relevant settings that 
you can change.

**Forecast period:** If you input something like `load_data(forecast=F)` then if F is a positive multiple
of 6 the function will create a `VMAXF` variable instead. By default `F=12`.

**Variable selection:** Another part of the default config is that it automatically selects a small number 
of variables. The default is `load_data(type="basic")` which keeps the variables 
`CSST, RHLO, SHRD, T200` 
(sea surface temp, rel. humidity at low altitiude, wind shear, and air temp at 200mb height).
The following settings will be interpreted by `load_data`:

* `type="minimal-A"`: CSST, SHRD
* `type="minimal-B"`: CSST, SHRD, VMPI
* `type="basic"`: CSST, RHLO, SHRD, VMPI, T200
* `type="nonlinear"`: INCV, U200, RHMD, REFC, G250, T150, VVAV, CSST, SHRD
* `type="large"`: HIST, INCV, CSST, CD20, NAGE, U200, V20C,
                  ENEG, RHLO, RHHI, PSLV, D200, REFC, PEFC,
                  TWXC, G200, G250, TGRD, TADV, SHDC, SDDC,
                  T150, T200, SHRD, SHTD, VMPI, VVAV, CFLX
* `type="all"`: loads entire set

**DELTA-V vs. FUTURE VMAX:** There is an option to select creation of a 
'delta' type variable by writing `load_data(target="delta")`. This creates instead
a variable `DELTA12(t) = VMAX(t+12) - VMAX(t)`. However the default is 
`target="value"` which creates the normal `VMAX12` target variable.

**Standardize data:** By default `load_data()` keeps the data in the normal scale. 
If given the option `standardize=TRUE`, it will standardize the entire dataset and store
variables `vmax_mu, vmax_sd, y_mu, y_sd` in the R environment.

There is a function called `transform_back()` which is called by giving it the input
`transform_back(VMAX, mu=vmax_mu, sd=vmax_sd)` to transform VMAX back to the normal scale 
(or respectively the same with y, the dependent variable which is either VMAX12 or DELTA12).

## Modeling scripts

Here is a list of the R scripts used in modeling.

* `minimal_models.R`: perform the Stan simulations and generate LOO-PSIS performance statistics
* `data_exploration.R`: an early script for looking at correlation plots
* `tests.R`: validate the chosen model by comparing with empirical data for a chosen storm

Old scripts that are/were essential for development.

* `init.R`: shortcut script that intializes everything and sets up help functions, etc.
* `data_processing.R`: a minor script that was used for data preprocessing

The rest of the scripts are essentially junk.

## A note on the data

Under `data` there is a dataset `atl-ships-data.csv` with ~130 covariates and the outcome variable of interest, 
`VMAX`.

To understand the data, you first need to understand a few basics.

- ID: this is a storm ID assigned by the WMO (World Meteorological Org)
- TIME: ISO formatted date and hour: YYYY-MM-DD HH
- VMAX: given in knots; rounded to nearest multiple of 5 (real-time observations are not very precise)
- MSLP: minimum sea-level pressure; actually a kind of alternative to VMAX since intensity and pressure correlate

Further, in the SHIPS data the value 9999 is used for NA. Just keep this in mind when loading the data into R.

Another thing to remember is that the values are all stored in integer form (a trick to save storage space, I think).
So for example, the `CSST` variable is 274 when the sea-surface temperature is 27.4 Celsius.

Most of the variables are difficult to understand for non-meteorologists. I have included a list of variables 
from the SHIPS website (docx format). The list does not really explain everything well, but it gives some info.
If you want to get a deeper understanding you can try reading the first scientific publication about the SHIPS model.
I have included the article in the project folder. Just keep in mind that the scientific publications are full 
of jargon and we are mostly here to do some analysis on one data set, so we don't need to know everything.
