@isTest
private class ProductZoningServiceTest {

    @isTest
    static void testGetZoningList_ValidProductCodeAndCountryCode() {
        // Criar um Product2 com um ProductCode válido
        Product2 product = new Product2(ProductCode = 'Product123', Family = 'Fixed-Wing', Name = 'Produto Teste');
        insert product;

        // Simular a requisição HTTP com ProductCode e CountryCode válidos
        RestContext.request = new RestRequest();
        RestContext.request.params.put('ProductCode', 'Product123');
        RestContext.request.headers.put('CountryCode', 'US');
        
        Test.startTest();
        String result = ProductZoningService.getZoningList();
        Test.stopTest();
        
        // Verificar se o resultado corresponde ao valor de Permissible_Fly_Zone__c
        System.assertEquals('Regulated', result, 'The zoning should match the permissible fly zone');
    }

    @isTest
    static void testGetZoningList_ProductCodeNotFound() {
        // Criar um Product2 com um ProductCode válido
        Product2 product = new Product2(ProductCode = 'Product123', Family = 'FamilyA', Name = 'Produto Teste');
        insert product;

        // Simular a requisição HTTP com um ProductCode que não existe
        RestContext.request = new RestRequest();
        RestContext.request.params.put('ProductCode', 'Product999');
        RestContext.request.headers.put('CountryCode', 'US');
        
        Test.startTest();
        String result = ProductZoningService.getZoningList();
        Test.stopTest();
        
        // Verificar se o resultado é o esperado quando o ProductCode não é encontrado
        System.assertEquals('ProductCode is missing or doesn\'t exist', result, 'The product code should not be found');
    }

    @isTest
    static void testGetZoningList_NoMapping() {
        // Criar um Product2 com um ProductCode válido
        Product2 product = new Product2(ProductCode = 'Product123', Family = 'FamilyA', Name = 'Produto Teste');
        insert product;

        // Simular a requisição HTTP com ProductCode válido
        RestContext.request = new RestRequest();
        RestContext.request.params.put('ProductCode', 'Product123');
        
        Test.startTest();
        String result = ProductZoningService.getZoningList();
        Test.stopTest();
        
        // Verificar se o resultado é o esperado quando não há mapeamento correspondente
        System.assertEquals('Confirm with the local authorities', result, 'The zoning should request confirmation with local authorities when no mapping exists');
    }
}
