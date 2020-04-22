# Fatigue Impairment Prediction Suite (FIPS)

<img align="right" src="inst/logo/FIPS_logo.png?raw=true" alt="FIPSLOGO" width="200"/> 

FIPS provides researchers and practitioners comprehensive set of functions for applying bio-mathematical models (BMMs) of fatigue. FIPS is under active development and implemented in the R programming language. FIPS provides a set of well-documented functions for transforming sleep and actigraphy data to formats required for applying BMMs, as well as a set of functions for simulating and interpreting BMMs with several kinds of models and customisable parameter settings. 

BMMs are a class of biological phenomenological models which are used to predict the neuro-behavioural outcomes of fatigue (e.g., alertness, performance) using sleep-wake history. These models are frequently applied by defence and industrial sectors to support system safety as part of broader fatigue management strategies. FIPS is the first open-source BMM framework enabling practitioners to inspect, validate, and ideally extend BMMs. Although there are several different implementations of BMMs, most have their roots in Borbély's (1982) two process model which models sleepiness/performance impairment as the sum of two processes: a circadian process and a homeostatic process.

## Installation
To install the latest development version of FIPS:

```R
# install.packages('remotes') # if remotes not installed
remotes::install_github("humanfactors/FIPS", build_vignettes = TRUE)
```

It is highly recommended to build the vignettes (though do note this has additional dependencies).

## Additional Terms for Academic Usage
In addition to the rights stipulated in the GNU AFFERO GENERAL PUBLIC LICENSE, we request that all work leveraging FIPS provide a direct citation to the software package. Please contact the authors for this citation (as of 22/04/2020). We aim to have a manuscript for citation soon.

## Using FIPS

Full walkthroughs for using FIPS can be found at

Currently all FIPS simulations **must** start with the *Sleep Data Format*  unless you are able to directly create a dataframe compliant with the *FIPS data format*.

**The Sleep Data Format** looks as follows:

|sleep.start         |sleep.end           | sleep.id|
|:-------------------|:-------------------|--------:|
|2018-05-11 07:07:00 |2018-05-11 12:55:00 |        1|
|2018-05-12 06:14:00 |2018-05-12 12:50:00 |        2|
|2018-05-14 01:55:00 |2018-05-14 06:29:00 |        3|
|2018-05-14 13:30:00 |2018-05-14 14:58:00 |        4|

Ideally, you should use these column names and format to avoid conflicts with the generated column names. Optional ID variables (e.g., name, location, notes) may also be present, but avoid conflicts with the names required in the FIPS dataframe format (shown below).

You can generate the FIPS format (from a sleep data format) with the  `parse_sleeptimes` function.

```R
# Simulation start date time (i.e., when you want first predictions to begin)
simulation.start = lubridate::ymd_hms('2018-05-01 07:00:00', tz = "Australia/Perth")
# Simulation end date time (i.e., when you want predictions to end)
simulation.end = lubridate::ymd_hms('2018-05-07 21:00:00', tz = "Australia/Perth")
# The Continuous FIPS_df dataframe format
# This creates the format ready for simulation
simulated.dataframe = parse_sleeptimes(
  sleeptimes = example.sleeptimes,
  series.start = simulation.start,
  series.end = simulation.end,
  sleep.start.col = "sleep.start",
  sleep.end.col = "sleep.end",
  sleep.id.col = "sleep.id",
  roundvalue = 5
  )

```
The resulting dataframe output (of class `FIPS_df`) can then be sent the simulation dispatch function `FIPS_simulate()`. The simulation functions require a parameter vector/list (pvec). Please see `TPM_make_pvec()` or `unified_make_pvec()` to generate these vectors.

In the example below, we will run a Three Process Model simulation over the `FIPS_df` series we just created. To do this, we will use the `FIPS_simulation` function, which takes in three arguments: a `FIPS_df` object, a specification of a `modeltype` (see help for model types currently implemented), and a `pvec` which is a vector of parameters for the model.

Calling `FIPS_simulate()` will the produces a `FIPS_df` with model predictions and predicted model parameter values (e.g., `s`, `c`). The returned `FIPS_df` will also now inherit the `FIPS_simulation` class.  A `FIPS_simulation` object has attributes containing the parameter vector, the `modeltype` string, and the `pvec` used, and several other values used internally. A custom print function of the object will reveal all this information. Note that this print function does mask some of the columns for ease of reading.

```r
# Run a simulation with the three process model
TPM.simulation.results = FIPS_simulate(
  FIPS_df = simulated.dataframe, # The FIPS_df
  modeltype = "TPM",             # three process model
  pvec = TPM_make_pvec()       # parameter vector with defaults
  )
```

You now can access printing, summary and plot methods for the FIPS_simulation object. Note that further transformations to the object in dplyr and similar Tidyverse packages will remove attributes.

```R
plot(TPM.simulation.results)
summary(TPM.simulation.results)
print(TPM.simulation.results)
```

