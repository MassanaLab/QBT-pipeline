#!/bin/bash

#SBATCH --job-name=QBT_1
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --mem=8GB
#SBATCH --output=data/logs/QBT_pipeline_1_%A_%a.out
#SBATCH --error=data/logs/QBT_pipeline_1_%A_%a.err

############################################
# Load required modules
module load cesga/2020 seqkit/2.1.0
#module load cesga/2020
#module load gcc/system busco/5.3.2

# =============================
# PARAMETERS
# =============================

MAIN_NAME="$1"
SOURCE="$2"
N="$3"

FILTER_SUFFIX="filter${N}"
FULL_NAME="${MAIN_NAME}_${FILTER_SUFFIX}"

# Dynamically generate sample list from filenames in ${SOURCE}
TMP_SAMPLE_FILE="data/clean/${FULL_NAME}_samples.tmp"

# Get the sample for the current SLURM array task
SAMPLE=$(cat ${TMP_SAMPLE_FILE} | awk "NR == ${SLURM_ARRAY_TASK_ID}")

echo "Running sample: ${SAMPLE}"

FILTERED="$4"
QBT="$5"

ESS=${QBT}_ess
REPORTS=${ESS}/all_reports

# Create folders
mkdir -p ${FILTERED} \
         ${QBT}/quast \
         ${QBT}/tiara \
         ${QBT}/busco \
         ${ESS}/quast \
         ${ESS}/busco \
         ${REPORTS}



############################################
# STEP 1: SEQKIT FILTER
seqkit seq -m ${N} ${SOURCE}/${SAMPLE}*.fasta -o ${FILTERED}/${SAMPLE}_filter${N}.fasta

############################################
# STEP 2: QUAST
~/store/quast/metaquast.py \
 --contig-thresholds 0,1000,3000,5000 \
 -o "${QBT}/quast/${SAMPLE}" \
 "${FILTERED}/${SAMPLE}_filter${N}.fasta"

cp ${QBT}/quast/${SAMPLE}/transposed_report.tsv ${ESS}/quast/${SAMPLE}_transposed_report.tsv

############################################
# STEP 3: TIARA

module load cesga/2020

~/.local/bin/tiara \
 -i "${FILTERED}/${SAMPLE}_filter${N}.fasta" \
 -o "${QBT}/tiara/${SAMPLE}"

# copy all tiara logs once
cp -r ${QBT}/tiara ${ESS}

############################################
# STEP 4: BUSCO

module load gcc/system busco/5.3.2

BUSCO_DB=eukaryota_odb10

busco \
 --in "${FILTERED}/${SAMPLE}_filter${N}.fasta" \
 -o "${QBT}/busco/${SAMPLE}" \
 -l ${BUSCO_DB} \
 -m genome \
 --cpu ${SLURM_CPUS_PER_TASK} \
 -f

cp ${QBT}/busco/${SAMPLE}/short_summary.specific.${BUSCO_DB}.${SAMPLE}.txt ${ESS}/busco/


rm -r ${QBT}/quast/${SAMPLE}
rm ${QBT}/tiara
rm -r ${QBT}/busco/${SAMPLE}
