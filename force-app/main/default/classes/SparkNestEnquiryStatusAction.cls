
public with sharing class SparkNestEnquiryStatusAction {
    
    public class Request {
        @InvocableVariable(
            required=true
            label='Customer Email'
            description='Email address of the customer checking an enquiry.'
        )
        public String email;

        public Request() {}
    }

    public class Response {
        @InvocableVariable(label='Contact Found')
        public Boolean contactFound;

        @InvocableVariable(label='Enquiry Found')
        public Boolean enquiryFound;

        @InvocableVariable(label='Enquiry Subject')
        public String enquirySubject;

        @InvocableVariable(label='Enquiry Status')
        public String enquiryStatus;

        @InvocableVariable(label='Closed Date')
        public Date closedDate;

        @InvocableVariable(label='Message')
        public String message;

        public Response() {}
    }

    @InvocableMethod(
        label='Get Latest Enquiry By Email'
        description='Finds a customer by email and returns their latest enquiry status and closed date.'
    )
    public static List<Response> getLatestEnquiry(
        List<Request> requests
    ) {
        List<Response> results = new List<Response>();
        Set<String> emails = new Set<String>();

        for (Request req : requests) {
            if (req.email != null && !String.isBlank(req.email)) {
                emails.add(req.email.trim().toLowerCase());
            }
        }

        Map<String, Id> contactIdsByEmail = new Map<String, Id>();

        if (!emails.isEmpty()) {
            List<Contact> contactsFound = (List<Contact>)
                Database.queryWithBinds(
                    'SELECT Id, Email FROM Contact ' +
                    'WHERE Email IN :emails ORDER BY CreatedDate DESC',
                    new Map<String, Object>{ 'emails' => emails },
                    AccessLevel.SYSTEM_MODE
                );

            for (Contact c : contactsFound) {
                String emailKey = c.Email.toLowerCase();

                if (!contactIdsByEmail.containsKey(emailKey)) {
                    contactIdsByEmail.put(emailKey, c.Id);
                }
            }
        }

        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(contactIdsByEmail.values());

        Map<Id, Enquiry__c> latestByContact =
            new Map<Id, Enquiry__c>();

        if (!contactIds.isEmpty()) {
            List<Enquiry__c> enquiriesFound = (List<Enquiry__c>)
                Database.queryWithBinds(
                    'SELECT Id, Contact__c, Subject__c, Status__c, ' +
                    'Closed_Date__c, CreatedDate ' +
                    'FROM Enquiry__c ' +
                    'WHERE Contact__c IN :contactIds ' +
                    'ORDER BY CreatedDate DESC',
                    new Map<String, Object>{
                        'contactIds' => contactIds
                    },
                    AccessLevel.SYSTEM_MODE
                );

            for (Enquiry__c e : enquiriesFound) {
                if (!latestByContact.containsKey(e.Contact__c)) {
                    latestByContact.put(e.Contact__c, e);
                }
            }
        }

        for (Request req : requests) {
            Response res = new Response();
            res.contactFound = false;
            res.enquiryFound = false;

            String emailKey = req.email == null
                ? ''
                : req.email.trim().toLowerCase();

            if (String.isBlank(emailKey)) {
                res.message = 'Please provide your email address.';
            } else if (!contactIdsByEmail.containsKey(emailKey)) {
                res.message =
                    'No Contact was found. Please check your email address or submit a new enquiry.';
            } else {
                res.contactFound = true;

                Id contactId = contactIdsByEmail.get(emailKey);
                Enquiry__c enquiry = latestByContact.get(contactId);

                if (enquiry == null) {
                    res.message =
                        'Your Contact was found, but no Enquiry was found.';
                } else {
                    res.enquiryFound = true;
                    res.enquirySubject = enquiry.Subject__c;
                    res.enquiryStatus = enquiry.Status__c;
                    res.closedDate = enquiry.Closed_Date__c;
                    res.message = 'Latest Enquiry found.';
                }
            }

            results.add(res);
        }

        return results;
    }
}
