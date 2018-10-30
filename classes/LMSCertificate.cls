/**
 * NAME: LMSCertificate
 * DEVELOPER: Appirio
 * CREATED DATE: 2013/11/29
 *
 * DESCRIPTION:
 * General controller
 * Get Data for Certificate page
 *
 * CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2013/11/29
 * Appirio               Updated class                           2014/01/13
 * Sunny Gill               Updated type of CompletionDate to String     2015/03/13
 * Daniel Bradbury       Updated class                           2018/03/28
 */

public without sharing class LMSCertificate {
/**
    * Method: Constructor LMSCertificate
    *
    * Starting method that get all the values.
    *
    * @param Void
    * @return void
    */
    public static final String COMPLETED = 'Completed';
    private final String COMPLETED_OBJECT;
    private static final Decimal COMPLETED_STATUS;
    public Boolean GOT_ERRORS {get;set;}
    static {
        COMPLETED_STATUS = 100.00;
    }

    public LMSCertificate(){
        this.GOT_ERRORS = false;
        Id gid = NULL;
        try {
            gid = ApexPages.currentPage().getParameters().get('id');
        }catch(System.StringException parseException){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Sorry, but ID is invalid'));
        }
        if(gid == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please enter a valid ID.'));
            return;
        }

        String prefix = String.valueOf(gid);
        ID USER_ID = Userinfo.getUserId();
        String keyPrefix = prefix.substring(0, 3);
        Boolean Record_Exist = true;
            if(lmscons__Training_Path_Assignment_Progress__c.SObjectType.getDescribe().getKeyPrefix().Equals(keyPrefix)){
                List<lmscons__Training_Path_Assignment_Progress__c>  PathProgress = [SELECT Id, lmscons__Training_Path__r.Name, lmscons__Transcript__r.lmscons__Trainee__r.Name, lmscons__Completion_Date__c
                                                    FROM lmscons__Training_Path_Assignment_Progress__c
                                                    WHERE Id = :gid AND lmscons__Transcript__r.lmscons__Trainee__c = : USER_ID AND lmscons__Training_Path__r.lmscons__Enable_Certificate__c = true
                                                    AND lmscons__StatusPicklist__c = :COMPLETED
                                                    LIMIT 1];
                                                    
                if(!PathProgress.isEmpty()) {
                    if(PathProgress[0].lmscons__Completion_Date__c != null ){
                        this.CompletionDate = PathProgress[0].lmscons__Completion_Date__c.format('MMMM d yyyy');
                    }
                        this.UserName = PathProgress[0].lmscons__Transcript__r.lmscons__Trainee__r.Name;
                        this.Title = PathProgress[0].lmscons__Training_Path__r.Name;
                } else { Record_Exist = false; }

            }else if(lmscons__Transcript_Line__c.SObjectType.getDescribe().getKeyPrefix().Equals(keyPrefix)){
                List<lmscons__Transcript_Line__c>  TrcLine = [SELECT Id, lmscons__Transcript__r.lmscons__Trainee__r.Name, lmscons__Quiz__c, lmscons__Training_Content__c, lmscons__Content_Title__c, lmscons__Completion_Date__c, lmscons__Trainee__c, lmscons__Score__c, lmscons__Completed_Date__c
                                                    FROM lmscons__Transcript_Line__c
                                                    WHERE Id = :gid
                                                    AND lmscons__Transcript__r.lmscons__Trainee__c = : USER_ID
                                                    AND lmscons__Percent_Complete__c =:COMPLETED_STATUS AND lmscons__Training_User_License__r.lmscons__Content_License__r.lmscons__Training_Content__r.lmscons__Enable_Certificate__c = true AND lmscons__Status__c != 'Failed'
                                                    LIMIT 1];
                                                
                if(!TrcLine.isEmpty()) {
               if(TrcLine[0].lmscons__Completion_Date__c != null ){    
                        this.CompletionDate = TrcLine[0].lmscons__Completion_Date__c.format('MMMM d yyyy');
                }        
                        this.UserName = TrcLine[0].lmscons__Transcript__r.lmscons__Trainee__r.Name;
                        this.Title = TrcLine[0].lmscons__Content_Title__c;
                } else { Record_Exist = false; }

            }else if(lmscons__Learning_Path_Assignment__c.SObjectType.getDescribe().getKeyPrefix().Equals(keyPrefix)){
                List<lmscons__Learning_Path_Assignment__c>  LPAssign = [SELECT Id, lmscons__Transcript__r.lmscons__Trainee__r.Name, lmscons__Learning_Path__r.Name, lmscons__Completion_Date__c
                                                    FROM lmscons__Learning_Path_Assignment__c
                                                    WHERE Id = :gid
                                                    AND lmscons__Transcript__r.lmscons__Trainee__c = : USER_ID AND lmscons__Learning_Path__r.lmscons__Enable_Certificate__c  = true
                                                    AND lmscons__Status__c = :COMPLETED
                                                    LIMIT 1];
                                                 
                if(!LPAssign.isEmpty()) {
                if(LPAssign[0].lmscons__Completion_Date__c != null ){    
                    this.CompletionDate = LPAssign[0].lmscons__Completion_Date__c.format('MMMM d yyyy');
                }
                    this.UserName = LPAssign[0].lmscons__Transcript__r.lmscons__Trainee__r.Name;
                    this.Title = LPAssign[0].lmscons__Learning_Path__r.Name;
                } else { Record_Exist = false; }

            }else if(lmscons__Curriculum_Assignment__c.SObjectType.getDescribe().getKeyPrefix().Equals(keyPrefix)){
                List<lmscons__Curriculum_Assignment__c>  CrcAssign = [SELECT Id, lmscons__Transcript__r.lmscons__Trainee__r.Name,lmscons__Curriculum__r.Name, lmscons__Completion_Date__c
                                                    FROM lmscons__Curriculum_Assignment__c
                                                    WHERE Id = :gid
                                                    AND lmscons__Transcript__r.lmscons__Trainee__c = : USER_ID AND lmscons__Curriculum__r.lmscons__Enable_Certificate__c = true
                                                    AND lmscons__Status__c = :COMPLETED
                                                    LIMIT 1];
                                              
                if(!CrcAssign.isEmpty()) {
                if(CrcAssign[0].lmscons__Completion_Date__c != null ){      
                    this.CompletionDate = CrcAssign[0].lmscons__Completion_Date__c.format('MMMM d yyyy');
                }
                    this.UserName = CrcAssign[0].lmscons__Transcript__r.lmscons__Trainee__r.Name;
                    this.Title = CrcAssign[0].lmscons__Curriculum__r.Name;
                } else { Record_Exist = false; }

            } else {
                this.GOT_ERRORS = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, 'INVALID ID'));
            }

            if(!Record_Exist){
                this.GOT_ERRORS = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, 'INVALID ID'));
            }
    }


    //Get data set for Certificate
    public lmscons__Transcript_Line__c returncert;
    public String CompletionDate {get; set;} //Date certificate completed
    public DateTime ExpiryDate {get; set;} // Date certificate Expired
    public DateTime TodayDate {get {return date.Today(); } set;} // Date certificate Created
    public String UserName {get; set;} //Full user name
    public String FName {get; set;} //First Name
    public String LName {get; set;} // Last Name
    public String Title {get; set;} // Title Learning Object
    }