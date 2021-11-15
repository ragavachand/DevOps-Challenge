======================Simple Overview======================

In the implemented scenario, I have used Vault along with PostgreSQL database. We need to deploy the vault server and Vault injector as Sidecar.The Sidecar manages the authentication to Vault and the retrieval of secrets. The retrieved secrets are written to pod volume through which the application can read them.As it is always best practice to have dynamic secrets in place, Vault should be configured in such a way that it should be able to create and manage the lifecycle of the secrets.To access the secrets in the vault, need to be authenticated which can be done with the help of Kubernetes serviceaccount token. Besides getting authenticated, proper policies should also be in place which gives the permissions for the authenticated users to access secrets.

After all the configuration part is done, now we can inject secrets into the kubernetes deployments for which we need to match the kubernetes serviceaccount token to the name of the role we create. After which we can configure the deployment to inject the database credentials automatically with an 'annotation'.

