
# simulation_df
library(tidyverse)

attributes(test_simulation_unified)

tileplot_dataprep_FIPS_sim <- function(FIPS_sim, pred_stat = NULL, show_sleep = F, tile_epoch = "default", output_label = "Fatigue", scale_limit_type = "observed") {

  # Extract core features of data
  if (is.null(pred_stat)) {
    pred_stat = attr(FIPS_sim, "pred_stat")
  }

  # Breaks for observed limits
  if (scale_limit_type == "observed") {
    tmpdat = test_simulation_unified[,pred_stat]
    scale_limits = c(floor(min(tmpdat)), ceiling(max(tmpdat)))
  }

  if (show_sleep == F) {
    FIPS_sim_tp = mutate(FIPS_sim, fatigue_dv = ifelse(wake_status == F, NA, !!rlang::sym(pred_stat)))
  } else {
    FIPS_sim_tp = mutate(FIPS_sim, fatigue_dv = !!rlang::sym(pred_stat))
  }

  # Now setup the dataframe to round based on tile_duration_mins
  # and clean it up generally for use in plot
  FIPS_sim_tp = FIPS_sim_tp %>%
    mutate(floor_time = floor(time))

  p = ggplot(FIPS_sim_tp, aes(day, time, fill = fatigue_dv, group = floor_time)) +
    scale_x_reverse(expand = c(0, 0), breaks = seq(13,1,-1)) +
    geom_tile(color = "black", size = 0.1) +
    scale_y_continuous(expand = c(0, 0), breaks = seq(0,23,1)) +
    labs(y = "Time", x = "Day")

  if (scale_limit_type == "observed") {
    p = p +
      scale_fill_distiller(
        name = output_label,
        limits = scale_limits,
        palette = "Spectral",
        guide = guide_colorbar(
          ticks.colour = "black",
          ticks.linewidth  = 1,
          frame.colour = "black",
          draw.ulim = F,
          draw.llim = F,
          direction = "horizontal",
          barwidth = 20))
}

  p = p + coord_flip() +
    theme(
      strip.background = element_rect(colour = "white"),
      legend.position = "bottom")+
  removeGrid()
 p
}

(tileplot_dataprep_FIPS_sim(test_simulation_unified))

heatmap_dats = test_simulation_unified %>%
  mutate(fatigue = KSS) %>%
  mutate(fatigue = ifelse(wake_status == F, NA, fatigue)) %>%
  mutate(floor_time = floor(time))

, breaks = c(1,2,3,4,5,6,7,8,9),
labels = c(1,2,3,4,5,6,7,8,9),
ticks.linewidth  = 1,
frame.colour = "black",
draw.ulim = F,
draw.llim = F,
direction = "horizontal",
barwidth = 20)) +

#' Remove grid lines from ggplot2
#'
#' Remove grid lines from a ggplot2 plot, to have a cleaner and simpler
#' plot
#'
#' Minor grid lines are always removed.
#'
#' \code{removeGrid} removes the major grid lines from the x and/or y axis
#' (both by default).
#'
#' \code{removeGridX} is a shortcut for \code{removeGrid(x = TRUE, y = FALSE)}
#'
#' \code{removeGridY} is a shortcut for \code{removeGrid(x = FALSE, y = TRUE)}
#'
#' @param x Whether to remove grid lines from the x axis.
#' @param y Whether to remove grid lines from the y axis.
#' @return A ggplot2 layer that can be added to an existing ggplot2 object.
#' @examples
#' df <- data.frame(x = 1:50, y = 1:50)
#' p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + ggplot2::geom_point()
#' p + removeGrid()
#' p + removeGrid(y = FALSE)
#' p + removeGridX()
#' @name removeGrid
NULL

#' @export
#' @rdname removeGrid
removeGrid <- function(x = TRUE, y = TRUE) {
  p <- ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
  if (x) {
    p <- p +
      ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  }
  if (y) {
    p <- p +
      ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
  }

  p
}

#' @export
#' @rdname removeGrid
removeGridX <- function() {
  removeGrid(x = TRUE, y = FALSE)
}

#' @export
#' @rdname removeGrid
removeGridY <- function() {
  removeGrid(x = FALSE, y = TRUE)
}



