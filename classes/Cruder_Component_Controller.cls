public class Cruder_Component_Controller {
    
    public Cruder_Component_Controller()
    {
        
    }
    
    @AuraEnabled
    public static List<Sobject> retriveRecordDetail(String queryFields,String SobjectName,String filterCrieteria)
    {
        String query = 'Select Id,'+queryFields+ ' From '+SobjectName+' Where '+filterCrieteria;
        system.debug('===query===='+query);
        return Database.query(query);
    }
    
    @AuraEnabled
    public static List<Sobject>  fetchRecordByQuery(String query)
    {
        List<Sobject> lstRecords = new List<Sobject>();
        lstRecords = Database.query(query);
        return  lstRecords;
    }

}