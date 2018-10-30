public class ApprovalsRenderingComponentController{
    public static Id QuoteId{get;set;}
    public List<sbaa__Approval__c> ApprovalLinesList;
    
    public static List<sbaa__Approval__c>getApprovalLinesList(){
        List<sbaa__Approval__c> ApprovalLinesList = new List<sbaa__Approval__c>();
        String sToday = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String query = 'SELECT ';
        
        // Get Approval Field Set fields       
        List<Schema.FieldSetMember> fieldSetMembersList = new List<Schema.FieldSetMember>();    
        fieldSetMembersList = SObjectType.sbaa__Approval__c.FieldSets.Email_Fields.getFields();     
        for(Schema.FieldSetMember f : fieldSetMembersList) {
            query += f.getFieldPath() + ', ';            
        }

        query += ' Id FROM sbaa__Approval__c WHERE (sbaa__Status__c != \'Rejected\' AND sbaa__Status__c != \'Recalled\' ) AND Quote__c =: QuoteId AND Submitted_Date__c >='+sToday;

        System.debug('Final Query=====>' + query);
        ApprovalLinesList = Database.query(query);
            
        return ApprovalLinesList;    
    }
}