public class EnquiryProductInterestService {

    public static void updateProductCount(Set<Id> enquiryIds) {

       if (enquiryIds == null || enquiryIds.isEmpty()) {
    return;
}

        Map<Id, Integer> productCounts = new Map<Id, Integer>();

        for (AggregateResult result : [
            SELECT Enquiry__c, COUNT(Id) total
            FROM Enquiry_Product__c
            WHERE Enquiry__c IN :enquiryIds
            GROUP BY Enquiry__c
        ]) {
            productCounts.put(
                (Id) result.get('Enquiry__c'),
                (Integer) result.get('total')
            );
        }

        List<Enquiry__c> enquiriesToUpdate = new List<Enquiry__c>();

        for (Id enquiryId : enquiryIds) {
            Integer total = productCounts.containsKey(enquiryId)
                ? productCounts.get(enquiryId)
                : 0;

            enquiriesToUpdate.add(new Enquiry__c(
                Id = enquiryId,
                Total_Products_Interested__c = total
            ));
        }

        if (!enquiriesToUpdate.isEmpty()) {
            update enquiriesToUpdate;
        }
    }
}