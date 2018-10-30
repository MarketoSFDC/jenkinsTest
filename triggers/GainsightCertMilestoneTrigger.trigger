trigger GainsightCertMilestoneTrigger on Certification_History__c (after update, after insert) 
{

    try
    {
        Set<id> AccountIDSet = new Set<id>();
        Map<string, string> MilestoneMap = new Map<string, string>();
        List<Certification_History__c> CustCertList = new List<Certification_History__c> ();
        Map<string, JBCXM__CustomerInfo__c> CustInfoMap = new Map<string, JBCXM__CustomerInfo__c>();
        List<JBCXM__Milestone__c> MilestonesToInsert = new List<JBCXM__Milestone__c>();
        Map<string, List<Certification_History__c>> CertAcctIdMap   = new Map<string, List<Certification_History__c>>();
        Map<string, Certification_History__c> OldCertList = new Map<string, Certification_History__c>();
        Map<string, string> ContactMap  = new Map<string, string>();



        if(Trigger.isUpdate)
        {

            for(Certification_History__c CHO : Trigger.old)
            {
                OldCertList.put(CHO.Id, CHO);
            }
        }

        for(Certification_History__c CH : Trigger.new)
        {
            Certification_History__c OLDCH = OldCertList.get(CH.Id);

            if(Trigger.isInsert)
            {
                if( CH.Exam_Result__c == 'Pass' )
                {
                    system.debug('Pass Statement');
                    AccountIDSet.add(CH.Account__c);
                }
            }

            else
            {
            if( CH.Exam_Result__c == 'Pass' && OLDCH.Exam_Result__c != 'Pass')
                {
                    AccountIDSet.add(CH.Account__c);
                }
            }
            List<Certification_History__c> TempList = new List<Certification_History__c>();

            if(CertAcctIdMap.containsKey(CH.Account__c)) 
            {
                TempList = CertAcctIdMap.get(CH.Account__c);
            }

            Templist.add(CH);

            CertAcctIdMap.put(CH.Account__c, Templist);
        }

        for(Contact C : [SELECT Id, Name FROM Contact WHERE AccountId IN :AccountIDSet])
        {
            ContactMap.put(C.Id, C.Name);
        }

        for (JBCXM__CustomerInfo__c CI : [SELECT Id,JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c IN :AccountIDSet ])
        {
            CustInfoMap.put(CI.JBCXM__Account__c, CI);
        }

        for (JBCXM__PickList__c PL : [SELECT Id, JBCXM__SystemName__c, JBCXM__Category__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c = 'Milestones' AND JBCXM__SystemName__c='Marketo Certified'])
        {
            MilestoneMap.put(PL.JBCXM__SystemName__c, PL.Id);
        }

        for(string S  : AccountIDSet)
        {
            if(CertAcctIdMap.containsKey(S))
            { 
                List<Certification_History__c> TempList = CertAcctIdMap.get(S);

                for(Certification_History__c CH : TempList)
                {
                    if(CustInfoMap.containskey(CH.Account__c))
                    {   

                        JBCXM__Milestone__c M   = new JBCXM__Milestone__c();
                        M.JBCXM__Milestone__c   = MilestoneMap.get('Marketo Certified');
                        M.JBCXM__Account__c     = CH.Account__c;
                        M.JBCXM__Comment__c     = 'Name: ' +ContactMap.get(CH.Certification_Contact__c)+ ' | Email: ' +CH.Business_Email_Address__c+ ' | Marketo Certification: ' +CH.Certification_Level__c  ;
                        M.JBCXM__Date__c        = CH.Date_Passed_Exam__c;
                        
                        MilestonesToInsert.add(M);
                
                    }
                }
            } 
        }

        if(MilestonesToInsert.size() > 0) insert MilestonesToInsert;

        }
        
    
   
    catch (Exception e) 
    {
        JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create a Milestone for Marketo Certification',
                                                   JBCXM__LogDateTime__c            = datetime.now(),
                                                   JBCXM__SourceData__c             = e.getMessage(),
                                                   JBCXM__SourceObject__c           = 'Case',
                                                   JBCXM__Type__c                   = 'GainsightCertMilestoneTrigger Trigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }
}