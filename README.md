# QBT-pipeline

## Step 1
Inside [0-run_QBT_pipline.sh](scripts/0-run_QBT_pipline.sh), indicate the origin of your assembled fasta files and decide the name of your job.

## Step 2
Execute the main script like this:

```
bash scripts/0-run_QBT_pipline.sh
```
Two jobs will be sent to the queue. The first one being the 3 programs (Quast, BUSCO, Tiara), which will be sent as an array to be more efficient. The second job, which is the creation of the main final report, will wait for the first job to finish becasue it needs the QBT data from all the samples.

Once this second job finishes, you will find 
