
[![Build Status](https://travis-ci.org/StevenMMortimer/salesforcer.svg?branch=master)](https://travis-ci.org/StevenMMortimer/salesforcer) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/salesforcer?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/salesforcer) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/salesforcer)](http://cran.r-project.org/package=salesforcer) [![Coverage Status](https://codecov.io/gh/StevenMMortimer/salesforcer/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/salesforcer?branch=master)

<br> <img src="man/figures/logo.png" align="right" />

**salesforcer** is an R package that connects to Salesforce APIs using tidy principles. The package implements most actions from the following APIs:

-   REST
-   Bulk (2.0 for insert, delete, update, and upsert; 1.0 for query and hardDelete)
-   SOAP

Future APIs to support:

-   Async
-   Metadata
-   Reporting
-   Analytics

Package features include:

-   OAuth 2.0 and Basic authentication methods (`sf_auth()`)
-   CRUD operations (Create, Retrieve, Update, Delete) methods for REST and Bulk APIs
-   Query operations via REST and Bulk APIs (`sf_query()`)
-   Backwards compatible functions from the `RForcecom` package (`rforcecom.login()`, `rforcecom.query()`)
-   Basic utility calls (`sf_user_info()`, `sf_server_timestamp()`, `sf_list_objects()`)

Installation
------------

``` r
# this package is currently not on CRAN, so it should be installed from GitHub
# install.packages("devtools")
devtools::install_github("StevenMMortimer/salesforcer")
```

If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/StevenMMortimer/salesforcer/issues).

Usage
-----

### Using against the REST API

``` r
library(dplyr)
library(salesforcer)

sf_auth()

# pull down information of person logged in
# it's a simple easy call to get started 
# and confirm a connection to the APIs
user_info <- sf_user_info()

# Create some records

# Now query those records by Id
my_soql <- sprintf("SELECT Id, 
                           Account.Name, 
                           FirstName, 
                           LastName 
                    FROM Contact 
                    WHERE Id in ('%s')", 
                   paste0(created_records$id , collapse="','"))

queried_records <- sf_query(my_soql)

# Update some of those records
queried_records <- queried_records %>%
  mutate(FirstName = "TestTest")

updated_records <- sf_update(queried_records)

# Finally delete those records
deleted_records <- sf_delete(updated_records$id)
```

### Using against the Bulk API

``` r

# For really large inserts, updates, deletes, upserts, queries 
# you can just add "api_type" = "Bulk" to most functions to get 
# the benefits of using the Bulk API instead of the REST API (fewer calls, speedier)
# create bulk
# delete bulk
# query bulk
```

### Accessing Metadata

In future iterations of the package **salesforcer** will connect to the Metadata API; however, currently, there are RESTful calls that will return metatdata.

``` r
#sf_describe_global()
#sf_describe_object()
#sf_describe_layout()
#sf_describe_tabs()
```