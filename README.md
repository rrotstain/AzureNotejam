# Notejam Application Deployed to Azure PaaS

## Purpose

This project uses builds upon [Notejam](https://github.com/komarserjio/notejam) to deploy it to Azure using PaaS assets.

## Notes

* Update **all.yml** to supply the Azure **subscription_id**, **tenant_id**, and service principal **app_id** and **app_secret**
* The HSQLDB local file database has been updated to use a PaaS SQL Server instance within Azure. Update the property **admin_password** in **all.yml** with the password you'd like to set for this SQL Server instance.  Note that the unit test portion of the code is left untouched and defaults to local memory database.
* Update the **firewall_allow_start_ip** and **firewall_allow_end_ip** variables in **all.yml** as required.  This will dictate who can access the database.  I used the starting and ending IP addresses of the subnet, which is also where the application is deployed.  To allow internet-wide access, use a starting and ending IP address of **0.0.0.0**.
* The application deployment is handled by the Maven **azure-webapp** plugin. In order for this plugin to authenticate to Azure, the file **~/.m2/settings.xml** has to be created in the home directory of whoever runs the **mvn azure-webapp:deploy** command. In that regard, update the **vsts_agent_home_dir** variable as required.
* This project was developed with Azure DevOps. As such, the pipeline file **[pipeline/pipeline.yml](pipeline/pipeline.yml)** was created to facilitate CI/CD.

** Usage

* To test, run **mvn test**
* To deploy, first run **mvn package** then **mvn azure-webapp:deploy**

## Contributing

This project welcomes contributions and suggestions.
