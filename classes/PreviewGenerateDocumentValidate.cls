global class PreviewGenerateDocumentValidate{

    webservice static String validateGenerateDocument(Id quoteId){
        
        List<Products_Operational_Services__c> prodWithOpServicesList = Products_Operational_Services__c.getAll().values();
        List<String> productsList = new List<String>();
        if(!prodWithOpServicesList.isEmpty()){
            for(Products_Operational_Services__c prod :prodWithOpServicesList){
                productsList.add(prod.Product_Code__c);
            }
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        quoteLineList = [SELECT Id, SBQQ__Product__r.ProductCode, Product_SubFamily2__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId AND SBQQ__Product__r.ProductCode IN: productsList];                        
        // Create dynamic soql on quote for fields present in custom setting
        string soqlStr ='SELECT ' ;
        integer i=0;
        integer j=0;
        for(Quote_Document_Validation_Fields__c quoteField :Quote_Document_Validation_Fields__c.getAll().values()){
            soqlStr = soqlStr + ' '+ quoteField.Field_API_Name__c + ', ';
             if(quoteField.Operational_Services_Field__c == false){
                   i = i+1;
               }else{
                j =j+1;
               }
            
        }//End of FOR loop                      
        soqlStr = soqlStr + ' id FROM SBQQ__Quote__c WHERE Id  =  ' + '\'' + quoteId + '\'' +' limit 1';
        System.debug('soqlStr==============='+soqlStr);
            
        SBQQ__Quote__c thisQuote = Database.query(soqlStr);
        
        // If quote line list is not empty - quote with operational products
        if(!quoteLineList.isEmpty()){ 
           integer billing=0;
           integer prefix=0;   
            
            for(Quote_Document_Validation_Fields__c quoteField :Quote_Document_Validation_Fields__c.getAll().values()){
                string fieldVal=(String)String.valueOf(thisQuote.get(quoteField.Field_API_Name__c));
                if(fieldVal!=null && quoteField.Operational_Services_Field__c == false){
                    billing = billing + 1;
                }
                else if(fieldVal !=null && quoteField.Operational_Services_Field__c == true){
                    prefix = prefix + 1;
                }
            }
            
            System.debug('j===========>' + j + ' prefix=========>' + prefix);
            
            // If any of Contact, Bill to Address and Ship to Address field is missing, show msg
            if(i!=billing && j != prefix){
                return '2';
            }
            // If any of Acct Prefix Requested, Reason for Replacement/ Change Request, and Date old Instance can be Cancelled field is missing, show msg
            else if(i!=billing){
                return '1';
            }
            else if(j != prefix){
                return '0'; 
            }       
        }
        // If quote line list is empty - quote without operational products
        else{
            for(Quote_Document_Validation_Fields__c quoteField :Quote_Document_Validation_Fields__c.getAll().values()){
                string fieldVal=(String)String.valueOf(thisQuote.get(quoteField.Field_API_Name__c));
                if(fieldVal == null && quoteField.Operational_Services_Field__c == false){
                    return '1';
                }               
            }//End of FOR loop           
        }
        // If all fields are present, redirect to preview or generate document page
        return 'success';
    }
}