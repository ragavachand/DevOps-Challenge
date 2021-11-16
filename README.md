======================Simple Overview======================

* In the implemented scenario, I have used Vault along with PostgreSQL database.

* Before starting the scenario, as a pre-requisite assuming the vault server & vault-injector pods have already been deployed using helm chart on top of kubernetes cluster.

* When a deployment is submitted to the kubernetes cluster, vault-injector acts as a mutating web-hook which modifies the deployment there by injecting a vault-agent sidecar.This sidecar handles the authentication to vault and also handles the lifecycle of the secrets.

* For a deployment to get access the secrets in vault, first it needs to get authenticated using the vault's authentication backends. This authentication is done by validating the kubernetes serviceaccount token. If the token is valid then vault returns an internally managed token to application which can be used for future requests. This authentication is a one-time process.

* After authenticating we need to define which secrets that serviceaccount token can access. This can be done by configuring the vault policy. After writing the policy, we need to configure a role which type of combines both the serviceaccount token and the policy. Like which serviceaccount has access to which policy. We can have multiple policies to a particular role.

* For dynamic secrets, whenever an appplication requests for DB credentials(PostgreSQL in this case), Vault creates a new user in DB and returns username & password to application using which the application logs into the DB.

* For Vault to Connect to DB, we need to configure a database connection using a DB connection string and also the DB role so that vault will connect to DB & generate credentials on behalf of the operator. Vault not only generates credentials but also manages the lifecycle of these credentials.

* Along with the above we need to configure a policy for generating the credentials.

* After all the configuration, authentication things are in place, secrets are injected automatically as we are using vault-injector as a sidecar which will take care of the things in the backend. And also vault specific 'annotations' should be in place in the deployment for the vault-injector to inject secrets into the application/pod.





