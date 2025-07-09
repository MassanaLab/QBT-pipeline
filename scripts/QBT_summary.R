rm(list = ls())

library(readr)
library(dplyr)
library(tidyr)
library(readxl)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop("Usage: Rscript QBT_summary.R <DATA_DIR> <MAIN_NAME>")
}

DATA_DIR <- args[1]
MAIN_NAME <- args[2]


quast <- read_tsv(sprintf("%s/quast_report.txt", DATA_DIR))
busco <- read_tsv(sprintf("%s/busco_report.txt", DATA_DIR))
tiara <- read_tsv(sprintf("%s/tiara_report.txt", DATA_DIR), col_names = c('Sample', 'tiara'))

# TIARA preprocessing
tiara <- tiara %>% 
  separate(tiara, sep = ': ', into = c('tax', 'n')) %>% 
  mutate(n = as.numeric(n)) %>% 
  group_by(Sample, tax) %>% 
  summarise(n = sum(n), .groups = 'drop') %>% 
  pivot_wider(names_from = tax, values_from = n, values_fill = 0) %>%
  mutate(across(where(is.numeric), ~round(., 1))) %>%
  select(
        Sample,
        everything(),
        -any_of("organelle")
    ) %>%
    rowwise() %>%
  mutate(
    all_tiara = sum(c_across(where(is.numeric)), na.rm = TRUE),
    `%-euk` = round(100 * ifelse("eukarya" %in% names(.), eukarya / all_tiara, 0), 1),
    `%-prok` = round(100 * sum(c_across(matches("bacteria|prokarya|archaea")), na.rm = TRUE) / all_tiara, 1)
  ) %>%
  ungroup() %>%
  select(
    Sample,
    `%-euk`,
    `%-prok`,
    any_of(c("eukarya", "bacteria", "archaea", "prokarya", "unknown", "mitochondrion", "plastid")),
    everything(),
    -all_tiara,
    all_tiara
  )

# QUAST + BUSCO base table
base <- data.frame(matrix(NA, nrow = nrow(quast), ncol = 14))
colnames(base) <- c("Sample", "Mb (>= 0 )", "Mb (> =1k)", "Mb (>= 3kb)", "Mb (>= 5Kb)", 
                    "contigs (>= 1Kb)", "contigs (>= 3Kb)", "contigs (>= 5Kb)", 
                    "Largest contig", "GC (%)", "N50", "Complete BUSCOs", 
                    "Fragmented BUSCOs", "Completeness (%) (out of 255)")

base$Sample <- quast$Sample
base[2:5] <- round(quast[7:10] / 1e6, 2)
base[6:8] <- quast[4:6]
base$`Largest contig` <- quast$`Largest contig`
base$`GC (%)` <- quast$`GC (%)`
base$N50 <- quast$N50

colnames(busco) <- c("Sample", "X", "Results", "Complete", "Complete and Single", 
                     "Complete and Duplicated", "Fragmented", "Missing", "X2", "X3", "X4")
base$`Complete BUSCOs` <-  busco$Complete
base$`Fragmented BUSCOs` <- busco$Fragmented
base$`Completeness (%) (out of 255)` <- round(100 * 
      (base$`Complete BUSCOs` + base$`Fragmented BUSCOs`) / 255, 2)

# Merge with TIARA
base2 <- left_join(base, tiara, by = "Sample")
base2[is.na(base2)] <- 0

# Save final table
write.table(
  base2,
  file = file.path(DATA_DIR, sprintf("QBT_summary_%s.tsv", MAIN_NAME)),
  sep = "\t",
  row.names = FALSE
)
