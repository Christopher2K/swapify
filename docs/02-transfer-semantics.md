# Transfer semantics

A transfer is just the job that actually do the music transfer from a platform to another.
There is two step, with an user interaction in between.

1. The first job is the `matching_job`. It will check if for any track in the source, 
we have a corresponding track in the destination. The output is the number of track 
matched and the number of track that the system couldn't find.
2. The second job is the `transfer_job`. After a user confirmation, this job is started and the 
goal is simply to register all matched tracks to the destination.

## Transfer state
- A transfer can be canceled if and only it's waiting for a user confirmation. 
We want to avoid having to design something to cancel the chain of the sequential Oban jobs.
