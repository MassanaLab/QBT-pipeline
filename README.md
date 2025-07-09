# QBT-pipeline

## Step 1
Inside [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh), please indicate:

1. **Task name**: This will be used to name all generated files and folders.

2. **Source path**: The location of your assembled FASTA files.

3. **SeqKit filter length cutoff**: The minimum contig length. We recommend `1000` as the default.

4. **Filtered output path**: Where the filtered FASTA files will be saved.

5. **QBT output path**: Temporary path where QBT will store its outputs. Note that this is not the final output folder — the pipeline will later clean and move only the essential files to a new folder with `_ess` appended to the name. QBT produces many intermediate ("trash") files, which are discarded in the final step.


## Step 2
Execute the main script like this:

```
bash scripts/0-run_QBT_pipline.sh
```
Two jobs will be sent to the queue. The first one being the 3 programs (Quast, BUSCO, Tiara), which will be sent as an array to be more efficient. The second job, which is the creation of the main final report, will wait for the first job to finish becasue it needs the QBT data from all the samples.

Once this second job finishes, you will find the final output summary table next to all individual reports inside the desired QBT output path you indicated in [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh). Remember it will have an "_ess" at the end of the path, in case you can't find it.
