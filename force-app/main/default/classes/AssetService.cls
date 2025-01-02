@RestResource(urlMapping='/lost')
global without sharing class AssetService {
    
    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {
        List<Asset> queryAssetResult = [SELECT Id, (SELECT Id FROM Insurances__r WHERE Coverage__c = 'Comprehensive' AND Active__c = true), (SELECT Id, Name FROM Claims__r WHERE Type__c = 'Loss') FROM Asset WHERE Asset_Identifier__c =: assetIdentifier];

        if (queryAssetResult.size() == 0) {
            return 'No device found.';
        }

        queryAssetResult[0].Status = 'Lost';
        update queryAssetResult;

        if (queryAssetResult[0].Insurances__r.size() > 0) {
            
            if (queryAssetResult[0].Claims__r.size() > 0) {
                return queryAssetResult[0].Claims__r[0].Name + ' already filed.';
            }


            Claim__c claim = new Claim__c(Type__c = 'Loss', Asset__c = queryAssetResult[0].Id);
            insert claim;

            Claim__c claimCreated = [SELECT Id, Name FROM Claim__c WHERE Id =: claim.Id];
            return claimCreated.Name;
        }

        return 'No coverage. Asset status adjusted to Lost.';
    }
}