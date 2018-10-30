public class BatchManualSync implements Database.Batchable<sObject>{
    public final String query;

    public BatchManualSync(String q) {
        query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        String objectTypeName = String.valueOf(scope[0].getSObjectType()).toLowerCase();
        Map<Id, SObject> scopeMap = new Map<Id, SObject>(scope);
        Map<String, Set<Id>> objectIdsByObjectType = new Map<String, Set<Id>>{ objectTypeName => scopeMap.keySet() };
        APXT_Redlining.PlatformDataService.tickleData(objectIdsByObjectType);
    }

    public void finish(Database.BatchableContext BC) {
    }
}