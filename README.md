# QBT-pipeline

## Step 1
Inside [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh), please indicate:

1-The name of your task, it will be used when creating all the needed files and folders.

2-The origin of your assembled fasta files.

3-The lenght cutoff of the SeqKit filter. We put 1000 as the standard.

4-The path where you want the filtered fasta files.

5-The path where you want the output of QBT. This is not the final path becasue it will be later cleaned and moved to the same path but with an additional "_ess" on the name. QBT produce lot of "trash" files so we remove them and produce another set of folders with just the essential outputs that are needed to generate the final main summary report.

## Step 2
Execute the main script like this:

```
bash scripts/0-run_QBT_pipline.sh
```
Two jobs will be sent to the queue. The first one being the 3 programs (Quast, BUSCO, Tiara), which will be sent as an array to be more efficient. The second job, which is the creation of the main final report, will wait for the first job to finish becasue it needs the QBT data from all the samples.

Once this second job finishes, you will find the final output summary table next to all individual reports inside the desired QBT output path you indicated in [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh). Remember it will have an "_ess" at the end of the path, in case you can't find it.
