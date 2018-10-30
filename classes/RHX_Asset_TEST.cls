@isTest(SeeAllData=true)
public class RHX_Asset_TEST {
	
    static testMethod void triggerTest() {
        
        List<Asset> sourceList = [SELECT Id
			                           		FROM Asset
                    				       		LIMIT 1
                           				];
        if(sourceList.size() == 0) {
            sourceList.add(
                	new Asset()
                );
        }
        upsert sourceList;
        
    }

}