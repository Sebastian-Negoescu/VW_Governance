So, basically, we will create all the Azure Policy / Initiative definitions in this folder, with dependencies and everything.
We will make use of the Azure Blueprints in order to ASSIGN the policies when deploying resources in the Azure Cloud.

Example:

---- Create policies for Allowed Locations (RGs && Resources) --> Assign these 2 to an Initiative;
---- Create a Blueprint folder and inside the Artifact folder, define the resources you want to create && also define the assignments for the initiative; the parameters created in the Azure Policies and Initiatives, will then be used in the Assignments, but their VALUEs will be definied when using Assignment.json (the file that allows us to make sense for multiple projects/environments while having the Blueprints.json file as a skeleton)

LET'S DO IT!