# Dependency list for different services using from telemetry demo opensource project as an application layer for our devops project

## Service using -> language 

1) product catalog -> go 

2) recommendation -> python

3) frontend -> node

## why these services

- All 3 services are light compared to other heavy one like kafka, java et cetera!
- All 3 are connected to each other : recommendation recommends the product from product catalog & frontend connects those 2!

## product-catalog

port: 3550

Env variable it needs : 

	**product-catalog**
	PRODUCT_CATALOG_PORT=3550
	**Postgres** for database string connection 
	DB_CONNECTION_STRING=postgres://<user>:<passwd>@<host>:<port>/<database>?sslmode=disable


What it calls or depends on: 

	it is called by recommendation service & frontend service. 
	it depends on postgreSQL

Which of these fail hard & which only warn (e.g: missing telemetry didn't stop them from runnning)

	if db string connection fails then it is a hard failure | failure like OpAMP, collector,OTel etc only warns
	
## recommendation


port: 9001

Env variable :

	** needed var**
	PRODUCT_CATALOG_ADDR=localhost:3550
	OTEL_SERVICE_NAME=recommendation
	RECOMMENDATION_PORT=9001


What it calls or depends on:

        it called by frontend & depends on product catalog 
	it calls product-catalog
   

Which of these fail hard & which only warn (e.g: missing telemetry didn't stop them from runnning)
it refuse to start if Any variable is missing but it keeps running without telemetry and feature flags 

## frontend

- Not yet connected 

port: 8080

Env variable :
	PRODUCT_CATALOG_ADDR=localhost:3550 #cause it calls the prodcut-catalog
	RECOMMENDATION_ADDR=localhost:9001 #cause it calls the recommendation
	FRONTEND_PORT = 8080

What it calls or depends on:

        it calls prodcut-catalog & recommendation service and other bunch of services as well 


Which of these fail hard & which only warn (e.g: missing telemetry didn't stop them from runnning)
