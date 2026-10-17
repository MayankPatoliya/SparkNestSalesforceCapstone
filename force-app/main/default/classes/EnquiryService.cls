public class EnquiryService {

    public static void beforeInsert(List<Enquiry__c> enquiries) {
        for (Enquiry__c enquiry : enquiries) {
            if (String.isBlank(enquiry.Status__c)) {
                enquiry.Status__c = 'New';
            }

            if (enquiry.Customer_Budget__c != null &&
                enquiry.Customer_Budget__c < 1000) {
                enquiry.Customer_Budget__c.addError(
                    'Customer budget must be at least ₹1,000'
                );
            }
        }
    }

    public static void afterInsert(List<Enquiry__c> enquiries) {
        List<Task> tasksToInsert = new List<Task>();

        for (Enquiry__c enquiry : enquiries) {
            Task followUp = new Task(
                Subject = 'Follow up: ' + enquiry.Subject__c,
                ActivityDate = Date.today().addDays(3),
                OwnerId = enquiry.OwnerId,
                WhatId = enquiry.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            );

            tasksToInsert.add(followUp);
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    public static void beforeUpdate(
        List<Enquiry__c> enquiries,
        Map<Id, Enquiry__c> oldEnquiries
    ) {
        for (Enquiry__c enquiry : enquiries) {
            Enquiry__c oldEnquiry = oldEnquiries.get(enquiry.Id);

            if (oldEnquiry != null &&
                oldEnquiry.Status__c != 'Closed' &&
                enquiry.Status__c == 'Closed') {
                enquiry.Closed_Date__c = Date.today();
            }
        }
    }
}