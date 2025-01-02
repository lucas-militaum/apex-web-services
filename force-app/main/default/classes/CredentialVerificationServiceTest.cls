@isTest
public class CredentialVerificationServiceTest {

    @TestSetup
    static void setupTestData() {
        Certification__c certification1 = new Certification__c();
        insert certification1;

        Certification__c certification2 = new Certification__c();
        insert certification2;

        // Criação de uma conta de teste
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Criação de contatos associados à conta
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert contact1;

        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = testAccount.Id);
        insert contact2;
        
        // Criação de certificações associadas aos contatos
        Contact_Certification__c cert1 = new Contact_Certification__c(
            Contact__c = contact1.Id, 
            isActive__c = true,
            Certification__c = certification1.Id,
            Issue_Date__c = Date.today().addDays(10)
        );
        insert cert1;

        Contact_Certification__c cert2 = new Contact_Certification__c(
            Contact__c = contact2.Id, 
            isActive__c = false,
            Certification__c = certification2.Id,
            Issue_Date__c = Date.today().addDays(-10)
        );
        insert cert2;
    }

    @isTest
    static void testVerifyCredential_NoContactFound() {
        // Chama o método verifyCredential com um sobrenome que não existe
        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('NonExistentLastName', 'Salesforce Certified Developer');
        Test.stopTest();

        // Verifica que o resultado é 'No record found'
        System.assertEquals('No record found', result, 'The message should indicate no contact found');
    }

    @isTest
    static void testVerifyCredential_NoCertificationFound() {
        // Chama o método verifyCredential com um sobrenome válido, mas uma certificação que o contato não tem
        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Doe', 'NonExistentCertification');
        Test.stopTest();

        // Verifica que o resultado é 'No record found'
        System.assertEquals('No record found', result, 'The message should indicate no certification found');
    }

    @isTest
    static void testVerifyCredential_CertificationValid() {
        Contact johnContact = [SELECT Id, (SELECT Name FROM Contact_Certifications__r LIMIT 1) FROM Contact WHERE LastName = 'Doe'];
        String certificationName = johnContact.Contact_Certifications__r[0].Name;
        // Chama o método verifyCredential com um sobrenome válido e uma certificação ativa
        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Doe', certificationName);
        Test.stopTest();

        // Verifica que o resultado é 'Valid'
        System.assertEquals('Valid', result, 'The certification should be valid');
    }

    @isTest
    static void testVerifyCredential_CertificationNeedsRenewal() {
        Contact janeContact = [SELECT Id, (SELECT Name FROM Contact_Certifications__r LIMIT 1) FROM Contact WHERE LastName = 'Smith'];
        String certificationName = janeContact.Contact_Certifications__r[0].Name;
        // Chama o método verifyCredential com um sobrenome válido e uma certificação inativa
        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Smith', certificationName);
        Test.stopTest();

        // Verifica que o resultado é 'Needs Renewal'
        System.assertEquals('Needs Renewal', result, 'The certification should need renewal');
    }
}