#' FIPS Time Series Plot
#'
#' @param dats A FIPS_simulation object (i.e., FIPS_df with simulation results)
#' @param from The starting datetime to be plotted
#' @param to The ending datetime to be plotted
#' @param plot_stat Which variables to plot
#' @param fatigue_CIs A logical indicating whether uncertainty intervals on fatigue should be plotted
#' @param observed A data frame with any observed sleepiness ratings or objective indicators to plot against predictions
#' @param observed_y The name of the observed sleepiness ratings in the observed data frame
#'
#' @return A ggplot2 object displaying fatigue and other requested processes over time
#' @md
#' @export
FIPS_plot <- function(dats,
                      from = NULL,
                      to = NULL,
                      plot_stat = NULL,
                      fatigue_CIs = FALSE,
                      observed = NULL,
                      observed_y = NULL) {


  if(FIPS_Simulation_lost_attributes(dats)) {
    stop("Your FIPS_Simulation object has lost attributes (have you wrangled the dataframe with dplyr?).
          No plot method availble. Please manually save attributes if plotting essential.")
  }


  if(!is_FIPS_simulation(dats)) {
    stop("Requires a FIPS_df which has had model simulation run on it")
  }

  modeltype = get_FIPS_modeltype(dats)
  if(! modeltype %in% c("TPM", "unified")) {
    warning("You supplied a modeltype argument that doesn't match the model type specified in your
             FIPS_simulation FIPS_df. Defaulting to using one specified in the FIPS_df.")
  }

  # Figure out appropriate default plot_stat and observed_y based on modeltype
  if(is.null(plot_stat)) plot_stat <- get_FIPS_pred_stat_name(dats)
  # Make observation variable plot_stat unless otherwise specified
  if(is.null(observed_y)) observed_y <- plot_stat

  # Filter based on selected datetimes from and to
  if (!is.null(from)) {
    dats <- dats %>% dplyr::filter(datetime > from)
    if (!is.null(observed))
      observed <- observed %>% dplyr::filter(datetime > from)
    }

  if (!is.null(to)) {
    dats <- dats %>% dplyr::filter(datetime < to)
    if (!is.null(observed))
      observed <- observed %>% dplyr::filter(datetime < to)
  }

  if(!any((get_FIPS_pred_stat_name(dats) %in% plot_stat)) & fatigue_CIs == TRUE){
    warning("Will not plot fatigue CIs without a predicted model value (alertness/fatigue)")
    fatigue_CIs = FALSE
  }

  # Get start and end of sleeptimes for plotting sleep as rectangles
  sim_results <- dats  %>%
    dplyr::group_by(sleep.id) %>% dplyr::mutate(
      sleepstart = ifelse(is.na(sleep.id), NA, min(sim_hours)),
        sleepend = ifelse(is.na(sleep.id), NA, max(sim_hours))) %>%
    #Also get end of each day for dashed lines indicating day end
    dplyr::group_by(day) %>%
    dplyr::mutate(eod = sim_hours[which(time == max(time))] + 24 - max(time))

  # Filter out any end of days after specified date range
  sim_results$eod[sim_results$eod > max(sim_results$sim_hours)] <- NA

  plot_out <- ggplot2::ggplot(sim_results, aes(x = sim_hours)) +
    geom_rect(aes(xmin = sleepstart, xmax = sleepend,
                  ymin = -Inf, ymax = Inf, fill = 'Sleep'), alpha = 0.1, na.rm = T) +
    scale_fill_manual('Sleep', name = "", values = 'grey80', guide = guide_legend(override.aes = list(alpha = 1))) +
    geom_vline(aes(xintercept = eod), linetype = 2, na.rm = T) +
    theme_classic() +
    xlab ("Simulation Hours") +
    ylab("")


  long_data <- tidyr::pivot_longer(sim_results, !!plot_stat, names_to = "stat")

  # Change factor order to put fatigue first
  if("fatigue" %in% plot_stat){
    fac_levels <- c("fatigue", unique(long_data$stat)[!unique(long_data$stat) == "fatigue"])
    long_data$stat <- factor(long_data$stat, levels = fac_levels)
  }

  plot_out <- plot_out +
    geom_line(data = long_data, aes(y = value, color = stat), size = 1) +
    labs(colour = "Predicted Value")

  if (fatigue_CIs) {
    # Figure out which fill is appropriate
    correct_fill <- which(levels(long_data$stat) == "fatigue") + 1
    plot_out <- plot_out +
      geom_ribbon(aes(ymin = fatigue_lower, ymax = fatigue_upper), alpha = 0.2, fill = correct_fill)
    }

  if (!is.null(observed)) {
    plot_out <-
      plot_out + geom_point(data = observed, aes(y = !!as.name(observed_y)))
  }

  return(plot_out)

}


#' plot.FIPS_simulation
#'
#' S3 plot method for FIPS_simulation
#'
#' @param x A valid .FIPS_simulation series that has been simulated
#' @param from The starting datetime to be plotted
#' @param to The ending datetime to be plotted
#' @param plot_stat Which variables to plot
#' @param fatigue_CIs A logical indicating whether uncertainty intervals on fatigue should be plotted
#' @param observed A data frame with any observed sleepiness ratings or objective indicators to plot against predictions
#' @param observed_y The name of the observed sleepiness ratings in the observed data frame
#'
#' @export
plot.FIPS_simulation <- function(
  x,
  from = NULL,
  to = NULL,
  plot_stat = NULL,
  fatigue_CIs = FALSE,
  observed = NULL,
  observed_y = NULL) {
  FIPS_plot(
    dats = x,
    from = from,
    to = to,
    plot_stat = plot_stat,
    fatigue_CIs = fatigue_CIs,
    observed = observed,
    observed_y = observed_y
  )
}
