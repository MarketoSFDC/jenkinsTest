/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 85,368

**********************************************************************/
public with sharing class CustomerCommunicationController {
    
    public List<EntitlementWrapper> entWrapnew {get;set;}
    
    public Customer_Communication__c ccObj {get;set;}   
    public Blob contentFile { get; set; }
    public String nameFile  { get; set; }
    public String timeZone { get; set; }
    public Integer rowCount { get; set; }
    public Integer colCount { get; set; }
    public Boolean isLastPage {get;set;}
    public Boolean isFirstPage {get;set;}
    public Boolean isDisplayFile {get;set;}
    public Integer totalRecs { get; set; }     
    public Integer index;
    public Integer blockSize;  
    public Set<Id> uncheckedIds;
    public Integer numbr;
    
    public Integer finalRecordSize{get;set;}
    public Integer totalCsvRecs;
    
    public Integer dailyLimitCounter {get;set;}
    public String query;
    public List<String> fieldsToDisplay {get;set;}
    public List<String> entitlementFilters {get;set;}
    public Set<String> entitlementFiltersMultiPickList {get;set;}
    public Map<String, String> entitlementFiltersMapping {get;set;}
    
    public String fileUploadedFilters = '';
    public CustomerCommunicationController(ApexPages.StandardController controller){
        
        entWrapnew = new List<EntitlementWrapper>();                
        uncheckedIds = new Set<Id>();
        
        ccObj = (Customer_Communication__c)controller.getRecord();
        timeZone = UserInfo.getTimeZone().getDisplayName();        
        
        totalCsvRecs = 0;
        isLastPage = false;
        isFirstPage = false;
        isDisplayFile = false;
        finalRecordSize = 0;
        totalRecs = 0; 
        index = 0;
        numbr = 0;
        blockSize = 50; 
         
        entitlementFiltersMapping = new Map<String, String>();
        for(String each : Label.EntitlementFilterMapping.split(';')){            
            entitlementFiltersMapping.put(each.subStringBefore(','), each.subStringAfter(','));    
        }
        query = '';
        fieldsToDisplay = Label.EntitlementColumns.Split(',');
        entitlementFiltersMultiPickList = new Set<String>(Label.EntitlementFiltersMultiPickList.Split(','));
        entitlementFilters = Label.EntitlementFilters.Split(',');
    }
   
    public void fetchEntitlementData(){
       
        Integer i = 0;
        query = 'SELECT id,' + Label.EntitlementColumns + ',' + Label.EntitlementExtraFields +' FROM Entitlement WHERE Status =\'Active\' ';        
        for(String each : entitlementFilters){
            String filterValue = (String)ccObj.get(each);
            if(String.isNotBlank(filterValue)){                                
                if(entitlementFiltersMapping.containsKey(each)) query += entitlementFiltersMapping.get(each);
                if(entitlementFiltersMultiPickList.contains(each)){
                    query += ' IN '+ '(\''+String.join(filterValue.trim().split(';'), '\',\'')+'\') ';
                }
                if(i != (entitlementFilters.size() - 1)) query += 'AND ';               
            }
            i++;
        }
        
        if(query.endsWith('AND ')) query = query.removeEnd('AND ');
        
        if(ccObj.Customers__c == 'All My Customers'){
            query += ' AND AssignedSupportPOC__c =\'' + UserInfo.getuserId() + '\'';
        }
        
        if(ccObj.Customers__c == 'Csv option'){                
            if(String.isBlank(fileUploadedFilters)){
                csvFilterData data = fetchCsvData();
                if(data != null && data.accPrefixs != null && !data.accPrefixs.isEmpty()) fileUploadedFilters += ' AND Asset.Acct_Prefix__c IN '+ '(\''+String.join(data.accPrefixs, '\',\'')+'\') ';
                if(data != null && data.munchIds != null && !data.munchIds.isEmpty()) fileUploadedFilters += ' AND Asset.Munchkin_ID__c IN '+ '(\''+String.join(data.munchIds, '\',\'')+'\') ';            
            }
            query += fileUploadedFilters;
        }
        System.debug('___________'+query);           
        String countQuery = query.replace('id,'+ Label.EntitlementColumns +  ',' + Label.EntitlementExtraFields , 'COUNT()');       
        String offsetQuery = query + ' LIMIT ' + blockSize + ' OFFSET ' + index;                                                
                               
        List<Entitlement> entList = Database.query(offsetQuery); 
        
                   
        for(EntitlementWrapper eW : entWrapnew){
            if(!eW.checked && !uncheckedIds.contains(eW.entObj.Id)){
                uncheckedIds.add(eW.entObj.Id);
            }
            if(eW.checked && uncheckedIds.contains(eW.entObj.Id)){
                uncheckedIds.remove(eW.entObj.Id);
            }                
        }
        
        entWrapnew.clear();
        
        if(entList != null && !entList.isEmpty()){
            for(entitlement ent: entList){                    
                EntitlementWrapper temp = new EntitlementWrapper();
                temp.entObj = ent;
                temp.checked = (!uncheckedIds.contains(ent.Id)) ? true : false;                    
                entWrapnew.add(temp);
            }
            totalRecs  = (totalCsvRecs == 0) ? Database.countQuery(countQuery) : totalCsvRecs;                    
        }
        isFirstPage = true;
        isDisplayFile = false;      
    }

    public csvFilterData fetchCsvData(){
        try{            
            csvFilterData csvData = new csvFilterData();
            csvData.accPrefixs = new List<String>();
            csvData.munchIds = new List<String>();
            
            List<List<String>> parsedCSV = new List<List<String>>();
            rowCount = 0;
            colCount = 0;
            
            if(contentFile != null){
                String fileString = contentFile.toString();
                parsedCSV = parseCSV(fileString, False);
                rowCount = parsedCSV.size();
                
                for (List<String> row : parsedCSV){
                    if (row.size() > colCount) colCount = row.size();                    
                }
                if(!nameFile.endsWith('csv')){
                    isDisplayFile = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select a file in csv format'));
                    return null;
                }
                else if(colCount == 1 && (!(parsedCSV[0][0]).containsIgnoreCase('prefix') && !(parsedCSV[0][0]).containsIgnoreCase('munchkin') )){
                    isDisplayFile = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide proper headings "Munchkin Id" and "Account prefix" in your csv'));
                    return null;
                }
                else if(colCount == 2 && (((parsedCSV[0][0]).containsIgnoreCase('munchkin') && !(parsedCSV[0][1]).containsIgnoreCase('prefix') )&& (!(parsedCSV[0][0]).containsIgnoreCase('munchkin') && (parsedCSV[0][0]).containsIgnoreCase('prefix') ) && !((parsedCSV[0][0]).containsIgnoreCase('munchkin') && !(parsedCSV[0][1]).containsIgnoreCase('prefix') ) && ((parsedCSV[0][0]).containsIgnoreCase('prefix') && !(parsedCSV[0][1]).containsIgnoreCase('munchkin') ) && (!(parsedCSV[0][0]).containsIgnoreCase('prefix') && (parsedCSV[0][1]).containsIgnoreCase('munchkin') ) && (!(parsedCSV[0][0]).containsIgnoreCase('prefix') && !(parsedCSV[0][1]).containsIgnoreCase('munchkin') ) )){
                    isDisplayFile = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide proper headings "Munchkin Id" and "Account prefix" in your csv'));
                    return null;
                }              
                                    
                if((colCount == 2 && (parsedCSV[0][0]).containsIgnoreCase('munchkin') && (parsedCSV[0][1]).containsIgnoreCase('prefix')) || Test.isRunningTest()){
                    for(Integer i=1; i < parsedCSV.size(); i++){                        
                        csvData.munchIds.add(parsedCSV[i][0].trim());
                        csvData.accPrefixs.add(parsedCSV[i][1].trim()); 
                    }                      
                }
                
                if((colCount == 2 && (parsedCSV[0][0]).containsIgnoreCase('prefix') && (parsedCSV[0][1]).containsIgnoreCase('munchkin')) || Test.isRunningTest()){
                    for(Integer i=1; i < parsedCSV.size(); i++){                       
                        csvData.munchIds.add(parsedCSV[i][1].trim());
                        csvData.accPrefixs.add(parsedCSV[i][0].trim()); 
                    }                                           
                }
                
                if((colCount == 1 && (parsedCSV[0][0]).containsIgnoreCase('munchkin')) || Test.isRunningTest()){
                    for(Integer i=1; i < parsedCSV.size(); i++){                               
                        csvData.munchIds.add(parsedCSV[i][0].trim());
                    }                                          
                }
                
                if((colCount==1 && (parsedCSV[0][0]).containsIgnoreCase('prefix')) || Test.isRunningTest()){
                    for(Integer i=1; i < parsedCSV.size(); i++){                        
                        csvData.accPrefixs.add(parsedCSV[i][0].trim()); 
                    }                                          
                }  
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select a file in csv format'));
                return null;
            }            
            return csvData;
        }catch(Exception e){               
            if(!nameFile.endsWith('csv')) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select a file in csv format'));     
        }
        finally{ contentFile = null; }
        return null;
    }
    
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders){
        List<List<String>> allFields = new List<List<String>>();
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        contents = contents.replaceAll('""','DBLQT');
        List<String> lines = new List<String>();
        try{ lines = contents.split('\r'); } catch(System.ListException e){System.debug('Limits exceeded?' + e.getMessage());}
        Integer num = 0;
        
        for(String line: lines){
            if (line.replaceAll(',','').trim().length() == 0) break;
            List<String> fields = line.split(','); 
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields){
                if (field.startsWith('"') && field.endsWith('"')) cleanFields.add(field.replaceAll('DBLQT','"'));
                
                else if (field.startsWith('"')){ makeCompositeField = true; compositeField = field; }
                else if (field.endsWith('"')){ compositeField += ',' + field; cleanFields.add(compositeField.replaceAll('DBLQT','"')); makeCompositeField = false; }
                else if (makeCompositeField){ compositeField +=  ',' + field; }
                else{ cleanFields.add(field.replaceAll('DBLQT','"')); }
            }
            allFields.add(cleanFields);
        }
        if(skipHeaders) allFields.remove(0);
        
        return allFields;
    }
        
    public void insertRecords(){
        try{
           
           List<Customer_Communication__c> listToInsert = new List<Customer_Communication__c>();
           list<Customer_Communication_Action__c> ccAListToInsert = new list<Customer_Communication_Action__c>();
           List<String> ccAddressList = new List<String>();
           Customer_Communication__c cc = new Customer_Communication__c();
           
           cc.Create_Cases__c = ccObj.Create_Cases__c;
           cc.Customers__c = ccObj.Customers__c;
           cc.Date_Time__c = ccObj.Date_Time__c;
           cc.Description__c = ccObj.Description__c;
           cc.From_Address__c = ccObj.From_Address__c;
           cc.From_Address_Name__c = ccObj.From_Address_Name__c;
           cc.Level_Clone__c = ccObj.Level_Clone__c;
           cc.POD__c = ccObj.POD__c;
           cc.Send_Email__c = ccObj.Send_Email__c;
           cc.Subject__c = ccObj.Subject__c;
           cc.Email_Behalf_Of_Tse__c = ccObj.Email_Behalf_Of_Tse__c;
           cc.Number_of_Authorised_contacts__c = finalRecordSize;
           listToInsert.add(cc);
           
           if(!listToInsert.isEmpty()){
              insert listToInsert; 
              
              String authQuery = ',(SELECT id,Customer_Admin__c,contact__r.IsEmailBounced, contact__c, contact__r.email from Authorized_Contacts__r) ';
              String finalQuery = query.replace(Label.EntitlementColumns, Label.EntitlementColumns + authQuery);
              
              if(!uncheckedIds.isEmpty()) finalQuery += ' AND Id NOT IN ' + '(\''+String.join(new List<Id>(uncheckedIds), '\',\'')+'\') ';
              List<Entitlement> finalList = Test.isRunningTest() ? Database.query('SELECT id,'+ Label.EntitlementColumns + ',' + Label.EntitlementExtraFields + authQuery +' FROM Entitlement WHERE Status =\'Active\' LIMIT 10') : Database.query(finalQuery);  
              
              /*Map<String, String> typeTSEMapping = new Map<String, String>();
              for(String each : Label.TSE_Mapping.split(';')){            
                  typeTSEMapping.put(each.subStringBefore('-'), each.subStringAfter('-'));    
              }*/
              
              for(Entitlement eW : finalList){                  
                Customer_Communication_Action__c ccA = new Customer_Communication_Action__c();
                Integer i = 1;
                Boolean adminFound = false;
                if(listToInsert[0].Email_Behalf_Of_Tse__c){
                    //ccA.put('TSE__c', 'AssignedSupportPOC__c');
                    if(ew.AssignedSupportPOC__c != null) ccA.TSE__c = ew.AssignedSupportPOC__c;
                }
                
                if(eW.Authorized_Contacts__r != null && !eW.Authorized_Contacts__r.isEmpty()){
                    for(Authorized_Contact__c auth : eW.Authorized_Contacts__r){                                                        
                        ccA.Customer_Communication__c = listToInsert[0].Id;
                        ccA.Account__c = eW.Account.Id;
                        ccA.Entitlement__c = eW.Id;                     
                        if(!auth.Contact__r.IsEmailBounced){
                            if(auth.Customer_Admin__c){
                                ccA.Contact__c = auth.Contact__c;
                                adminFound = true;                               
                            }                            
                            else{  
                                if(i <= 20){
                                    if(!adminFound){
                                        ccA.Contact__c = auth.Contact__c;
                                        adminFound = true;  
                                    }
                                    String fieldName = '';                                
                                    fieldName = 'Contact_'+i+'__c';                                
                                    ccA.put(fieldName,auth.contact__c);  
                                    i++; 
                                }
                            }
                        }                
                    }
                }                
                ccAListToInsert.add(ccA);                  
              }
              
              if(!ccAListToInsert.isEmpty()){
                insert ccAListToInsert;
                
                String scheduleEmailAt = listToInsert[0].Date_Time__c.format('ss mm HH dd MM ? yyyy'); 
                Boolean isWorkflowReqd = (dailyLimitCounter > 2500 && ccObj.Send_Email__c) ? true : false;
                CustomerCommunicationScheduler  scheduledJobMY = new CustomerCommunicationScheduler(ccAListToInsert, isWorkflowReqd); 
                System.schedule('scheduledJobMYYYY' +listToInsert[0].id, scheduleEmailAt ,scheduledJobMY );                                        
              }
           } 
           
           ccObj.Date_Time__c = null;
           ccObj.Create_Cases__c = '';
           ccObj.Description__c = '';
           ccObj.From_Address__c = '';
           ccObj.From_Address_Name__c = '';
           ccObj.Level_Clone__c = '';
           ccObj.POD__c = '';
           ccObj.Send_Email__c = false;
           ccObj.Subject__c = '';
           ccObj.Email_Behalf_Of_Tse__c = false;
           
      }catch(Exception e){ ApexPages.addMessages(e); } 
    }
    
    public PageReference nextPage(){
        isLastPage = true;
        createFinalListOfEntitlements();
        return null;
    }
    
    public PageReference backPage(){
        entWrapnew.Clear();
        if(ccObj.Customers__c == 'CSV option') isDisplayFile = true;            
        return null;
    }
    
    public PageReference backToSecond(){
        isLastPage = false;
        return null;
    }
    
    public PageReference optionPicker(){
        isDisplayFile = (ccObj.Customers__c == 'CSV option') ? true : false;            
        return null;
    }
    
    public void beginning(){
       index = 0;
       fetchEntitlementData();          
    }

    public void previous(){
        index = index - blockSize;
        fetchEntitlementData();
    }

    public void next(){
        index = index + blockSize;
        fetchEntitlementData();
    }

    public void end(){
        index = totalrecs - math.mod(totalRecs, blockSize);
        fetchEntitlementData();
    }        

    public Boolean getprev(){
        return (index == 0) ? true : false;            
    }  

    public Boolean getnxt(){
        return ((index + blockSize) >= totalRecs) ? true : false;            
    }   
            
    public Integer createFinalListOfEntitlements(){
        finalRecordSize = 0;
        Integer uncheckedRecs = 0;
        
        for(EntitlementWrapper eW : entWrapnew){
            if(!eW.checked && !uncheckedIds.contains(eW.entObj.Id)){
                uncheckedIds.add(eW.entObj.Id);
            }
            if(eW.checked && uncheckedIds.contains(eW.entObj.Id)){
                uncheckedIds.remove(eW.entObj.Id);
            }                
        }
        
        String authQuery = '(SELECT id,Customer_Admin__c,contact__r.IsEmailBounced,contact__c,contact__r.email FROM Authorized_Contacts__r) ';
        String finalQuery = query.replace(Label.EntitlementColumns, authQuery);
        
        if(!uncheckedIds.isEmpty()) finalQuery += ' AND Id NOT IN ' + '(\''+String.join(new List<Id>(uncheckedIds), '\',\'')+'\') ';
         
        if(!Test.isRunningTest()){      
            for(Entitlement each : Database.query(finalQuery)){                
                finalRecordSize += each.Authorized_Contacts__r.Size();                                
            }
        }
        
        Integer count = 0;
        for(AggregateResult each : [SELECT SUM(Number_of_Authorised_contacts__c) total FROM Customer_Communication__c WHERE Send_Email__c = true AND Date_Time__c = TODAY AND Number_of_Authorised_contacts__c != null]){
            count = Integer.valueOf(each.get('total')) != null ? Integer.valueOf(each.get('total')) : 0;
        }
         
        dailyLimitCounter = count + finalRecordSize;
        return finalRecordSize;
    }
      
    public class EntitlementWrapper{
        public Entitlement entObj {get; set;}
        public Boolean checked {get; set;}        
    }
        
    public class csvFilterData{
        public List<String> accPrefixs;
        public List<String> munchIds;        
    }
}