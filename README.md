[![Travis build status](https://travis-ci.com/humanfactors/FIPS.svg?branch=master)](https://travis-ci.com/humanfactors/FIPS)
[![codecov](https://codecov.io/gh/humanfactors/FIPS/branch/master/graph/badge.svg)](https://codecov.io/gh/humanfactors/FIPS)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.02340/status.svg)](https://doi.org/10.21105/joss.02340)

# Fatigue Impairment Prediction Suite (FIPS)

<img align="right" src="https://github.com/humanfactors/FIPS/blob/master/inst/logo/FIPS_logo.png?raw=true" alt="FIPSLOGO" width="200"/> 

> If you are measure sleep behaviour or want to predict fatigue, this package probably can help.

FIPS is an R package that provides researchers and practitioners with a comprehensive set of functions for applying and simulating from bio-mathematical models (BMMs) of fatigue.

FIPS includes a set of functions for transforming sleep and actigraphy data to the data frame structure required for executing BMM simulations(called a [`FIPS_df`](https://humanfactors.github.io/FIPS/reference/FIPS_df.html)). Importantly, FIPS includes a set of functions for simulating from and interpreting several forms of BMM, including the [Unified Model](https://www.sciencedirect.com/science/article/pii/S0022519313001811) and [Three Process Model](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0108679). All models are extendable and include customisable parameters. The core features of FIPS leverage R's flexible `S3` class system, making extensions straightforward.

## Installation
We have no plans for a CRAN submission. To install the latest version of FIPS:

```r
# install.packages('remotes') # if remotes not installed
remotes::install_github("humanfactors/FIPS")
```

# Core Features Example

Detailed information regarding the FIPS data formats can be found in the ["FIPS Simulation Walkthrough Vignette"](https://humanfactors.github.io/FIPS/articles/FIPS-simulation-walkthrough.html).


**Step 1:** Prior to simulation, FIPS requires sleep history data to be in a special format, called a [`FIPS_df`](https://humanfactors.github.io/FIPS/reference/FIPS_df.html) which contains all the information required for modelling (e.g., time awake, time asleep). This can be created with [`parse_sleepwake_sequence`](https://humanfactors.github.io/FIPS/reference/parse_sleepwake_sequence.html) or [`parse_sleeptimes`](https://humanfactors.github.io/FIPS/reference/parse_sleeptimes.html).

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
  # formula = alertness ~ s + c + u + w  # An optional formula for output
)

# Run a simulation with the unified model
unified.simulation.results = FIPS::FIPS_simulate(
FIPS_df = my_FIPS_dataframe,   # A FIPS_df
modeltype = "unified",         # Unified model
pvec = unified_make_pvec()     # Default parameter vector
)  
```

```
$ print(TPM.simulation.results)
> ---------
> Model Type: TPM 
> Epoch Value: 5 minutes 
> Simulation duration: 60 hours 
> Time points: 721 
> Parameters used (pvec input): ...[Suppressed for README]...
> For descriptions of these parameters, inspect:  help(FIPS::TPM_make_pvec) 
> ---------
> # A tibble: 721 x 10
>    datetime             time wake_status sim_hours     s     c     w        u   KSS alertness
>    <dttm>              <dbl> <lgl>           <dbl> <dbl> <dbl> <dbl>    <dbl> <dbl>     <dbl>
>  1 2020-05-21 08:00:00  8    TRUE           0       7.96 -1.67 -5.72 -0.00274 10.3       6.28
>  2 2020-05-21 08:05:00  8.08 TRUE           0.0833  7.94 -1.63 -5.04 -0.00549  9.84      6.31
>  3 2020-05-21 08:10:00  8.17 TRUE           0.167   7.93 -1.59 -4.45 -0.00919  9.47      6.33
>  4 2020-05-21 08:15:00  8.25 TRUE           0.25    7.91 -1.55 -3.92 -0.0138   9.14      6.35
>  5 2020-05-21 08:20:00  8.33 TRUE           0.333   7.89 -1.50 -3.46 -0.0194   8.85      6.37
>  6 2020-05-21 08:25:00  8.42 TRUE           0.417   7.88 -1.46 -3.05 -0.0258   8.59      6.39
>  7 2020-05-21 08:30:00  8.5  TRUE           0.5     7.86 -1.42 -2.69 -0.0332   8.36      6.41
>  8 2020-05-21 08:35:00  8.58 TRUE           0.583   7.85 -1.37 -2.37 -0.0415   8.16      6.43
>  9 2020-05-21 08:40:00  8.67 TRUE           0.667   7.83 -1.32 -2.09 -0.0506   7.98      6.46
> 10 2020-05-21 08:45:00  8.75 TRUE           0.75    7.81 -1.28 -1.84 -0.0606   7.82      6.48
> # ... with 711 more rows
```

```
$ print(unified.simulation.results)
> ---------
> Model Type: unified 
> Epoch Value: 5 minutes 
> Simulation duration: 60 hours 
> Time points: 721 
> Parameters used (pvec input): ...[Suppressed for README]...
> For descriptions of these parameters, inspect:  help(FIPS::unified_make_pvec) 
> ---------
> # A tibble: 721 x 9
>    datetime             time wake_status sim_hours      s      l     c     w fatigue
>    <dttm>              <dbl> <lgl>           <dbl>  <dbl>  <dbl> <dbl> <dbl>   <dbl>
>  1 2020-05-21 08:00:00  8    TRUE           0      0      0      0.335 1.14     1.38
>  2 2020-05-21 08:05:00  8.08 TRUE           0.0833 0.0502 0.0206 0.320 1.10     1.37
>  3 2020-05-21 08:10:00  8.17 TRUE           0.167  0.100  0.0412 0.305 1.06     1.36
>  4 2020-05-21 08:15:00  8.25 TRUE           0.25   0.150  0.0618 0.291 1.02     1.35
>  5 2020-05-21 08:20:00  8.33 TRUE           0.333  0.200  0.0824 0.276 0.978    1.34
>  6 2020-05-21 08:25:00  8.42 TRUE           0.417  0.250  0.103  0.261 0.941    1.33
>  7 2020-05-21 08:30:00  8.5  TRUE           0.5    0.300  0.123  0.247 0.906    1.32
>  8 2020-05-21 08:35:00  8.58 TRUE           0.583  0.349  0.144  0.232 0.872    1.31
>  9 2020-05-21 08:40:00  8.67 TRUE           0.667  0.399  0.164  0.218 0.839    1.30
> 10 2020-05-21 08:45:00  8.75 TRUE           0.75   0.448  0.185  0.204 0.807    1.29
> # ... with 711 more rows
```

**Step 3:** You now can access printing, summary and plot methods for the FIPS_simulation object. A [detailed tutorial of the plotting functionality](https://humanfactors.github.io/FIPS/articles/plotting.html) for FIPS is provided in the vignettes.

```r
plot(TPM.simulation.results)
summary(TPM.simulation.results)
print(TPM.simulation.results)
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
