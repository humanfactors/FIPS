
## Simple Use Case

Full walkthroughs for using FIPS can be found in the vignette `vignette("FIPS-simulation-walkthrough","FIPS")`, with further information about plotting in `vignette("plotting","FIPS")`. These files can also be directly accessed from the source Rmarkdown files under `./vignettes`.

All FIPS simulations require a `FIPS_df` object (see, `?FIPS::FIPS_df`), which is a form of data frame. There are two methods for generating a `FIPS_df` from existing data:

- `parse_sleepwake_sequence` can be used to convert a sequence of sleep wake statuses (e.g., binary sequence with equidistance temporal spacing. This is the format used by other proprietary BMM software as well as several actigraphy-based sleep detection algorithms. 
- `parse_sleeptimes` can be used to convert a data frame of sleep and wake times (and a sleep identifier) to a `FIPS_df` object.
- Note that advanced users should be able to create a data frame compliant with the *FIPS data format*. See `help("FIPS_df")`. 

For this example, we will run through a `parse_sleeptimes` example. You must start with a data frame in the *Sleep Data Format*, which is shown below. Importantly, the datetimes in the columns must be POSIXct datetime objects. We suggest leveraging lubridate for a simple datetime interface. Ideally, you should use these column names and format to avoid conflicts with the generated column names. 

**The Sleep Data Format** looks as follows:

|sleep.start         |sleep.end           | sleep.id|
|:-------------------|:-------------------|--------:|
|2018-05-11 07:07:00 |2018-05-11 12:55:00 |        1|
|2018-05-12 06:14:00 |2018-05-12 12:50:00 |        2|
|2018-05-14 01:55:00 |2018-05-14 06:29:00 |        3|
|2018-05-14 13:30:00 |2018-05-14 14:58:00 |        4|

For testing purposes, the following snippet shows how to generate a FIPS compliant sleep data frame (as shown above).

```r
example.sleeptimes <- tibble::tibble(
  sleep.start = seq(
    from = lubridate::ymd_hms('2018-05-01 23:00:00', tz = "Australia/Perth"), 
    to = lubridate::ymd_hms('2018-05-07 17:00:00', tz = "Australia/Perth"),
    by = '24 hours'),
  sleep.end = sleep.start + lubridate::dhours(7.5),
  sleep.id = rank(sleep.start))
```

Now that you have the correct sleep times input structure, you can generate the `FIPS_df` from the sleep data format via the `parse_sleeptimes` function.

```r
# Simulation start date time (i.e., when you want first predictions to start)
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
  roundvalue = 5)
```
The resulting dataframe output (of class `FIPS_df`) can then be sent the simulation dispatch function `FIPS_simulate()`. The simulation functions require a parameter vector/list (pvec). Please see help for `TPM_make_pvec()` or `unified_make_pvec()` for more information on generating these vectors.

In the example below, we will run a Three Process Model simulation over the `FIPS_df` series we just created. To do this, we will use the `FIPS_simulation` function, which takes in three arguments: a `FIPS_df` object, a specification of a `modeltype` (see help for model types currently implemented), and a `pvec` which is a vector of parameters for the model.

Calling `FIPS_simulate()` will produce a `FIPS_df` with model predictions and predicted model process values (e.g., `s`, `c`). The returned `FIPS_df` will also now inherit the `FIPS_simulation` class.  A `FIPS_simulation` object has attributes containing the parameter vector, the `modeltype` string, and the `pvec` used, and several other values used internally. A custom print function of the object will reveal all this information. Note that this print function does mask some of the columns for ease of reading.

```r
# Run a simulation with the three process model
TPM.simulation.results = FIPS_simulate(
  FIPS_df = simulated.dataframe, # The FIPS_df
  modeltype = "TPM",             # three process model
  pvec = TPM_make_pvec())       # parameter vector with defaults
```

You now can access printing, summary and plot methods for the FIPS_simulation object. Note that further transformations to the object in dplyr and similar Tidyverse packages will remove attributes.

```r
plot(TPM.simulation.results)
summary(TPM.simulation.results)
print(TPM.simulation.results)
```