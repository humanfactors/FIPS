#' Generate a heat-tile plot
#'
#' @param FIPS_sim
#' @param pred_stat
#' @param show_sleep
#' @param tile_epoch
#' @param output_label
#' @param dv_range
#' @param dv_breaks
#'
#' @note Currently plotly is not supported, due to the axis flipping.
#'
#' @return
#' @export
#'
#' @examples
tileplot_dataprep_FIPS_sim <- function(FIPS_sim, pred_stat = NULL, show_sleep = F, output_label = "Fatigue", dv_range = NULL, dv_breaks = NULL, plot_palette = NA) {

  if(is.na(plot_palette)) {plot_palette = "Spectral"}

  # Extract core features of data
  if (is.null(pred_stat)) {
    pred_stat = attr(FIPS_sim, "pred_stat")
  }

  if (show_sleep == F) {
    FIPS_sim_tp = mutate(FIPS_sim, fatigue_dv = ifelse(wake_status == F, NA, !!rlang::sym(pred_stat)))
    } else {FIPS_sim_tp = mutate(FIPS_sim, fatigue_dv = !!rlang::sym(pred_stat))}

  # Breaks for observed limits
  if (is.null(dv_breaks) | is.null(dv_range)) {
    dv_range = c(floor(min(FIPS_sim_tp$fatigue_dv, na.rm = T)), ceiling(max(FIPS_sim_tp$fatigue_dv, na.rm = T)))
    dv_breaks = seq(from = dv_range[1], to = dv_range[2])
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

  p = p +
    scale_fill_distiller(
      name = output_label,
      labels = dv_breaks,
      breaks = dv_breaks,
      limits = dv_range,
      palette = plot_palette,
      guide = guide_colorbar(
        ticks.colour = "black",
        ticks.linewidth  = 1,
        frame.colour = "black",
        draw.ulim = F,
        draw.llim = F,
        direction = "horizontal",
        barwidth = 20))

  p = p + coord_flip() +
    theme(strip.background = element_rect(colour = "white"),
          legend.position = "bottom") +
    removeGrid()

 return(p)
}

# Copyright Dean Attali 2015, MIT licence
# From https://github.com/daattali/ggExtra/blob/master/LICENSE
# Remove grid lines from ggplot2
# Remove grid lines from a ggplot2 plot, to have a cleaner and simpler plot
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

removeGridX <- function() {
  removeGrid(x = TRUE, y = FALSE)
}

removeGridY <- function() {
  removeGrid(x = FALSE, y = TRUE)
}



