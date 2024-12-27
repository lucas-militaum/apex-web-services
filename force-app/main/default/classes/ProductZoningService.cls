@RestResource(urlMapping='/ProductZoning/*')
global without sharing class ProductZoningService {

    @HttpGet
    global static String getZoningList() {
        RestRequest request = RestContext.request;

        
        String productCode = request.params.get('ProductCode');
        String countryCode = request.headers.get('CountryCode');

        if (countryCode == null) {
            countryCode = 'US';
        }

        if (String.isBlank(productCode)) {
            return 'ProductCode is missing or doesn\'t exist';
        }
        
        List<Product2> prd = [SELECT Id, Family FROM Product2 WHERE ProductCode =: productCode];
        
        if (prd.size() == 0) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        Map<String, Product_Geo_Mapping__mdt> productGeoMappingMdtMap = Product_Geo_Mapping__mdt.getAll();

        for (Product_Geo_Mapping__mdt currentMdtRecord : productGeoMappingMdtMap.values()) {
            if (currentMdtRecord.Country_Code__c == countryCode && currentMdtRecord.Product_Family__c == prd[0].Family) {
                return currentMdtRecord.Permissible_Fly_Zone__c;
            }
        }

        return 'Confirm with the local authorities';
    }
}