Global class MarketoPageSecurityPlugin implements SBQQ.PageSecurityPlugin2 {
    Global Boolean isFieldEditable(String pageName, Schema.SObjectField field) {
        //system.debug(pageName);
        return null;
    }
    
    Global Boolean isFieldEditable(String pageName, Schema.SObjectField field, SObject record) {
        //system.debug(pageName);
        if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) {        
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            if (field == SBQQ__QuoteLine__c.MKTO_Net_Total__c){
                return false;
            }
            if (
            field == SBQQ__QuoteLine__c.Manual_Rollup__c && line.SBQQ__ProductFamily__c != 'Bundle' && line.Quote_Type__c == 'Amendment'
                ) 
            {
                return false;
            }
        }
        return null;
    }
    
    Global Boolean isFieldVisible(String pageName, Schema.SObjectField field) {
        //system.debug(pageName);
        //system.debug(field);
        return null;
    }
     
  Global Boolean isFieldVisible(String pageName, Schema.SObjectField field, SObject record) {
        //system.debug(pageName);
        //system.debug(field);
       
        if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) {        
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            //system.debug(line.Rubiks_Quote__c);  
            if ((field == SBQQ__QuoteLine__c.Manual_Rollup__c) 
                && (((line.SBQQ__ProductFamily__c != 'Support' || line.Product_Type__c == 'Services') && line.SBQQ__ProductFamily__c != 'Product' && line.Quote_Type__c != 'Amendment') || line.Rubiks_Quote__c != true)
                ) 
            {
                return false;
            }
            if ((field == SBQQ__QuoteLine__c.MKTO_Discount__c) && (line.Quote_Type__c != 'Amendment' || (line.Quote_Type__c == 'Amendment' && line.SBQQ__Existing__c && line.Qty_Diff__c < 1) || (!line.SBQQ__Existing__c && line.Quote_Type__c == 'Amendment'))) {
                return false;
            }
                       
        }
        return null;
    }
}