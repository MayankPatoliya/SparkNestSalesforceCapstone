@RestResource(urlMapping='/SparkNestEnquiryAPI/*')
global with sharing class SparkNestEnquiryAPI {

    global class EnquiryRequest {
        global String firstName;
        global String lastName;
        global String email;
        global String phone;
        global String subject;
        global String enquiryType;
        global String priority;
        global String source;
        global String planDuration;
        global Decimal customerBudget;
    }

    global class EnquiryResponse {
        global Boolean success;
        global String message;
        global Id contactId;
        global Id enquiryId;
    }

    @HttpPost
    global static EnquiryResponse submitEnquiry() {
        RestResponse response = RestContext.response;
        EnquiryResponse result = new EnquiryResponse();

        EnquiryRequest requestData;

        try {
            if (RestContext.request.requestBody == null) {
                response.statusCode = 400;
                result.success = false;
                result.message = 'Request body is required.';
                return result;
            }

            requestData = (EnquiryRequest) JSON.deserialize(
                RestContext.request.requestBody.toString(),
                EnquiryRequest.class
            );
        } catch (Exception ex) {
            response.statusCode = 400;
            result.success = false;
            result.message = 'Invalid JSON request body.';
            return result;
        }

        if (requestData == null ||
            String.isBlank(requestData.email)) {
            response.statusCode = 400;
            result.success = false;
            result.message = 'Email is required to submit an enquiry.';
            return result;
        }

        if (String.isBlank(requestData.lastName) ||
            String.isBlank(requestData.subject)) {
            response.statusCode = 400;
            result.success = false;
            result.message = 'Last name and enquiry subject are required.';
            return result;
        }

        Savepoint sp = Database.setSavepoint();

        try {
            List<Contact> existingContacts = [
                SELECT Id
                FROM Contact
                WHERE Email = :requestData.email
                LIMIT 1
            ];

            Contact customer;
            Boolean contactCreated = false;

            if (!existingContacts.isEmpty()) {
                customer = existingContacts[0];
            } else {
                customer = new Contact(
                    FirstName = requestData.firstName,
                    LastName = requestData.lastName,
                    Email = requestData.email,
                    Phone = requestData.phone
                );

                insert customer;
                contactCreated = true;
            }

            Enquiry__c enquiry = new Enquiry__c(
                Subject__c = requestData.subject,
                Contact__c = customer.Id
            );

            if (!String.isBlank(requestData.enquiryType)) {
                enquiry.Enquiry_Type__c = requestData.enquiryType;
            }

            if (!String.isBlank(requestData.priority)) {
                enquiry.Priority__c = requestData.priority;
            }

            if (!String.isBlank(requestData.source)) {
                enquiry.Source__c = requestData.source;
            }

            if (!String.isBlank(requestData.planDuration)) {
                enquiry.Plan_Duration__c = requestData.planDuration;
            }

            if (requestData.customerBudget != null) {
                enquiry.Customer_Budget__c =
                    requestData.customerBudget;
            }

            insert enquiry;

            response.statusCode = 201;
            result.success = true;
            result.message = contactCreated
                ? 'Contact and Enquiry created successfully.'
                : 'Existing Contact found; Enquiry created successfully.';
            result.contactId = customer.Id;
            result.enquiryId = enquiry.Id;

            return result;

        } catch (Exception ex) {
            Database.rollback(sp);
            response.statusCode = 500;
            result.success = false;
            result.message = 'Unable to submit enquiry: ' +
                ex.getMessage();
            return result;
        }
    }
}