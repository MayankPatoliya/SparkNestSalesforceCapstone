@IsTest
public class TestDataFactory {

    public static Enquiry__c createEnquiry(
        String subject,
        String status,
        Decimal budget
    ) {
        return new Enquiry__c(
            Subject__c = subject,
            Status__c = status,
            Customer_Budget__c = budget
        );
    }

    public static List<Enquiry__c> createEnquiries(Integer count) {
        List<Enquiry__c> enquiries = new List<Enquiry__c>();

        for (Integer i = 0; i < count; i++) {
            enquiries.add(new Enquiry__c(
                Subject__c = 'Test Enquiry ' + i,
                Status__c = 'New',
                Customer_Budget__c = 1000
            ));
        }

        return enquiries;
    }
}