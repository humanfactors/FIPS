---
title: 'FIPS: An R Package for Biomathematical Modelling of Human Fatigue Related Impairment'
tags:
  - R
  - psychobiology
  - human factors
  - fatigue
  - biomathematical modelling
  - dynamic models
authors:
  - name: Michael David Wilson
    orcid: 0000-0003-4143-7308
    affiliation: 1
  - name: Luke Strickland
    orcid: 0000-0002-6071-6022
    affiliation: 1
  - name: Timothy Ballard
    orcid: 0000-0001-8875-4541
    affiliation: 2
affiliations:
 - name: Future of Work Institute, Curtin University
   index: 1
 - name: School of Psychology, University of Queensland
   index: 2
date: May 01 2020
bibliography: sleep.bib
---

# Summary

In many workplace contexts, accurate predictions of a human's fatigue
state can drastically improve system safety. Biomathematical models of
fatigue (BMMs) are a family of dynamic phenomenological models that
predict the neurobehavioural outcomes of fatigue (e.g., sleepiness,
performance impairment) based on sleep/wake history [@Dawson2017].
However, to-date there are no open source implementations of BMMs, and
this presents a significant barrier to their broadscale adoption by
researchers and industry practitioners.

`FIPS` is an open source R package [@R] to facilitate BMM research and
simulation. FIPS has implementations of several published
bio-mathematical models and includes functions for easily manipulating
sleep history data into the required data structures. FIPS also includes
default plot and summary methods to aid model interpretation. Model
objects follow tidy data conventions [@wickham2014tidy], enabling FIPS to be
integrated into existing research workflows of R users.

# Background on Biomathematical Models

Borbély's [-@Borbely1982] seminal two-process BMM specifies that
subjective fatigue is modulated by the additive interaction of two
biological processes: the homeostatic and the circadian. The homeostatic
process, denoted by *S*, is responsible for the increase in fatigue
during wake and the recovery from fatigue during sleep. Fluctuations in
process *S* are described by exponential functions with fixed lower and
upper asymptotes. The endogenous circadian process, denoted by *C*,
reflects the effect of the body clock on sleep propensity. The dynamics
of these processes are driven by a set of governing parameters (e.g.,
the phase of the circadian process). Figure 1 below shows the additive
effects of varying governing parameters of S and C. This model has
formed the basis of many other models that predict neurobehavioural
performance and fatigue based on sleep history 
[@Akerstedt2008; @peng18_improved; @ramakrishnan16_unified_model; @hursh_fatigue_2004].

![A parameter sensitivity plot of the Three Process Model. The _x_ axis
represents a 24 hour day, with the dark gray plot regions indcating sleep and
the light gray indicating wake. The top panel shows the homeostatic process with
five variations of the $\tau_{d}$ parameter and the centre panel shows the
circadian process with five variations of the $\varphi_{phase}$ parameter. The
bottom panel shows the multiplicative combinations of all unique S and C
processes from the previous panels. The plot was produced with functionality in
`FIPS`.](FIPS_Fatigue_2PM.png)

BMMs have a rich history of application in laboratory sleep deprivation studies
where they are used to understand the latent factors underlying human fatigue.
An important aim of these studies is to identify the governing parameter values
which provide the best account for the data at hand [@Reifman2004]. Further,
propriety BMM implementations are frequently applied in safety-critical
industries (e.g., aviation, military, mining operations) to support system
safety as part of broader fatigue management strategies 
[e.g., aiding in rostering decisions; see @Dawson2017; @dawson_modelling_2011].

Unfortunately, the broader adoption of BMMs by the cognitive and behavioral
sciences has been constrained by several factors. Firstly, BMM researchers have
typically only provided the mathematical derivations of their models (i.e.,
formulae) and not their computational implementations. This is a barrier to
reproducibility [@wilson2019all] because implementing BMMs and the required data
structures from the ground up requires substantial expertise and time
investment. Prior to FIPS, the only available BMM implementations were contained
within closed-source commercial software [e.g., SAFTE-FAST; @hursh_fatigue_2004].
Even for researchers and practitioners able to afford licenses, these tools
prohibit users from inspecting, modifying, independently evaluating, or
extending the code and contained models.

# Package Motivation and Features

`FIPS` aims to make BMM approaches accessible to a wider community and
assist researchers in conducting robust and reproducible biomathematical
modelling of fatigue. The package includes:

-   Functions to transform common sleep data formats into the
    longitudinal data structure required for conducting BMM simulation
    and estimation.

-   Well documented implementations of three forms of BMM: The Unified
    Model [@ramakrishnan16_unified_model] and Two- and Three-Process Models
    [@Akerstedt2008; @Reifman2004; @Borbely1982].

-   A function for plotting BMM outputs, including with observed data
    points. The visualisations are publication-ready, but flexibly
    adjusted via the `ggplot2` package.

The package also contains two vignettes: a walk-through of a sleep simulation
scenario which includes generating, transforming and analyzing the data;
and a detailed tutorial in plotting model outputs.

# FIPS Interface and Data Structures

Conducting a BMM simulation in FIPS requires users to generate a `FIPS_df`, a
tidy data frame containing a time series (based on sleep history) of all
variables required to conduct BMM research. FIPS supports two sleep data
formats, each format associated with a corresponding function that automatically
performs all required transformations to the `FIPS_df` format:

-   The `parse_sleeptimes` function transforms a data frame containing three
    vectors: sleep onset times, sleep end times (i.e., awakening), and the sleep
    episode sequence identifier. This format is human readable and well suited
    for individuals who are manually entering sleep history data (e.g., from a
    paper sleep diary).[^1]	

-   The `parse_sleepwake_sequence` function transforms a bit vector
    representing sleep (0) and wake (1) statuses, with each bit
    representing an equal epoch (e.g., 1 minute). While not very human
    readable, this data format is commonly output by actigraphy devices
    and their corresponding sleep/wake status algorithms (e.g.,
    Cole--Kripke). Consequently, this format is often supported by other
    proprietary BMM software.

[^1]: It should be noted that the `parse_sleeptimes` function may also be useful to users wishing to convert a set of human-readable sleep times (e.g., manually entered from a sleep diary) to a bit vector (i.e., a list of `1` or `0` values). This is because the `FIPS_df` contains a column representing the series as a bit vector (see `FIPS_df$wake_status_int`).

The resulting `FIPS_df` dataframe can then be sent to the simulation
dispatch function `FIPS_simulate` to execute a specific model. This
function requires: a `FIPS_df`, a model string (e.g., "unified"), and an associated
parameter vector for the selected model (`pvec`). Documentation is
provided for customizing each parameter in the `pvec`, with citations
for the default values. The returned `FIPS_simulation` data frame has
added columns for each time-step of the series, including model
predictions (e.g., alertness and sleepiness in the case of the three
process model), as well as time-varying model processes (e.g., the
circadian process, *c*, and homeostatic process, *s*). `FIPS_simulation`
predictions can be plotted by calling plot or `FIPS_plot` on the object,
and simulation and model configurations can be reviewed via `summary`
or `print`.

# Research & Future Development

FIPS is being actively developed as part of a broader research project
examining cognitive fatigue prediction in safety-critical workplace
environments. Given the extensibility of FIPS's implementation, we hope
other BMM researchers may consider collaborating to implement other BMMs
in the framework.

# Acknowledgments

The Future of Work Institute at Curtin University supported the
development of this package.

# License

This project is licensed under the "GNU Affero General Public License"
version 3 - see the LICENSE file for details

# References

