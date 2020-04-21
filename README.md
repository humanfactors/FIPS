# Fatigue Impairment Prediction Suite (FIPS)

<img align="right" src="inst/logo/FIPS_logo.png?raw=true" alt="FIPSLOGO" width="200"/> 

FIPS provides researchers and practitioners comprehensive set of functions for applying bio-mathematical models (BMMs) of fatigue. FIPS is under active development and implemented in the R programming language. FIPS provides a set of well-documented functions for transforming sleep and actigraphy data to formats required for applying BMMs, as well as a set of functions for simulating and interpreting BMMs with several kinds of models and customisable parameter settings. 

BMMs are a class of biological phenomenological models which are used to predict the neuro-behavioural outcomes of fatigue (e.g., alertness, performance) using sleep-wake history. These models are frequently applied by defence and industrial sectors to support system safety as part of broader fatigue management strategies. FIPS is the first open-source BMM framework enabling practitioners to inspect, validate, and ideally extend BMMs. Although there are several different implementations of BMMs, most have their roots in Borbély's (1982) two process model which models sleepiness/performance impairment as the sum of two processes: a circadian process and a homeostatic process.

## Installation
To install the latest development version of FIPS:

```R
# install.packages('remotes') # if remotes not installed
remotes::install_github("humanfactors/FIPS")
```

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
FIPS::parsed.dats = parse_sleeptimes(
  sleeptimes = dats,
  series.start = ymd_hms("2018-05-11 5:07:00", tz = "Australia/Perth"),
  sleep.start.col = "sleep.start",
  sleep.end.col = "sleep.end",
  sleep.id.col = "sleep.id",
  roundvalue = 5
)

```
This dataframe can then be sent to one of the simulation functions. The simulation functions require a parameter vector/list (pvec). Currently no debugging is documentation is provided around dramatically customising these values, but just `dput` the `FIPS::pvec.threeprocess` if you want to see the required parameters.

```R
predicted.data = FIPS::simulate_TPM(pvec = FIPS::pvec.threeprocess, dat = test.dats)

```

