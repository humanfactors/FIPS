change_points = FIPS:::change_points

#' parse_sleepwake_workload_sequence
#'
#' @param sleepwakesequence
#' @param worksequence
#' @param epoch
#' @param series.start
#'
#' @return
#' @export
#'
#' @importFrom FIPS parse_sleepwake_sequence
#'
#' @examples
parse_sleepwake_workload_sequence <- function(sleepwakesequence, worksequence, epoch, series.start) {
  
wldf = FIPS::parse_sleepwake_sequence(
    seq = sleepwakesequence,
    epoch = epoch,
    series.start = series.start)
  
  cp = FIPS:::change_points(worksequence)
  wldf = wldf %>% dplyr::bind_cols(
    work_status = worksequence,
    work_change_point = cp)
  class(wldf) <- append("FIPS_workload_df", class(wldf))
  
  return(wldf)
}





