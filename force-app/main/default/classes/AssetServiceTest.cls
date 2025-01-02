@isTest
public class AssetServiceTest {

    // Dados de teste criados no método @TestSetup
    static Account testAccount;
    static Contact testContact;
    static Asset testAsset;
    static Insurance__c testInsurance;

    @TestSetup
    static void setupTestData() {
        // Criação de uma conta de teste
        testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Criação de um contato de teste associado à conta
        testContact = new Contact(FirstName = 'Test', LastName = 'User', AccountId = testAccount.Id);
        insert testContact;

        // Criação de um ativo (Asset) associado à conta e ao contato
        testAsset = new Asset(
            Name = 'Test Device', // O campo Name deve ser preenchido
            Asset_Identifier__c = '12345',
            Status = 'Active',
            AccountId = testAccount.Id,
            ContactId = testContact.Id // Supondo que ContactId seja um campo personalizado em Asset
        );
        insert testAsset;

        // Criação de um seguro para o ativo
        testInsurance = new Insurance__c(
            Asset__c = testAsset.Id,
            Coverage__c = 'Comprehensive',
            Active__c = true
        );
        insert testInsurance;
    }

    @isTest
    static void testReportLostDevice_DeviceFoundAndClaimCreated() {
        testAsset = [SELECT Id FROM Asset LIMIT 1];
        // Step 1: Chama o método reportLostDevice com um identificador de ativo válido
        Test.startTest();
        String result = AssetService.reportLostDevice('12345');
        Test.stopTest();
        // Step 2: Verifica se a reclamação (Claim) foi criada
        Claim__c claim = [SELECT Id, Name FROM Claim__c WHERE Asset__c = :testAsset.Id AND Type__c = 'Loss'];
        System.assertNotEquals(null, claim, 'Claim should be created');
        System.assertEquals(claim.Name, result, 'Returned claim name should match the created claim');
    }

    @isTest
    static void testReportLostDevice_NoDeviceFound() {
        // Step 1: Chama o método reportLostDevice com um identificador de ativo que não existe
        Test.startTest();
        String result = AssetService.reportLostDevice('NonExistentAsset');
        Test.stopTest();

        // Step 2: Verifica a mensagem retornada
        System.assertEquals('No device found.', result, 'The message should indicate no device was found');
    }

    @isTest
    static void testReportLostDevice_DeviceFoundNoCoverage() {
        testAccount = [SELECT Id FROM Account LIMIT 1];
        testContact = [SELECT Id FROM Contact LIMIT 1];
        // Step 1: Cria um novo ativo sem cobertura (Insurance)
        Asset assetWithoutCoverage = new Asset(
            Name = 'Test Device No Coverage',
            Asset_Identifier__c = '67890',
            Status = 'Active',
            AccountId = testAccount.Id,
            ContactId = testContact.Id // Associando ao contato
        );
        insert assetWithoutCoverage;

        // Step 2: Chama o método reportLostDevice com o identificador de ativo
        Test.startTest();
        String result = AssetService.reportLostDevice('67890');
        Test.stopTest();

        // Step 3: Verifica a mensagem retornada
        System.assertEquals('No coverage. Asset status adjusted to Lost.', result, 'The message should indicate no coverage');
        
        // Step 4: Verifica se o status do ativo foi alterado para 'Lost'
        Asset updatedAsset = [SELECT Status FROM Asset WHERE Id = :assetWithoutCoverage.Id];
        System.assertEquals('Lost', updatedAsset.Status, 'The asset status should be updated to Lost');
    }

    @isTest
    static void testReportLostDevice_DeviceFoundAndClaimAlreadyFiled() {
        testAccount = [SELECT Id FROM Account LIMIT 1];
        testContact = [SELECT Id FROM Contact LIMIT 1];

        // Step 1: Cria um ativo com uma reclamação já existente
        Asset assetWithClaim = new Asset(
            Name = 'Test Device With Claim',
            Asset_Identifier__c = '54321',
            Status = 'Active',
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert assetWithClaim;

        // Criação de uma reclamação existente para o ativo
        Claim__c existingClaim = new Claim__c(
            Type__c = 'Loss',
            Asset__c = assetWithClaim.Id
        );
        insert existingClaim;

        // Step 2: Cria um seguro para o ativo
        Insurance__c insurance = new Insurance__c(
            Asset__c = assetWithClaim.Id,
            Coverage__c = 'Comprehensive',
            Active__c = true
        );
        insert insurance;

        // Step 3: Chama o método reportLostDevice
        Test.startTest();
        String result = AssetService.reportLostDevice('54321');
        Test.stopTest();

        String existingClaimName = [SELECT Name FROM Claim__c LIMIT 1].Name;

        // Step 4: Verifica o resultado que deve indicar que a reclamação já foi registrada
        System.assertEquals(existingClaimName + ' already filed.', result, 'The message should indicate the claim is already filed');
    }
}