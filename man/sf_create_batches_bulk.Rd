% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bulk-operation.R
\name{sf_create_batches_bulk}
\alias{sf_create_batches_bulk}
\title{Add Batches to a Bulk API Job}
\usage{
sf_create_batches_bulk(job_id, input_data, api_type = c("Bulk 1.0",
  "Bulk 2.0"), verbose = FALSE)
}
\arguments{
\item{job_id}{character; the Salesforce Id assigned to a submitted job as 
returned by \link{sf_create_job_bulk}}

\item{input_data}{\code{named vector}, \code{matrix}, \code{data.frame}, or 
\code{tbl_df}; data can be coerced into .csv file for submitting as batch request}

\item{api_type}{character; one of "REST", "SOAP", "Bulk 1.0", "Bulk 2.0", or 
"Chatter" indicating which API to use when making the request}

\item{verbose}{logical; do you want informative messages?}
}
\value{
a \code{tbl_df} containing details of each batch
}
\description{
This function takes a data frame and submits it in batches to a 
an already existing Bulk API Job by chunking into temp files
}
\examples{
\dontrun{
# NOTE THAT YOU MUST FIRST CREATE AN EXTERNAL ID FIELD CALLED My_External_Id 
# BEFORE RUNNING THIS EXAMPLE
# inserting 2 records
my_data <- tibble(Name=c('New Record 1', 'New Record 2'),
                  My_External_Id__c=c('11111','22222'))
job_info <- sf_create_job_bulk(operation='insert',
                               object='Account')
batches_ind <- sf_create_batches_bulk(job_id = job_info$id,
                                      input_data = my_data)
# upserting 3 records
my_data2 <- tibble(My_External_Id__c=c('11111','22222', '99999'), 
                  Name=c('Updated_Name1', 'Updated_Name2', 'Upserted_Record')) 
job_info <- sf_create_job_bulk(operation='upsert',
                               externalIdFieldName='My_External_Id__c',
                               object='Account')
batches_ind <- sf_create_batches_bulk(job_id = job_info$id,
                                      input_data = my_data2)
sf_get_job_bulk(job_info$id)                                     
}
}
\references{
\url{https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/}
}
