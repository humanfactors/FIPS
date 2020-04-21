#' FIPS: The Fatigue Prediction Suite
#'
#' The “Fatigue Impairment Prediction Suite (FIPS) is currently under development and implemented in the R programming language. FIPS aims to provide practitioners a comprehensive set of functions for estimating and applying bio-mathematical models (BMMs).
#'
#' Specifically, FIPS aims to provide the following: (1) a set of well-documented functions for transforming sleep and actigraphy data to formats required for applying BMMs; (2) a set of functions for simulating fatigue scenarios (with customisable parameter settings and models), including visualisations of results; (3) importantly, FIPS offers a set of functions for conducting parameter estimation of BMMs in a Bayesian Framework using the ‘Stan’ language; and (4) a web-based application named, FIPS, which allows users to run simulations with a graphical user interface (GUI) without the need for programming expertise. It is crucial to highlight that FIPS is the first open-source BMM framework enabling defence researchers to inspect, validate, and ideally extend the code, and the only model implemented under a Bayesian probabilistic framework.
#'
#' BMM’s are a class of biological phenomenological models which are used to predict the neuro-behavioural outcomes of fatigue (e.g., alertness, performance) using sleep-wake history. These models enable hypothesis testing of the latent factors underlying the relationships between sleep, fatigue, and human performance, and are frequently applied by defence and industrial sectors to support system safety as part of broader fatigue management strategies.
#'
#' @import ggplot2
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr mutate bind_rows ungroup group_by
#' @import lubridate
#' @importFrom rlang sym ensym :=
#' @importFrom tidyr expand complete pivot_longer
#' @importFrom checkmate assert_posixct assert_true
"_PACKAGE"

