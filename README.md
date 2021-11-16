======================Simple Overview======================

In the implemented scenario, I have used Vault along with PostgreSQL database. We need to deploy the vault server and Vault injector as Sidecar.The Sidecar manages the authentication to Vault and the retrieval of secrets. The retrieved secrets are written to pod volume through which the application can read them.

With dynamic secrets in place, creation and management of the lifecycle of secrets should be handled by the Vault thus automatically rotating the password and revoking the access when no longer needed. Whenever application requests database credentials, Vault creates new user in database and returns username, password to application using which application logs into database.

But to access the secrets in vault, need to be authenticated which can be done with the help of Kubernetes serviceaccount token. Once a pod gets deployed with kubernetes with service account token, vault will validate the token and in return provides an internally managed token which will be used by application for future requests.

After all the configuration & authentication part is done, need to define proper policies which states which admin operations an autheticated user can perform.

With all the configurations, authentication mechanisms, policies and roles in place, secrets can be injectedd dynamically into the kubernetes pod with the help of some vault specific 'Annotations'.

