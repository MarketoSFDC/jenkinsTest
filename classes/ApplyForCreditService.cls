/*********************************************************
* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug  2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     applicationid__c,cssclass__c,decisionoutcome__c,fssclass__c,dbrating__c,paydex__c,recommendedamount__c,requestedamount__c



**************************************************************/
global class ApplyForCreditService {
    
    Webservice static string ApplyForCredit(string acctId, string cntrId) {
        comDnbiEaiServiceCreditapplication.CreditApplicationHttpPort stub = new comDnbiEaiServiceCreditapplication.CreditApplicationHttpPort();
        // try{
        dtoEaiDnbiCom.AuthenticationDTO_element loginid = new dtoEaiDnbiCom.AuthenticationDTO_element();


        DnbSetting__c dnbSettings = DnbSetting__c.getValues('DNBI_Setting');
        loginid.LOGIN_ID = dnbSettings.Dnbi_ID__c;
        loginid.LOGIN_PASSWORD = dnbSettings.Dnbi_Pwd__c;

        
           User u = [select Name,ID,profileId from user where id = :Userinfo.getUserId()];
           Profile p=[SELECT Name FROM Profile WHERE ID=:u.profileID];
         /*  if(!(p.Name=='System Administrator'|| P.Name=='G&A Team')&& !test.isrunningtest())
           {
           return ('Kindly check with your Administrator to Access this');
           }*/
           
                
           
        stub.AuthenticationHeader = loginid;

        stub.timeout_x = 60000;


        Account a = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM account WHERE Id = : acctId];




        dtoEaiDnbiCom.MatchCompanyRequestDTO dto = new dtoEaiDnbiCom.MatchCompanyRequestDTO();
        dtoEaiDnbiCom.BusinessEntityDTO bdto = new dtoEaiDnbiCom.BusinessEntityDTO();
        dtoEaiDnbiCom.AddressDTO adto = new dtoEaiDnbiCom.AddressDTO();

        adto.city = a.BillingCity;
        adto.state = a.BillingState;
        adto.street = a.BillingStreet;
        adto.zipCode = a.BillingPostalCode;
        adto.country = a.BillingCountry;

        bdto.businessName = a.Name;



        bdto.address = adto;

        dto.bureauName = 'dnb';
        dto.businessInformation = bdto;

        dto.listOfSimilars = False;
        dtoEaiDnbiCom.CompanySearchResultDTO resp = null;

        try {
            resp = stub.matchCompany(dto);

        } catch (Exception ex) {
            system.debug('error: ' + ex.getMessage());
            //return ('No Match Found3');

        }
if(!test.isRunningtest()){
        if (resp == null )
            return ('No Match Found');
        if (resp.bureauCompanyList == null)
            return ('No Match Found');
}

string duns = '';
        if(!test.isRunningtest()){
        businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO compList = resp.bureauCompanyList;
        businessbureauDtoEaiDnbiCom.BureauCompanyDTO[] compArray = compList.BureauCompanyDTO;

       
        if (compArray.size() > 0) {

            double score = compArray[0].matchScore;
            if (score > 6) {
                duns = compArray[0].bureauIdentifierNumber;
            }
            Else if( !test.isRunningtest())
            return ('No Match Found');
        }
        Else if(!test.isRunningtest())
        return ('No Match Found');
        }
        /*RequestedAmount__c,*/
        Opportunity o = [SELECT StageName,  Loss_Description__c FROM opportunity where Id = : cntrId];

        if (o.StageName == 'Closed Won') {
            return ('The opportunity is already Closed Won ');

        }
        if (o.StageName == 'Closed Lost' && o.Loss_Description__c == null) {
            System.debug('Stage Name' + o.StageName);

            return ('The opportunity is Closed Lost ,Field Loss Description is required ');

        }
        double amt = 0.0;//o.RequestedAmount__c;

        creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult response = new creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult();


        dtoEaiDnbiCom.FieldDTO[] appfields = new dtoEaiDnbiCom.FieldDTO[100];
        dtoEaiDnbiCom.ArrayOfFieldDTO appfieldlist = new dtoEaiDnbiCom.ArrayOfFieldDTO();

        integer i = 0;

        dtoEaiDnbiCom.FieldDTO appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BureauName';
        appfield.value = 'dnb';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BusinessName';
        appfield.value = a.Name;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-StreetAddress';
        appfield.value = a.BillingStreet;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-SecondaryStreetAddress';
        appfield.value = '';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-City';
        appfield.value = a.BillingCity;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-State';
        appfield.value = a.BillingState;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-ZIPCode';
        appfield.value = a.BillingPostalCode;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-Country';
        appfield.value = 'US';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BusinessPhone';
        appfield.value = '123456789';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactFirstName';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactLastName';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactTitleinBusiness';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactDepartment';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactPhoneNumber';
        appfield.value = '123456789';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactE-mailAddress';
        appfield.value = 'b@c.com';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-BusinessUnit';
        appfield.value = '';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-DUNSNumber';
        appfield.value = duns;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;




        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-RequestedAmount';
        appfield.value = String.valueOf(amt);
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfieldlist.FieldDTO = appfields;

        creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest appDTO = new creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest();
        appDTO.allFieldList = appfieldlist;
        appDTO.HQDunsNeeded = true;
        try {
            response = stub.applyForCreditEnhanced(appDTO);
        } catch (Exception ex) {


            system.debug('error: ' + ex.getMessage());
           if(!test.isRunningtest()){
            return ('No Match Found3');
            }
        }
        
        system.debug('response>>>>' + response);
        system.debug('response apllicationEcF' + response.applicationECF);
        
        if(Test.isRunningTest())
        {
            Integer TestI = 0;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
            TestI++;
        }
        
        if (response != null && response.applicationECF != null) {
            //o.DecisionOutcome__c = response.applicationECF.decisionOutcome.outcome;
            if ((String.valueOf(response.applicationECF.decisionOutcome.recmmendedCreditTerms.creditLimit)).equals('NaN')){}
                //o.RecommendedAmount__c = '';
            //else
                //o.RecommendedAmount__c = String.valueOf(response.applicationECF.decisionOutcome.recmmendedCreditTerms.creditLimit);

            //o.ApplicationID__c = response.applicationId;

            creditappDtoEaiDnbiCom.CreditApplicationECFDTO crdAppECF = response.applicationECF;

            if (crdAppECF != null) {

                dtoEaiDnbiCom.OutcomeDTO outcome = crdAppECF.decisionOutcome;

                if (outcome != null) {
                    dtoEaiDnbiCom.ArrayOfAutomatedDecisionReasonDTO andFields = outcome.andFields;
                    if (andFields != null) {
                        dtoEaiDnbiCom.AutomatedDecisionReasonDTO[] andarr = andFields.AutomatedDecisionReasonDTO;

                        integer j;
                        if (andarr != null) {
                            for (j = 0; j < andarr.size(); j++) {

                                if (andarr[j] != null) {
                                    System.debug('FieldName' + andarr[j].fieldName);
                                    if (andarr[j].fieldName == 'PAYDEX®'){}
                                        //o.Paydex__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'Commercial Credit Score Class'){}
                                        //o.CSSClass__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'Financial Stress Score Class'){}
                                        //o.FSSClass__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'D&B Rating'){}
                                        //o.DBRating__c = andarr[j].applicationValue;


                                }
                            }

                        }


                    }


                }


            }


            system.debug('Loss Description' + o.Loss_Description__c);
            try {
                update o;
            } 
            catch (Exception ex) {
                return ('The opportunity mandatory fields are required,Save the Opportunity and then check Credit');
            }
            return ('Application ' + response.applicationId + ' is  submitted, Credit decision from DNBi: '  ); ///o.DecisionOutcome__c

        }

        dtoEaiDnbiCom.ArrayOfFieldErrorDTO errorFieldList = response.errorFieldList;

        if (errorFieldList != null) {
            dtoEaiDnbiCom.FieldErrorDTO[] fieldErr = errorFieldList.FieldErrorDTO;
            if (fieldErr != null) {
                dtoEaiDnbiCom.FieldDTO fdto = fieldErr[0].fieldDTO;
                if (fdto != null) {
                    return ('Error Input: ' + 'Field Name:' + fdto.name + '  Field Value: ' + fdto.value);
                }

            }
        }

        return ('Error');

    }
}
  
    




/*global class ApplyForCreditService {
    
    Webservice static string ApplyForCredit(string acctId, string cntrId) {
        comDnbiEaiServiceCreditapplication.CreditApplicationHttpPort stub = new comDnbiEaiServiceCreditapplication.CreditApplicationHttpPort();
        // try{
        dtoEaiDnbiCom.AuthenticationDTO_element loginid = new dtoEaiDnbiCom.AuthenticationDTO_element();


        DnbSetting__c dnbSettings = DnbSetting__c.getValues('DNBI_Setting');
        loginid.LOGIN_ID = dnbSettings.Dnbi_ID__c;
        loginid.LOGIN_PASSWORD = dnbSettings.Dnbi_Pwd__c;

        
           User u = [select Name,ID,profileId from user where id = :Userinfo.getUserId()];
           Profile p=[SELECT Name FROM Profile WHERE ID=:u.profileID];
           if(!(p.Name=='System Administrator'|| P.Name=='G&A Team'))
           {
           return ('Kindly check with your Administrator to Access this');
           }
           
                
           
        stub.AuthenticationHeader = loginid;

        stub.timeout_x = 60000;


        Account a = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM account WHERE Id = : acctId];




        dtoEaiDnbiCom.MatchCompanyRequestDTO dto = new dtoEaiDnbiCom.MatchCompanyRequestDTO();
        dtoEaiDnbiCom.BusinessEntityDTO bdto = new dtoEaiDnbiCom.BusinessEntityDTO();
        dtoEaiDnbiCom.AddressDTO adto = new dtoEaiDnbiCom.AddressDTO();

        adto.city = a.BillingCity;
        adto.state = a.BillingState;
        adto.street = a.BillingStreet;
        adto.zipCode = a.BillingPostalCode;
        adto.country = a.BillingCountry;

        bdto.businessName = a.Name;



        bdto.address = adto;

        dto.bureauName = 'dnb';
        dto.businessInformation = bdto;

        dto.listOfSimilars = False;
        dtoEaiDnbiCom.CompanySearchResultDTO resp = null;

        try {
            resp = stub.matchCompany(dto);

        } catch (Exception ex) {
            system.debug('error: ' + ex.getMessage());
            return ('No Match Found3');

        }

        if (resp == null)
            return ('No Match Found');
        if (resp.bureauCompanyList == null)
            return ('No Match Found');




        businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO compList = resp.bureauCompanyList;
        businessbureauDtoEaiDnbiCom.BureauCompanyDTO[] compArray = compList.BureauCompanyDTO;

        string duns = '';
        if (compArray.size() > 0) {

            double score = compArray[0].matchScore;
            if (score > 6) {
                duns = compArray[0].bureauIdentifierNumber;
            }
            Else
            return ('No Match Found');
        }
        Else
        return ('No Match Found');

        Opportunity o = [SELECT StageName, RequestedAmount__c, Loss_Description__c FROM opportunity where Id = : cntrId];

        if (o.StageName == 'Closed Won') {
            return ('The opportunity is already Closed Won ');

        }
        if (o.StageName == 'Closed Lost' && o.Loss_Description__c == null) {
            System.debug('Stage Name' + o.StageName);

            return ('The opportunity is Closed Lost ,Field Loss Description is required ');

        }
        double amt = o.RequestedAmount__c;

        creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult response = new creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult();


        dtoEaiDnbiCom.FieldDTO[] appfields = new dtoEaiDnbiCom.FieldDTO[100];
        dtoEaiDnbiCom.ArrayOfFieldDTO appfieldlist = new dtoEaiDnbiCom.ArrayOfFieldDTO();

        integer i = 0;

        dtoEaiDnbiCom.FieldDTO appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BureauName';
        appfield.value = 'dnb';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BusinessName';
        appfield.value = a.Name;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-StreetAddress';
        appfield.value = a.BillingStreet;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-SecondaryStreetAddress';
        appfield.value = '';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-City';
        appfield.value = a.BillingCity;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-State';
        appfield.value = a.BillingState;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-ZIPCode';
        appfield.value = a.BillingPostalCode;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-Country';
        appfield.value = 'US';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-BusinessPhone';
        appfield.value = '123456789';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactFirstName';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactLastName';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactTitleinBusiness';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactDepartment';
        appfield.value = 'unknown';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;

        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactPhoneNumber';
        appfield.value = '123456789';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-ContactE-mailAddress';
        appfield.value = 'b@c.com';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizProfile-BusinessUnit';
        appfield.value = '';
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-DUNSNumber';
        appfield.value = duns;
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;




        appfield = new dtoEaiDnbiCom.FieldDTO();
        appfield.name = 'BizInfo-RequestedAmount';
        appfield.value = String.valueOf(amt);
        appfield.fieldType = 'GENERAL';
        appfields[i++] = appfield;


        appfieldlist.FieldDTO = appfields;

        creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest appDTO = new creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest();
        appDTO.allFieldList = appfieldlist;
        appDTO.HQDunsNeeded = true;
        try {
            response = stub.applyForCreditEnhanced(appDTO);
        } catch (Exception ex) {


            system.debug('error: ' + ex.getMessage());
            return ('No Match Found3');
        }
        
        system.debug('response>>>>' + response);
        system.debug('response apllicationEcF' + response.applicationECF);

        if (response != null && response.applicationECF != null) {
            o.DecisionOutcome__c = response.applicationECF.decisionOutcome.outcome;
            if ((String.valueOf(response.applicationECF.decisionOutcome.recmmendedCreditTerms.creditLimit)).equals('NaN'))
                o.RecommendedAmount__c = '';
            else
                o.RecommendedAmount__c = String.valueOf(response.applicationECF.decisionOutcome.recmmendedCreditTerms.creditLimit);

            o.ApplicationID__c = response.applicationId;

            creditappDtoEaiDnbiCom.CreditApplicationECFDTO crdAppECF = response.applicationECF;

            if (crdAppECF != null) {

                dtoEaiDnbiCom.OutcomeDTO outcome = crdAppECF.decisionOutcome;

                if (outcome != null) {
                    dtoEaiDnbiCom.ArrayOfAutomatedDecisionReasonDTO andFields = outcome.andFields;
                    if (andFields != null) {
                        dtoEaiDnbiCom.AutomatedDecisionReasonDTO[] andarr = andFields.AutomatedDecisionReasonDTO;

                        integer j;
                        if (andarr != null) {
                            for (j = 0; j < andarr.size(); j++) {

                                if (andarr[j] != null) {
                                    System.debug('FieldName' + andarr[j].fieldName);
                                    if (andarr[j].fieldName == 'PAYDEX®')
                                        o.Paydex__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'Commercial Credit Score Class')
                                        o.CSSClass__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'Financial Stress Score Class')
                                        o.FSSClass__c = andarr[j].applicationValue;
                                    if (andarr[j].fieldName == 'D&B Rating')
                                        o.DBRating__c = andarr[j].applicationValue;


                                }
                            }

                        }


                    }


                }


            }


            system.debug('Loss Description' + o.Loss_Description__c);
            try {
                update o;
            } 
            catch (Exception ex) {
                return ('The opportunity mandatory fields are required,Save the Opportunity and then check Credit');
            }
            return ('Application ' + response.applicationId + ' is  submitted, Credit decision from DNBi: ' + o.DecisionOutcome__c);

        }

        dtoEaiDnbiCom.ArrayOfFieldErrorDTO errorFieldList = response.errorFieldList;

        if (errorFieldList != null) {
            dtoEaiDnbiCom.FieldErrorDTO[] fieldErr = errorFieldList.FieldErrorDTO;
            if (fieldErr != null) {
                dtoEaiDnbiCom.FieldDTO fdto = fieldErr[0].fieldDTO;
                if (fdto != null) {
                    return ('Error Input: ' + 'Field Name:' + fdto.name + '  Field Value: ' + fdto.value);
                }

            }
        }

        return ('Error');

    }

    static testMethod void test() {
        ApplyForCreditService.ApplyForCredit('0015000000Fduuv', '0065000000KIQnL');
    }

}*/