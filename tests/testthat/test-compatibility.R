context("RForcecom Compatibility")

salesforcer_test_settings <- readRDS("salesforcer_test_settings.rds")
salesforcer_token <- readRDS("salesforcer_token.rds")

test_that("testing rforcecom.login compatibility", {

  username <- salesforcer_test_settings$username
  password <- salesforcer_test_settings$password
  security_token <- salesforcer_test_settings$security_token

  # must set the API Version here because new calls to session will not 
  # create a new sessionId and then we are stuck with version 35.0 (the default from RForcecom::rforcecom.login)
  session1 <- RForcecom::rforcecom.login(username, paste0(password, security_token), 
                                         apiVersion=getOption("salesforcer.api_version"))
  suppressWarnings(
    session2 <- salesforcer::rforcecom.login(username, paste0(password, security_token), 
                                             apiVersion=getOption("salesforcer.api_version"))
  )

  expect_equal(session1, session2)
})

username <- salesforcer_test_settings$username
password <- salesforcer_test_settings$password
security_token <- salesforcer_test_settings$security_token
session <- RForcecom::rforcecom.login(username=username, 
                                      password=paste0(password, security_token), 
                                      apiVersion = getOption("salesforcer.api_version"))

sf_auth(token = salesforcer_token)

test_that("testing rforcecom.query compatibility", {
  
  soql <- "SELECT Id, Account.Name, Email FROM Contact WHERE Email != NULL LIMIT 10"
  
  result1 <- RForcecom::rforcecom.query(session, soqlQuery=soql)
  suppressWarnings(result2 <- salesforcer::rforcecom.query(session, soqlQuery=soql))

  expect_equal(sort(names(result1)), sort(names(result2)))
  expect_equal(nrow(result1), nrow(result2))
})

test_that("testing rforcecom.bulkQuery compatibility", {
  
  soql <- "SELECT Id, Email FROM Contact LIMIT 10"
  object <- "Contact"
  
  result1 <- RForcecom::rforcecom.bulkQuery(session, soqlQuery=soql, object=object)
  suppressWarnings(result2 <- salesforcer::rforcecom.bulkQuery(session, soqlQuery=soql, object=object))
  
  expect_equal(sort(names(result1)), sort(names(result2)))
  expect_equal(nrow(result1), nrow(result2))
})

test_that("testing rforcecom.create compatibility", {

  object <- "Contact"
  fields <- c(FirstName="Test", LastName="Contact-Create-Compatibility")
  
  result1 <- RForcecom::rforcecom.create(session, objectName=object, fields)
  suppressWarnings(result2 <- salesforcer::rforcecom.create(session, objectName=object, fields))
  
  expect_equal(names(result1), c("id", "success"))
  expect_is(result1, "data.frame")
  expect_is(result2, "data.frame")
  expect_equal(sort(names(result1)), sort(names(result2)))
  expect_equal(nrow(result1), nrow(result2))
  
  # clean up
  delete_result1 <- sf_delete(ids=c(as.character(result1$id), 
                                    as.character(result2$id)), object_name = object)
})

test_that("testing rforcecom.delete compatibility", {

  object <- "Contact"
  new_contact <- c(FirstName="Test", LastName="Contact-Delete-Compatibility")
  
  result1 <- sf_create(new_contact, "Contact")
  result1 <- RForcecom::rforcecom.delete(session, objectName=object, id=result1$id)
  
  result2 <- sf_create(new_contact, "Contact")
  suppressWarnings(result2 <- salesforcer::rforcecom.delete(session, objectName=object, id=result2$id))
  
  expect_null(result1)
  expect_equal(result1, result2)
})

test_that("testing rforcecom.update compatibility", {
  
  object <- "Contact"
  new_contact <- c(FirstName="Test", LastName="Contact-Update-Compatibility")
  fields <- c(FirstName="Test", LastName="Contact-Update-Compatibility2")
  
  create_result1 <- sf_create(new_contact, "Contact")
  result1 <- RForcecom::rforcecom.update(session, objectName=object, id=create_result1$id, fields)
  
  create_result2 <- sf_create(new_contact, "Contact")
  suppressWarnings(result2 <- salesforcer::rforcecom.update(session, objectName=object, id=create_result2$id, fields))
  
  expect_null(result1)
  expect_equal(result1, result2)
  
  # clean up
  delete_result1 <- sf_delete(ids=c(create_result1$id, create_result2$id), object)
})

test_that("testing rforcecom.upsert compatibility", {
  
  object <- "Contact"
  prefix <- paste0("Compatib-", as.integer(runif(1,1,100000)), "-")
  this_external_id1 <- paste0(prefix, letters[1])
  new_contact <- c(FirstName="Test", 
                   LastName="Contact-Upsert-Compatibility", 
                   My_External_Id__c = this_external_id1)
  create_result1 <- sf_create(input_data = new_contact, object_name = "Contact")
  fields <- c(FirstName="Test", 
              LastName="Contact-Upsert-Compatibility2")
  suppressWarnings(
    result1 <- RForcecom::rforcecom.upsert(session, 
                                           objectName = object, 
                                           externalIdField = "My_External_Id__c", 
                                           externalId = this_external_id1,
                                           fields)
  )
  this_external_id2 <- paste0(prefix, letters[2])
  new_contact <- c(FirstName = "Test", 
                   LastName = "Contact-Upsert-Compatibility", 
                   My_External_Id__c = this_external_id2)
  create_result2 <- sf_create(new_contact, "Contact")
  fields <- c(FirstName="Test", 
              LastName="Contact-Upsert-Compatibility2")
  suppressWarnings(
    result2 <- salesforcer::rforcecom.upsert(session, 
                                             objectName = object, 
                                             externalIdField = "My_External_Id__c", 
                                             externalId = this_external_id2,
                                             fields)
  )
  expect_is(result1, "data.frame")
  expect_is(result2, "data.frame")
  expect_equal(sort(names(result1)), sort(names(result2)))
  expect_equal(nrow(result1), nrow(result2))
  # clean up
  delete_result1 <- sf_delete(ids=c(create_result1$id, create_result2$id), object)
})

test_that("testing rforcecom.getServerTimestamp compatibility", {
  result1 <- RForcecom::rforcecom.getServerTimestamp(session)
  suppressWarnings(result2 <- salesforcer::rforcecom.getServerTimestamp(session))
  expect_equal(round(result1, units = "mins"),
               round(result2, units = "mins"))
})

test_that("testing rforcecom.retrieve compatibility", {
  
  objectName <- "Account"
  fields <- c("name", "Industry", "AnnualRevenue")
  
  result1 <- RForcecom::rforcecom.retrieve(session, objectName, fields, limit = 5)
  suppressWarnings(result2 <- salesforcer::rforcecom.retrieve(session, objectName, fields, limit = 5))
  
  expect_equal(sort(names(result1)), sort(names(result2)))
  expect_equal(nrow(result1), nrow(result2))
})

test_that("testing rforcecom.search compatibility", {
  
  search_string <- "(336)"
  result1 <- RForcecom::rforcecom.search(session, search_string)
  suppressWarnings(result2 <- salesforcer::rforcecom.search(session, search_string))

  expect_null(result1)
  # rforcecom.search has a bug that wont return right data
  expect_is(result2, "data.frame")
})

test_that("testing rforcecom.getObjectDescription compatibility", {
  
  result1 <- RForcecom::rforcecom.getObjectDescription(session, objectName="Account")
  result2 <- salesforcer::rforcecom.getObjectDescription(session, objectName="Account")
  
  expect_is(result1, "data.frame")
  expect_is(result2, "data.frame")
  # same number of fields
  expect_equal(nrow(result1), nrow(result2))
  # same names of the fields
  expect_equal(sort(as.character(result1$name)), sort(result2$name))
})

# not exported?
# test_that("testing rforcecom.bulkAction compatibility", {
#   n <- 2
#   prefix <- paste0("Bulk-", as.integer(runif(1,1,100000)), "-")
#   new_contacts <- tibble(FirstName = rep("Test", n),
#                          LastName = paste0("Contact-Create-", 1:n), 
#                          My_External_Id__c=paste0(prefix, letters[1:n]))
#   
#   result1 <- RForcecom:::rforcecom.bulkAction(session, operation='insert', 
#                                               data=new_contacts, object='Contact')
#   result2 <- salesforcer::rforcecom.bulkAction(session, operation='insert',
#                                                data=new_contacts, object='Contact')
# })