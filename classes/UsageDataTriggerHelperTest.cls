@isTest
public class UsageDataTriggerHelperTest{
    
    public static testMethod void UDTHMethod1(){
        
        Account acc = new Account(Name = 'Test Acc', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        delete UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='SandboxTestBeta',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        delete UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='SandboxTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        delete UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='sandboxTestDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
        delete UD4; 
    }
    public static testMethod void UDTHMethod2(){
        
        Account acc = new Account(Name = 'Test Acc Dev', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='DevTestDevAccDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        delete UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='DTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        delete UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        delete UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccDevTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
        delete UD4; 
        
    }
    public static testMethod void UDTHMethod3(){
        
        Account acc = new Account(Name = 'Test Acc Sandbox', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        delete UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        delete UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='AccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        delete UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
        delete UD4; 
    }
    
     public static testMethod void UDTHMethod4(){
        
        Account acc = new Account(Name = 'Test Acc Dev', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='DevTestDevAccDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='DTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccDevTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
        
    }
        public static testMethod void UDTHMethod5(){
        
        Account acc = new Account(Name = 'Test Acc', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='SandboxTestBeta',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='SandboxTestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='sandboxTestDevBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
    }
        public static testMethod void UDTHMethod6(){
        
        Account acc = new Account(Name = 'Test Acc Sandbox', Sales_Region__c = 'North America',Business_Unit__c = 'AMER-SB');
        insert acc;
        Asset ast = new Asset(Name = 'Test1', AccountId = acc.id, Munchkin_ID__c = '1010101', Status = 'Active');
        insert ast;
        Asset ast2 = new Asset(Name = 'Test2', AccountId = acc.id, Munchkin_ID__c = '1020102', Status = 'Active');
        insert ast2;
        Asset ast3 = new Asset(Name = 'Test3', AccountId = acc.id, Munchkin_ID__c = '10464101', Status = 'Expired');
        insert ast3;
        Asset ast4 = new Asset(Name = 'Test4', AccountId = acc.id, Munchkin_ID__c = '10353101', Status = 'Expired');
        insert ast4;
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD; 
        update UD;
        JBCXM__UsageData__c UD2 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD2;
        update UD2;
        JBCXM__UsageData__c UD3 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='AccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD3;
        update UD3;
        JBCXM__UsageData__c UD4 = new JBCXM__UsageData__c(JBCXM__Account__c=acc.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='1010101',JBCXM__InstanceName__c='TestAccSandboxBetaCust',Name='INSTANCELEVEL', totalknownleadcount__c = 50000,Related_Asset__c = ast.Id );
        insert UD4;
        update UD4;
    }
    

}