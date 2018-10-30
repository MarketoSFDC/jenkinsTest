//Generated by wsdl2apex

public class creditappMessageEaiDnbiCom {
    public class ApplyForCreditEnhancedResult {
        public Boolean applicationCreated;
        public creditappDtoEaiDnbiCom.CreditApplicationECFDTO applicationECF;
        public String applicationId;
        public businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO bureauCompanyList;
        public creditappDtoEaiDnbiCom.BureauErrorDTO bureauPullError;
        public Boolean bureauPullErrorFlag;
        public creditappDtoEaiDnbiCom.CompanyInfoDTO companyInfoDTO;
        public creditappDtoEaiDnbiCom.CorporateLinkageDTO corporateLinkageDTO;
        public DateTime dateOfDecisioning;
        public dtoEaiDnbiCom.ArrayOfFieldErrorDTO errorFieldList;
        public Boolean exactMatchFound;
        public Boolean listOfSimilarsFound;
        public Boolean noMatchFound;
        private String[] applicationCreated_type_info = new String[]{'applicationCreated','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] applicationECF_type_info = new String[]{'applicationECF','http://creditapp.dto.eai.dnbi.com','CreditApplicationECFDTO','0','1','true'};
        private String[] applicationId_type_info = new String[]{'applicationId','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] bureauCompanyList_type_info = new String[]{'bureauCompanyList','http://businessbureau.dto.eai.dnbi.com','ArrayOfBureauCompanyDTO','0','1','true'};
        private String[] bureauPullError_type_info = new String[]{'bureauPullError','http://creditapp.dto.eai.dnbi.com','BureauErrorDTO','0','1','true'};
        private String[] bureauPullErrorFlag_type_info = new String[]{'bureauPullErrorFlag','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] companyInfoDTO_type_info = new String[]{'companyInfoDTO','http://creditapp.dto.eai.dnbi.com','CompanyInfoDTO','0','1','true'};
        private String[] corporateLinkageDTO_type_info = new String[]{'corporateLinkageDTO','http://creditapp.dto.eai.dnbi.com','CorporateLinkageDTO','0','1','true'};
        private String[] dateOfDecisioning_type_info = new String[]{'dateOfDecisioning','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] errorFieldList_type_info = new String[]{'errorFieldList','http://dto.eai.dnbi.com','ArrayOfFieldErrorDTO','0','1','true'};
        private String[] exactMatchFound_type_info = new String[]{'exactMatchFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] listOfSimilarsFound_type_info = new String[]{'listOfSimilarsFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] noMatchFound_type_info = new String[]{'noMatchFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.message.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationCreated','applicationECF','applicationId','bureauCompanyList','bureauPullError','bureauPullErrorFlag','companyInfoDTO','corporateLinkageDTO','dateOfDecisioning','errorFieldList','exactMatchFound','listOfSimilarsFound','noMatchFound'};
    }
    public class ApplyForCreditResult {
        public Boolean applicationCreated;
        public creditappDtoEaiDnbiCom.CreditApplicationECFDTO applicationECF;
        public String applicationId;
        public businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO bureauCompanyList;
        public creditappDtoEaiDnbiCom.BureauErrorDTO bureauPullError;
        public Boolean bureauPullErrorFlag;
        public dtoEaiDnbiCom.ArrayOfFieldErrorDTO errorFieldList;
        public Boolean exactMatchFound;
        public Boolean listOfSimilarsFound;
        public Boolean noMatchFound;
        private String[] applicationCreated_type_info = new String[]{'applicationCreated','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] applicationECF_type_info = new String[]{'applicationECF','http://creditapp.dto.eai.dnbi.com','CreditApplicationECFDTO','0','1','true'};
        private String[] applicationId_type_info = new String[]{'applicationId','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] bureauCompanyList_type_info = new String[]{'bureauCompanyList','http://businessbureau.dto.eai.dnbi.com','ArrayOfBureauCompanyDTO','0','1','true'};
        private String[] bureauPullError_type_info = new String[]{'bureauPullError','http://creditapp.dto.eai.dnbi.com','BureauErrorDTO','0','1','true'};
        private String[] bureauPullErrorFlag_type_info = new String[]{'bureauPullErrorFlag','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] errorFieldList_type_info = new String[]{'errorFieldList','http://dto.eai.dnbi.com','ArrayOfFieldErrorDTO','0','1','true'};
        private String[] exactMatchFound_type_info = new String[]{'exactMatchFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] listOfSimilarsFound_type_info = new String[]{'listOfSimilarsFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] noMatchFound_type_info = new String[]{'noMatchFound','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.message.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationCreated','applicationECF','applicationId','bureauCompanyList','bureauPullError','bureauPullErrorFlag','errorFieldList','exactMatchFound','listOfSimilarsFound','noMatchFound'};
    }
    public class ApplyForCreditEnhancedRequest {
        public Boolean HQDunsNeeded;
        public dtoEaiDnbiCom.ArrayOfFieldDTO allFieldList;
        public Boolean exactCompanyMatchRequiredFlag;
        private String[] HQDunsNeeded_type_info = new String[]{'HQDunsNeeded','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] allFieldList_type_info = new String[]{'allFieldList','http://dto.eai.dnbi.com','ArrayOfFieldDTO','0','1','true'};
        private String[] exactCompanyMatchRequiredFlag_type_info = new String[]{'exactCompanyMatchRequiredFlag','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.message.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'HQDunsNeeded','allFieldList','exactCompanyMatchRequiredFlag'};
    }
    public class UpdateCreditApplicationResult {
        public Boolean applicationUpdated;
        public dtoEaiDnbiCom.ArrayOfFieldErrorDTO errorFieldList;
        private String[] applicationUpdated_type_info = new String[]{'applicationUpdated','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] errorFieldList_type_info = new String[]{'errorFieldList','http://dto.eai.dnbi.com','ArrayOfFieldErrorDTO','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.message.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationUpdated','errorFieldList'};
    }
}