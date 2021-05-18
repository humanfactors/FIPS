[![Travis build status](https://travis-ci.com/humanfactors/FIPS.svg?branch=master)](https://travis-ci.com/humanfactors/FIPS)
[![codecov](https://codecov.io/gh/humanfactors/FIPS/branch/master/graph/badge.svg)](https://codecov.io/gh/humanfactors/FIPS)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.02340/status.svg)](https://doi.org/10.21105/joss.02340)

# Fatigue Impairment Prediction Suite (FIPS)

<img align="right" src="https://github.com/humanfactors/FIPS/blob/master/inst/logo/FIPS_logo.png?raw=true" alt="FIPSLOGO" width="200"/> 

> If you are measure sleep behaviour or want to predict fatigue, this package probably can help.

FIPS provides researchers and practitioners comprehensive set of functions for applying bio-mathematical models (BMMs) of fatigue. FIPS is a young project under active development and is implemented in the R programming language. 

FIPS includes a set of well documented functions for transforming sleep and actigraphy data to the data frame structure (called a [`FIPS_df`](https://humanfactors.github.io/FIPS/reference/FIPS_df.html)) required for executing BMM simulations. Importantly, FIPS includes a set of functions for simulating from and interpreting several forms of BMM, including the Unified Model and Three Process Model. All models are extendable and include customisable parameters. The FIPS data structures also make parameter estimation more reproducible and standardised. All features of FIPS are based in `S3` classes, making extensions straightforward.

## Installation
To install the latest version of FIPS:

```r
# install.packages('remotes') # if remotes not installed
remotes::install_github("humanfactors/FIPS")
```

# Example Use

Detailed information regarding the FIPS data formats in the ["FIPS Simulation Walkthrough Vignette"](https://humanfactors.github.io/FIPS/articles/FIPS-simulation-walkthrough.html).


**Step 1:** Prior to simulation, FIPS requires sleep history data to be in a special format, called a [`FIPS_df`](https://humanfactors.github.io/FIPS/reference/FIPS_df.html) which contains all the information required for modelling (e.g., time awake, time asleep). This can be created with [`parse_sleepwake_sequence`](https://humanfactors.github.io/FIPS/reference/parse_sleepwake_sequence.html) or [`parse_sleeptimes](https://humanfactors.github.io/FIPS/reference/parse_sleeptimes.html).

```r
my_FIPS_dataframe = FIPS::parse_sleepwake_sequence(
  seq = unit_sequence,  # A binary (1,0) vector 
  epoch = 5,            # Epoch in minutes of vector
  series.start = as.POSIXct("2020-05-21 08:00:00"))
```

**Step 2:** To run a model simulation, you use [`FIPS_simulate`](https://humanfactors.github.io/FIPS/reference/FIPS_simulate.html), which returns a `FIPS_simulation` with all model predictions/forecasts generted in the corresponding columns. Note that the formula argument is optional, and sensible defaults will be used if omitted.

```r
# Run a simulation with the three process model
TPM.simulation.results = FIPS::FIPS_simulate(
  FIPS_df = my_FIPS_dataframe,   # A FIPS_df
  modeltype = "TPM",             # Three Process Model
  pvec = TPM_make_pvec()         # Default parameter vector
  formula = alertness ~ s + c + u + w) # A formula for output
---------
> Model Type: TPM 
> Epoch Value: 5 minutes 
> Simulation duration: 0.4166667 hours 
> Time points: 6 
> For descriptions of these parameters, inspect: help(FIPS::TPM_make_pvec) 
> ---------
> # A tibble: 6 x 10
>   datetime             time wake_status sim_hours     s     c     w      u   KSS alertness
>   <dttm>              <dbl> <lgl>           <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>     <dbl>
> 1 2018-05-02 21:55:00  21.9 TRUE           0       7.96 0.573 -5.72 -0.277  9.08      8.26
> 2 2018-05-02 22:00:00  22   TRUE           0.0833  7.94 0.520 -5.04 -0.297  8.73      8.17
> 3 2018-05-02 22:05:00  22.1 TRUE           0.167   7.93 0.466 -4.45 -0.317  8.42      8.08
> 4 2018-05-02 22:10:00  22.2 TRUE           0.25    7.91 0.413 -3.92 -0.337  8.16      7.99
> 5 2018-05-02 22:15:00  22.2 TRUE           0.333   7.89 0.359 -3.46 -0.358  7.94      7.90
> 6 2018-05-02 22:20:00  22.3 TRUE           0.417   7.88 0.305 -3.05 -0.379  7.75      7.80
```




## What are BMMs?

BMMs are a class of biological phenomenological models which are used to predict the neuro-behavioural outcomes of fatigue (e.g., alertness, performance) using sleep-wake history. There are several different BMM implementations, but most have their roots in Borbély's (1982) two process model which stipulates that sleepiness/performance impairment functions in response to two processes: a circadian process and a homeostatic process. BMMs enable hypothesis testing of the latent factors underlying the relationships between sleep, fatigue, and human performance. For example, they enable researchers to estimate the relative contributions of homeostatic processes on fatigue, relative to endogenous circadian processes. These models are also frequently applied by defence and industrial sectors to support system safety as part of broader fatigue management strategies. FIPS is the first open-source BMM framework enabling practitioners to inspect, validate, and ideally extend BMMs. 

# Contributing and Support

We welcome contributions great or small from the community. It would incredibly useful to receive feedback via Github Issues for anything regarding the package, including: installation issues, bugs or unexpected behaviour, usability, feature requests or inquiries, or even something you don't understand in the tutorials about this class of models more generally. Please file a Github issue for any general support queries too.

# Terms for Academic Usage
In addition to the rights stipulated in the GNU Affero GPL-3, we request that all academic work leveraging FIPS provide a direct citation to the software package.

Wilson et al., (2020). FIPS: An R Package for Biomathematical Modelling of Human Fatigue Related Impairment. _Journal of Open Source Software_, 5(51), 2340, https://doi.org/10.21105/joss.02340

```tex
@article{Wilson2020,
  doi = {10.21105/joss.02340},
  url = {https://doi.org/10.21105/joss.02340},
  year = {2020},
  publisher = {The Open Journal},
  volume = {5},
  number = {51},
  pages = {2340},
  author = {Michael David Wilson and Luke Strickland and Timothy Ballard},
  title = {FIPS: An R Package for Biomathematical Modelling of Human Fatigue Related Impairment},
  journal = {Journal of Open Source Software}
}
```
