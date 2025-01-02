global without sharing class CredentialVerificationService {
    
    webservice static String verifyCredential(String lastName, String certificationName) {
        List<Contact> queryContactResult = [SELECT Id, (SELECT Id, isActive__c FROM Contact_Certifications__r WHERE Name =: certificationName) FROM Contact WHERE LastName =: lastName];

        if (queryContactResult.size() == 0) {
            return 'No record found';
        }

        if (queryContactResult[0].Contact_Certifications__r.size() == 0) {
            return 'No record found';
        }

        if (queryContactResult[0].Contact_Certifications__r[0].isActive__c) {
            return 'Valid';
        } else {
            return 'Needs Renewal';
        }
    }
}