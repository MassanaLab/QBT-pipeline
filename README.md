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
Two jobs will be sent to the queue. The first one runs the three programs (Quast, BUSCO, and Tiara), submitted as an array job for efficiency. The second job — the creation of the main final report — will wait for the first one to finish, since it depends on having the QBT data from all samples.

Once this second job is complete, you'll find the final output summary table alongside all individual reports, inside the QBT output path you specified in [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh). Remember: the final path will have an `_ess` suffix, in case you're having trouble finding it.
