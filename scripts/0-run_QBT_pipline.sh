#!/bin/bash

MAIN_NAME="test_data" # <- 1 YOU WRITE
SOURCE="test_data" # <- 2 YOU WRITE
N=1000 # <- 3 YOU WRITE

FILTER_SUFFIX="filter${N}"
FULL_NAME="${MAIN_NAME}_${FILTER_SUFFIX}"

SEQKIT_OUT="lustre/${FULL_NAME}" # <- 4 YOU WRITE
QBT_OUT="lustre/qbt_${FULL_NAME}" # <- 5 YOU WRITE


# Dynamically generate sample list from filenames in ${SOURCE}
TMP_SAMPLE_FILE="data/clean/${FULL_NAME}_samples.tmp"

if [ ! -f "$TMP_SAMPLE_FILE" ]; then
  ls ${SOURCE}/*.fasta | \
    xargs -n 1 basename | \
    sed 's/\.fasta$//' | \
    sort > "$TMP_SAMPLE_FILE"
fi

# Count the number of samples
NUM_SAMPLES=$(wc -l < "$TMP_SAMPLE_FILE")

# Submit the array job with dynamic range
JOBID=$(sbatch --array=1-${NUM_SAMPLES}%10 scripts/1-QBT_steps1_4_array.sh "$MAIN_NAME" "$SOURCE" "$N" "$SEQKIT_OUT" "$QBT_OUT" | awk '{print $4}')

# Submit the dependent job
sbatch --dependency=afterok:$JOBID scripts/2-QBT_step5_merge_and_R.sh "$MAIN_NAME" "$N" "$QBT_OUT"
