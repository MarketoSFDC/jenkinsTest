global class EWSGlobalDashboardController{
    
    global Decimal thresholdScore1 {get;set;}
    global Decimal thresholdScore2 {get;set;}
    global Decimal thresholdScore3 {get;set;}
    global Map<String, String> columnsMap {get;set;}
    global List<String> columns {get;set;}
    String teamFilterValue; 
    global Map<String, List<EWSGlobalDashboardData>> scoreTypeDataMap {get;set;}
    global List<EWSGlobalDashboardData> teamOrgData {get;set;}
  
    global List<EWSGlobalDashboardData> accColorData {get;set;}
    global String colorSet {get;set;}    
    
    global EWSGlobalDashboardController(){  
        scoreTypeDataMap = new Map<String, List<EWSGlobalDashboardData>>();
        colorSet = '';
        teamFilterValue = ApexPages.currentPage().getParameters().get('team');
        if(String.isBlank(teamFilterValue)) teamFilterValue = 'All';
        columnsMap = new Map<String, String>();
        for(String each : Label.EWSGlobalDashboardColumns.split(';')){            
            columnsMap.put(each.subStringBefore(','), each.subStringAfter(','));    
        }  
        
        columns = Label.EWSGlobalDashboardColumnRepeatInfo.split(';');
        
        try{thresholdScore1 = Decimal.valueOf(Label.Threshold_Score_Value_For_EWS);}catch(exception e){thresholdScore1 = 100;}
        try{thresholdScore2 = Decimal.valueOf(Label.Threshold_Score_Value_2_For_EWS);}catch(exception e){thresholdScore2 = 150;}
        try{thresholdScore3 = Decimal.valueOf(Label.Threshold_Score_Value_3_For_EWS);}catch(exception e){thresholdScore3 = 175;}
        List<EWSGlobalDashboardData> scoreTypeData = theScoreTypeData();        
        Map<String, Integer> teamOrgCount = new Map<String, Integer>();
        Map<String, Integer> accColorCount = new Map<String, Integer>();
        
        if(!scoreTypeData.isEmpty()){
            
            for(EWSGlobalDashboardData each : scoreTypeData){
                if(teamFilterValue == 'All' || each.theMaxType == teamFilterValue){
                    List<EWSGlobalDashboardData> tempData = (scoreTypeDataMap.containsKey(each.theTotalScoreColor)) ? scoreTypeDataMap.get(each.theTotalScoreColor) : new List<EWSGlobalDashboardData>();
                    
                    if(tempData.size() < Integer.valueOf(Label.EWS_SIZE_LIMIT)) tempData.add(each);
                    scoreTypeDataMap.put(each.theTotalScoreColor, tempData);                                
                    Integer theCount = (teamOrgCount.containsKey(each.theMaxType)) ? teamOrgCount.get(each.theMaxType) + 1: 1;
                    teamOrgCount.put(each.theMaxType, theCount);
                    
                    Integer theColorCount = (accColorCount.containsKey(each.theTotalScoreColor)) ? accColorCount.get(each.theTotalScoreColor) + 1: 1;
                    accColorCount.put(each.theTotalScoreColor, theColorCount);
                }
            }
            
            if(!teamOrgCount.isEmpty()){
                teamOrgData = new List<EWSGlobalDashboardData>();
                for(String each : teamOrgCount.keySet()){
                    EWSGlobalDashboardData temp = new EWSGlobalDashboardData();
                    temp.theMaxType = each + ' - ' + teamOrgCount.get(each);
                    temp.theMaxAccCount = teamOrgCount.get(each);                    
                    teamOrgData.add(temp);
                }
            }
            
            if(!accColorCount.isEmpty()){
                accColorData = new List<EWSGlobalDashboardData>();
                for(String each : accColorCount.keySet()){
                    colorSet += each + ',';
                    EWSGlobalDashboardData temp = new EWSGlobalDashboardData();
                    temp.theTotalScoreColor = each + ' - ' + accColorCount.get(each);                                        
                    temp.theMaxAccCount = accColorCount.get(each);                    
                    accColorData.add(temp);
                }
                colorSet = colorSet.removeEnd(',');
            }                
        }            
    }
    
    global List<EWSGlobalDashboardData> theScoreTypeData(){       
    
        Map<Id, EWSGlobalDashboardData> theDataMap = new Map<Id, EWSGlobalDashboardData>();                
        List<String> accIds = new List<String>();
        
        for(AggregateResult each : [SELECT SUM(Score__c) sum, Account__c accId FROM Activities__c WHERE (CreatedDate = LAst_N_Days:91 OR CreatedDate = Today) GROUP BY Account__c HAVING (SUM(Score__c) >=: thresholdScore1 and SUM(Score__c)<: thresholdScore2) ORDER BY SUM(Score__c) desc LIMIT 50]){
            accIds.add(String.valueOf(each.get('accId')));
        }
        for(AggregateResult each : [SELECT SUM(Score__c) sum, Account__c accId FROM Activities__c WHERE (CreatedDate = LAst_N_Days:91 OR CreatedDate = Today) GROUP BY Account__c HAVING (SUM(Score__c) >=: thresholdScore2 and SUM(Score__c)<: thresholdScore3) ORDER BY SUM(Score__c) desc LIMIT 50]){
            accIds.add(String.valueOf(each.get('accId')));
        } 
        for(AggregateResult each : [SELECT SUM(Score__c) sum, Account__c accId FROM Activities__c WHERE (CreatedDate = LAst_N_Days:91 OR CreatedDate = Today) GROUP BY Account__c HAVING SUM(Score__c) >=: thresholdScore3 ORDER BY SUM(Score__c) desc LIMIT 50]){
            accIds.add(String.valueOf(each.get('accId')));
        }     
             
        String queryString = 'SELECT Id,Name,ARR_from_Gainsight__c,';
        queryString += '(SELECT Id,Score__c,Type__c FROM Activities__r WHERE ';
        if(String.isNotBlank(teamFilterValue) && teamFilterValue != 'All') {
            queryString += 'Type__c = \'' + teamFilterValue + '\' AND ';
        }
        else{
            queryString += 'Type__c IN (\'CSM\',\'Support\',\'Product\') AND ';
        }
        queryString += '(CreatedDate = LAst_N_Days:91 OR CreatedDate = Today) ORDER BY CreatedDate DESC),';
        queryString += '(SELECT Id,Action_Item__c,Case__c,Case__r.CaseNumber,Current_Action_Owner__r.Name,Current_Action_Owner__c,Status__c,Threshold_value__c,LastModifiedDate,Account__c FROM Threshold_Milestone__r WHERE Status__c != \'Closed\' ORDER BY CreatedDate DESC LIMIT 1)';
        queryString += ' FROM Account WHERE Id ';
        queryString += ' IN '+ '(\''+String.join(accIds, '\',\'')+'\') ';        
        
        integer i = 0;
        for(Account each : Database.query(queryString)){
            i++;            
            EWSGlobalDashboardData temp = new EWSGlobalDashboardData();
            temp.theaccName = each.Name;
            temp.theaccId = each.Id;
            temp.theTotalScore = 0;
            if(!each.Activities__r.isEmpty()){
                Integer csmScore = 0;
                Integer productScore = 0;
                Integer supportScore = 0;
                for(Activities__c eachAct : each.Activities__r){
                    if(eachAct.Type__c == 'CSM') csmScore +=  Integer.valueOf(eachAct.Score__c);
                    if(eachAct.Type__c == 'Support') supportScore +=  Integer.valueOf(eachAct.Score__c);
                    if(eachAct.Type__c == 'Product') productScore +=  Integer.valueOf(eachAct.Score__c);
                }
                
                List<Integer> tempScoreList = new List<Integer>{csmScore, supportScore, productScore};             
                tempScoreList.sort();    
                temp.theTotalScore = csmScore + supportScore + productScore; 
                temp.theMaxTypeScore = tempScoreList[2];
                temp.theMaxType = (csmScore == temp.theMaxTypeScore) ? 'CSM' : ((productScore == temp.theMaxTypeScore) ? 'Product' : 'Support');  
            }
            
            if(temp.theTotalScore >= thresholdScore1){
                temp.theTotalScoreColor = (temp.theTotalScore >= thresholdScore1 && temp.theTotalScore < thresholdScore2) ? 'Yellow' : ((temp.theTotalScore >= thresholdScore2 && temp.theTotalScore < thresholdScore3) ? 'Red' : 'Black');
                
                if(!each.Threshold_Milestone__r.isEmpty()){
                    Threshhold_Milestone__c tm = each.Threshold_Milestone__r[0];                    
                    temp.outReachValue = tm.LastModifiedDate.month() + '/' + tm.LastModifiedDate.day() + '/'+ tm.LastModifiedDate.year();                    
                    temp.actionOwner = tm.Current_Action_Owner__r.Name;
                    temp.actionOwnerId = tm.Current_Action_Owner__c;
                    temp.actionItemId = tm.Id;
                    temp.actionItemCaseId = tm.Case__c;
                    temp.actionItemCaseNumber = '#'+tm.Case__r.CaseNumber;
                }else{
                    temp.outReachValue = 'Not Available';
                    temp.actionOwner = 'Not Available';
                    temp.actionOwnerId = '';
                }
                temp.theArr = (each.ARR_from_Gainsight__c == null) ? 0.00 : each.ARR_from_Gainsight__c;
                theDataMap.put(each.Id, temp);
            }                
        }    
        return theDataMap.values();
    } 
    
    global class EWSGlobalDashboardData{
        global String theMaxType {get;set;}
        global Integer theMaxAccCount {get;set;}
        global String actionOwner {get;set;}
        global String actionOwnerId {get;set;}
        global String actionItemId {get;set;}
        global String actionItemCaseId {get;set;}
        global String actionItemCaseNumber {get;set;} 
        global String theaccId {get;set;}
        global String theaccName {get;set;}
        global Decimal theArr {get;set;}
        global Integer theMaxTypeScore {get;set;}
        global Integer theTotalScore {get;set;}
        global String theTotalScoreColor {get;set;}
        global String outReachValue {get;set;}
        global String theType {get;set;}
        global Integer theTypeScore {get;set;}
        
        
    }   
}