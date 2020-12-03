# bda-hurricane-modeling
Course project for the Aalto Bayesian Data Analysis 2020 course.

## Initialize the R environment

I have prepared some functions to make working smoother in the `init.r` file.
How to load the data automatically: in the R console, write

(make sure your R console is at the correct working directory, call `getwd()` to 
check which directory you are in)

```
source('init.r')
load_data()
```

I added an Rproj file to this repo so that you can open it to the correct wd in Rstudio
automatically. I didn't commit my `.Rprofile` file but I also recommend creating a 
1-line `.Rprofile` file with `source('init.r')`. 

By default this also adds a variable `VMAX12` to the set. 
The idea is that (all the other variables, VMAX, VMAX12) is treated as exchangeable.

## How to use load_data()

**Forecast period:** If you input something like `load_data(forecast=F)` then if F is a positive multiple
of 6 the function will create a `VMAXF` variable instead. But maybe we can stick to
the simpler case of 12 hour forecasts.

**Variable selection:** Another part of the default config is that it automatically selects a small number 
of variables. The default is `load_data(type="basic")` which keeps the variables 
`CSST, RHLO, SHRD, T200` 
(sea surface temp, rel. humidity at low altitiude, wind shear, and air temp at 200mb height).
Later we can add other configurations to include other variables. You can also call
`load_data(type="all")` if you want to keep the entire set.

**DELTA-V vs. FUTURE VMAX:** Finally, there is an option to select creation of a 
'delta' type variable by writing `load_data(target="delta")`. This creates instead
a variable `DELTA12(t) = VMAX(t+12) - VMAX(t)`. However the default is 
`target="value"` which creates the normal `VMAX12` target variable.

## Current next step(s)...

**30th Nov Update:** Over the weekend I developed some models. I've learned some things. 
First, we probably can't expect any high quality predictions out of these models. Even so, 
it's worth doing the model selection and finishing the report. A negative result is also a result.

Second, fitting some of these models with RStan can take a ridiculous amount of time. I added 
multicore settings to RStan so that (assuming you have a 4-core CPU), it simulates 4 chains on 
4 different CPU cores. Despite all of this, you can probably start an MCMC run and go have lunch, or 
read BDA3 or watch Youtube or something.

Here are a list of models to use:

- basic+linear: `load_data(type='basic')`, and `linear.stan` (in the R script: `linear_model.R`)
- basic+nonlinear: `load_data(type='basic')`, and `nonlinear.stan` (R script: `modelling.R`)
- nonlinear+nonlinear: `load_data(type='nonlinear')`, and `nonlinear.stan` (`nonlinear_model.R`)

All of the above are using a 'delta' type target (VMAX12 - VMAX). Could also change to a 'value' type 
(i.e. predicting raw VMAX12). Could also try using the 'nonlinear' variable set in the 'linear.stan' 
model (this would just entail changing to `type='nonlinear'` in the `load_data()` function in the 
`linear_model.R` script. 

This has kind of made me wonder, what kind of covariation does just the reduced variable set 
`CSST, SHRD, VMAX` have. There must be some pattern that our linear models fail to find. But at this 
point it's probably no longer reasonable to completely change direction and develop something new 
for the project.

**3rd Dec Update:**
I executed all the model, but I just realized that the second one only run for 2000 iterations (convergence was reached, but it is running now for 4000).

I merged all the three model executions to one file where the comparison is performed, I added it here, but I did not remove the individuals R files.

The linear model is the worst, and the other ones are extremely similar, which means that some of the variables included in the so-called "nonlinear" data are not necessary, however I though that the "nonlinear" dataset contained the same as the the "basic" dataset + other variables, but two of the variables in the "basic" are not in the "nonlinear".

I also added a small correlation plot of the variables we actually use (we can include it or not, but I think it can be nice)

## Idea

Under `data` there is a dataset `atl-ships-data.csv` with ~130 covariates and the outcome variable of interest, 
`VMAX`.

The idea is to formulate a Bayesian model for **future values of VMAX**. In the American NHC (National Hurricane 
Center) they do this using a multiple regression model, we should start out with something like this as well.

### What even is all of this

Hurricanes (aka tropical cyclones) work something like this: when a low-pressure point has formed in a tropical 
region (over sea), this leads to winds flowing to that point. Due to the spinning motion of the Earth, this leads
to a circular motion around the point (= cyclone). The cyclonic motion also leads to a counter-force in the form 
of the centrifugal force. There is a kind of 'critical' circular region where the force pushing winds into the 
center is balanced by the centrifugal force - this leads to a natural circle shape which is called the 'eyewall' 
of the hurricane. And inside of this circle is the region called the 'eye' of the storm. Winds are less intense 
inside the eye, but in the eyewall winds can be very destructive, and the wind strength falls slowly on the 
outside of the eye.

In short, we want to model changes of the wind intensity in the eyewall, this is the `VMAX` variable. 
So this leads to the question: what leads hurricanes to intensify, or to weaken? There are some variables which 
are known to be important. Unfortunately not all is well-understood by meteorologists, but there are some 
core principles:

- high sea temperatures (>28 deg C) cause convection, which can lower the pressure in the eye, leading to more force pushing winds into the eye
- strong wind shear (differences between winds low and high in the atmosphere) can destabilize the storm, making it more difficult to intensify
- high humidity is a good condition for convection

In the SHIPS dataset there are variables representing all of this, so we should easily be able to get a minimal 
model for intensity change.

### On the data

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

### I have processed the SHIPS data

Here is how the SHIPS data looked at first:

![atlantic ships data](images/shot1.png)

So you see that they had a weird column system. Well, the important data is under TIME = 0 in this format, so I 
extracted that column for every time step and saved to to a data frame. If you want to check what I did, see the 
file `data_processing.r`, a file where I wrote some functions with vanilla R to do the work.
The final CSV data is now saved in the path 
`data/atl-ships-data.csv`. 
