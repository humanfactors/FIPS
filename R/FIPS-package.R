#' FIPS: The Fatigue Impairment Prediction Suite
#'
#' The "Fatigue Impairment Prediction Suite" (FIPS) is currently under development and implemented in the R programming language.
#' FIPS provides researchers and practitioners comprehensive set of functions for applying bio-mathematical models (BMMs) of fatigue.
#' FIPS is under active development and implemented in the R programming language.
#' FIPS provides a set of well-documented functions for transforming sleep and actigraphy data to formats required for applying BMMs,
#' as well as a set of functions for simulating and interpreting BMMs with several kinds of models and customisable parameter settings.
#'
#' BMMs are a class of biological phenomenological models which are used to predict the neuro-behavioural
#' outcomes of fatigue (e.g., alertness, performance) using sleep-wake history.
#' These models are frequently applied by defence and industrial sectors to support system
#' safety as part of broader fatigue management strategies.
#' FIPS is the first open-source BMM framework enabling practitioners to inspect, validate, and ideally extend BMMs.
#' Although there are several different implementations of BMMs, most have their roots in Borbély's (1982)
#'  two process model which models sleepiness/performance impairment as the sum of two processes: a circadian process and a homeostatic process.
#'
#' @import ggplot2
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr mutate bind_rows ungroup group_by
#' @import lubridate
#' @importFrom rlang sym ensym :=
#' @importFrom tidyr expand complete pivot_longer
#' @importFrom checkmate assert_posixct assert_true
#' @importFrom stats time
"_PACKAGE"

