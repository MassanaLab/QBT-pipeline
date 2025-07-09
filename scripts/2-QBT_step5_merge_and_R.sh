#!/bin/bash

#SBATCH --job-name=QBT_2
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --mem=4GB
#SBATCH --output=data/logs/QBT_pipeline_2_%A_%a.out
#SBATCH --error=data/logs/QBT_pipeline_1_%A_%a.err

MAIN_NAME="$1" # <- YOU WRITE
FILTER_SUFFIX="filter1000"
FULL_NAME="${MAIN_NAME}_${FILTER_SUFFIX}"

QBT=lustre/qbt_${FULL_NAME}
ESS=${QBT}_ess
REPORTS=${ESS}/all_reports

############################################
# STEP 5: MERGE REPORTS (Run only once)


### --- BUSCO REPORT --- ###
DATA_DIR=${ESS}/busco
OUT_FILE=${REPORTS}/busco_report.txt
SAMPLE=$(ls ${DATA_DIR} | head -1 | awk -F "." '{print $4}')
HEADERS=$(grep -v '^#' ${DATA_DIR}/short_summary.*.${SAMPLE}.txt | grep -v '%' | sed '/^$/d' | perl -pe 's/.*\d+\s+//' | tr '\n' '\t')
echo -e "Sample\t${HEADERS}" > ${OUT_FILE}

for SAMPLE in $(ls ${DATA_DIR} | awk -F "." '{print $4}')
do
  REPORT=$(cat ${DATA_DIR}/short_summary.specific.eukaryota_odb10.${SAMPLE}.txt | \
  grep -v '^#' | perl -pe 's/^\n//' | awk '{print $1}' | tr '\n' '\t')
  echo -e "${SAMPLE}\t${REPORT}" >> ${OUT_FILE}
done

### --- TIARA REPORT --- ###
DATA_DIR=${ESS}/tiara
OUT_FILE=${REPORTS}/tiara_report.txt

for SAMPLE in $(ls ${DATA_DIR} | grep -v "^log")
do
  cat ${DATA_DIR}/log_${SAMPLE} | \
  grep -e 'archaea' -e 'bacteria' -e 'eukarya' -e 'organelle' -e 'unknown' -e 'prokarya' -e 'mitochondrion' -e 'plastid' | \
  awk -v var=${SAMPLE} '{print var$0}' OFS='\t' \
  >> ${OUT_FILE}
done

### --- QUAST REPORT --- ###
DATA_DIR=${ESS}/quast
OUT_FILE=${REPORTS}/quast_report.txt

# Pick one sample file to get headers from
SAMPLE=$(ls ${DATA_DIR}/*_transposed_report.tsv | head -1 | xargs -n 1 basename | sed 's/_transposed_report.tsv//')
HEADERS=$(head -1 ${DATA_DIR}/${SAMPLE}_transposed_report.tsv)

 echo -e "Sample\t${HEADERS}" > ${OUT_FILE}

 # Now loop over all samples robustly
 for FILE in ${DATA_DIR}/*_transposed_report.tsv; do
   SAMPLE=$(basename "$FILE" | sed 's/_transposed_report.tsv//')
   REPORT=$(tail -1 "$FILE")
   echo -e "${SAMPLE}\t${REPORT}" >> ${OUT_FILE}
 done

module load cesga/system R/4.2.2

# Call R script with dynamic DATA_DIR and MAIN_NAME
Rscript scripts/QBT_summary.R ${REPORTS} ${FULL_NAME}

fi
