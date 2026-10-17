#' Shared style for supplementary figures S1-S13, matched to Figure 1/2's
#' established conventions (see ../../main/figure2/R and
#' ../../../../extension/figure1/BUILD_NOTES.md): Okabe-Ito palette,
#' sans-serif, 8pt minimum font, 10pt bold panel letters, theme_bw with
#' blank grid.
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

MIN_PT <- 12

theme_supp <- function() {
  theme_bw(base_size = MIN_PT) +
    theme(
      text = element_text(family = "Helvetica", size = 12),
      panel.grid = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text = element_text(size = MIN_PT, colour = "black"),
      axis.title = element_text(size = MIN_PT, colour = "black", face = "bold"),
      legend.text = element_text(size = MIN_PT),
      legend.title = element_text(size = MIN_PT, face = "bold"),
      strip.background = element_blank(),
      strip.text = element_text(size = MIN_PT, face = "bold"),
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      plot.tag = element_text(size = 10, face = "bold"),
      panel.border = element_rect(
        fill = NA,
        colour = "black",
        linewidth = 0.5
      )
    )
}

theme_set(theme_supp())

BLUE <- "#025F9B" 
PURP <- "#837AAE" 
GREEN <- "#5bd3b0"
GREY <- "grey45"

# The 11-region Okabe-Ito palette already established across the AXES81
# pipeline (extension/axes81/photoperiod/scripts/02_photoperiod_amplitude.py
# OKABE_ITO list) -- reused verbatim, same region-to-colour mapping
# throughout every figure here so a region's colour means the same thing
# across S1-S13 (and is visually distinct from Figure 2's own use of
# colour, which is per-region there too, using the same convention).
REGION_COLOURS <- c(
  Australia = "#FAC457", Central_Indian_Ocean = "#A8DA96", Coral_Triangle_SE_Asia = "#5bd3b0",
  Eastern_Atlantic_West_Africa = "#16758b", Eastern_Pacific = "#788dc9", Red_Sea_Persian_Gulf = "#904653",
  South_Central_Pacific_Polynesia = "#93B9E8", Western_Atlantic_Caribbean_Brazil = "#f37c78",
  Western_Central_Pacific = "#3A71A4", Western_Indian_Ocean = "#7b2382ff", ORIGINAL_9 = "#eb5760FF"
)


REGION_LABELS <- c(
  Western_Atlantic_Caribbean_Brazil = "Western Atlantic & Caribbean",
  Red_Sea_Persian_Gulf = "Red Sea & Persian Gulf",
  Coral_Triangle_SE_Asia = "Coral Triangle & SE Asia",
  South_Central_Pacific_Polynesia = "South Central Pacific",
  Eastern_Atlantic_West_Africa = "Eastern Atlantic & West Africa",
  Western_Central_Pacific = "Western & Central Pacific",
  Central_Indian_Ocean = "Central Indian Ocean",
  Western_Indian_Ocean = "Western Indian Ocean",
  Australia = "Australia",
  Eastern_Pacific = "Eastern Pacific",
  ORIGINAL_9 = "Focal subset")

scale_colour_region <- function(...) scale_colour_manual(values = REGION_COLOURS, labels = REGION_LABELS, name = "Region", ...)
scale_fill_region <- function(...) scale_fill_manual(values = REGION_COLOURS, labels = REGION_LABELS, name = "Region", ...)

tag_panel <- function(letter) labs(tag = letter)

ROOT <- normalizePath(file.path(getwd(), "..", "..", "..", ".."))
here_root <- function(...) file.path(ROOT, ...)
