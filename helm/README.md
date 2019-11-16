Before deploying helmchart on a new cluster, Need to make sure of the following things :

AKS Cluster context is set to correct cluster. (az aks get-credentials -g RGNAME-n AKSNAME)

AKS ACR Pull is set correctly. (az aks update -n myAKSCluster -g myResourceGroup --attach-acr <acrName>) (User needs to be owner on the subscription)

AKS Is deployed in the same VNET as accumulo vmss.

Helmchart pulls the Appinsights Instrumentation_Key from mc-infra keyvault. Add the relevant key there.

Set the Hadoop Home and KeyName in the Makefile to correct values before using it.

Before building docker image make sure the conf/accumulo-client.properties file exists and has correct values set in it. If you plan to use helmchart for deployment, then no need to set the values in the accumulo-client.properties file, set them in deployed-values.yaml