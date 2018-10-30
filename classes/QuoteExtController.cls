public with sharing class QuoteExtController {
    private Id quoteId;
    private SObjectField fieldName;
    public SBAA__Approval__c[] approvals {get; set;}
    private sobject thisRecord;
    public string thisRecordName {get; set;}
    private string ObjectName {get;set;} 
    public string objectLabel {get;set;}
    id idToProcess = ApexPages.currentPage().getParameters().get('id');
    sObjectType objectType = idToProcess.getSobjectType();
        
    public QuoteExtController() {
        fieldName = getReferenceFieldName();
        objectName = idToProcess.getSObjectType().getDescribe().getName();
        objectLabel = idToProcess.getSobjectType().getDescribe().getLabel();    
        thisRecord = objectType.newSObject();
        thisRecord = database.query('SELECT Name from ' + objectName + ' where id =\'' + idtoProcess + '\' LIMIT 1');
        thisRecordName = (String) thisRecord.get('Name');    
    }

    public PageReference onSubmit() {
        if (fieldName != null && idToProcess != NULL) {
            SBAA.ApprovalAPI.submit(idToProcess, fieldName);
        }
        return new PageReference('/' + idToProcess);
    }
    
        public PageReference Cancel() {
        return new PageReference('/' + idToProcess);
    }

    public PageReference onRecall() {
        if (fieldName != null && idToProcess != NULL ) {
            SBAA.ApprovalAPI.recall(idToProcess, fieldName);
        }
        return new PageReference('/' + idToProcess);
    }

    public PageReference onPreview() {
        
            approvals = SBAA.ApprovalAPI.preview(idToProcess, fieldName);
           
        return null;
    }
    
      private SObjectField getReferenceFieldName()
    {
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('sbaa__Approval__c').getDescribe().fields.getMap();
		for(Schema.SObjectField fld :objectFields.values())
        {
			schema.describeFieldResult dfield = fld.getDescribe();
            string fldType = string.valueOf(dfield.getType());            	
            if (fldType == 'REFERENCE')
    			{
    				for(SObjectType t :dfield.getReferenceTo())
        				{
    						if(t ==  objectType) 
  							{
     							fieldName = fld;
     							break; 
  							}
        				}
				}
        }
        return fieldName;
    }
}