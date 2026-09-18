###### this is the notes section for iam basics ###########


################################################################################

## Users
- These are the different accounts than root accounts with credentials to login.

## Groups
- users can be part of groups & we can give everybody in the group the same permissions 

## Roles
- roles allows temporarily assume permissions without credentials. use case = an application sitting on an ec2 instance may need to assume permission to allow access to s3 &  CloudWatch.

## policies (and attach them)
ACTUAL permissions are defined in a policy, whether you want to allow somebody to read from s3 or write to a dynamodb table & finally to glue it together we attach these policies to one of our created identities, user, groups or the role.



