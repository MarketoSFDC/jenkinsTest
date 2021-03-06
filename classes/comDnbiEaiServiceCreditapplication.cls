//Generated by wsdl2apex

public class comDnbiEaiServiceCreditapplication {
    public class CreditApplicationHttpPort {
        public String endpoint_x = 'https://www.dnbi.com/dnbi/services/CreditApplication';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public dtoEaiDnbiCom.AuthenticationDTO_element AuthenticationHeader;
        private String AuthenticationHeader_hns = 'AuthenticationDTO=http://dto.eai.dnbi.com';
        private String[] ns_map_type_info = new String[]{'http://fault.eai.dnbi.com', 'faultEaiDnbiCom', 'http://creditapp.dto.eai.dnbi.com', 'creditappDtoEaiDnbiCom', 'http://businessbureau.dto.eai.dnbi.com', 'businessbureauDtoEaiDnbiCom', 'http://service.eai.dnbi.com', 'serviceEaiDnbiCom', 'http://com.dnbi.eai.service.CreditApplication', 'comDnbiEaiServiceCreditapplication', 'http://lang.java', 'langJava', 'http://dto.eai.dnbi.com', 'dtoEaiDnbiCom', 'http://rmi.java', 'rmiJava', 'http://creditapp.message.eai.dnbi.com', 'creditappMessageEaiDnbiCom', 'http://enumeration.eai.dnbi.com', 'enumerationEaiDnbiCom'};
        public dtoEaiDnbiCom.CompanySearchResultDTO matchCompany(dtoEaiDnbiCom.MatchCompanyRequestDTO in0) {
            comDnbiEaiServiceCreditapplication.matchCompany_element request_x = new comDnbiEaiServiceCreditapplication.matchCompany_element();
            comDnbiEaiServiceCreditapplication.matchCompanyResponse_element response_x;
            request_x.in0 = in0;
            Map<String, comDnbiEaiServiceCreditapplication.matchCompanyResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.matchCompanyResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'matchCompany',
              'http://com.dnbi.eai.service.CreditApplication',
              'matchCompanyResponse',
              'comDnbiEaiServiceCreditapplication.matchCompanyResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public creditappDtoEaiDnbiCom.CreditApplicationDTO getApplication(String in0) {
            comDnbiEaiServiceCreditapplication.getApplication_element request_x = new comDnbiEaiServiceCreditapplication.getApplication_element();
            comDnbiEaiServiceCreditapplication.getApplicationResponse_element response_x;
            request_x.in0 = in0;
            Map<String, comDnbiEaiServiceCreditapplication.getApplicationResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.getApplicationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'getApplication',
              'http://com.dnbi.eai.service.CreditApplication',
              'getApplicationResponse',
              'comDnbiEaiServiceCreditapplication.getApplicationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public creditappMessageEaiDnbiCom.UpdateCreditApplicationResult updateCreditApplication(creditappDtoEaiDnbiCom.UpdateCreditApplicationRequestDTO in0) {
            comDnbiEaiServiceCreditapplication.updateCreditApplication_element request_x = new comDnbiEaiServiceCreditapplication.updateCreditApplication_element();
            comDnbiEaiServiceCreditapplication.updateCreditApplicationResponse_element response_x;
            request_x.in0 = in0;
            Map<String, comDnbiEaiServiceCreditapplication.updateCreditApplicationResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.updateCreditApplicationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'updateCreditApplication',
              'http://com.dnbi.eai.service.CreditApplication',
              'updateCreditApplicationResponse',
              'comDnbiEaiServiceCreditapplication.updateCreditApplicationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public creditappDtoEaiDnbiCom.GetCreditApplicationsResultDTO getApplicationList(creditappDtoEaiDnbiCom.GetListOfApplicationsRequestDTO in0) {
            comDnbiEaiServiceCreditapplication.getApplicationList_element request_x = new comDnbiEaiServiceCreditapplication.getApplicationList_element();
            comDnbiEaiServiceCreditapplication.getApplicationListResponse_element response_x;
            request_x.in0 = in0;
            Map<String, comDnbiEaiServiceCreditapplication.getApplicationListResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.getApplicationListResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'getApplicationList',
              'http://com.dnbi.eai.service.CreditApplication',
              'getApplicationListResponse',
              'comDnbiEaiServiceCreditapplication.getApplicationListResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public creditappMessageEaiDnbiCom.ApplyForCreditResult applyForCredit(dtoEaiDnbiCom.ArrayOfFieldDTO in0,Boolean in1) {
            comDnbiEaiServiceCreditapplication.applyForCredit_element request_x = new comDnbiEaiServiceCreditapplication.applyForCredit_element();
            comDnbiEaiServiceCreditapplication.applyForCreditResponse_element response_x;
            request_x.in0 = in0;
            request_x.in1 = in1;
            Map<String, comDnbiEaiServiceCreditapplication.applyForCreditResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.applyForCreditResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'applyForCredit',
              'http://com.dnbi.eai.service.CreditApplication',
              'applyForCreditResponse',
              'comDnbiEaiServiceCreditapplication.applyForCreditResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult applyForCreditEnhanced(creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest applyForCreditRequestDTO) {
            comDnbiEaiServiceCreditapplication.applyForCreditEnhanced_element request_x = new comDnbiEaiServiceCreditapplication.applyForCreditEnhanced_element();
            comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element response_x;
            request_x.applyForCreditRequestDTO = applyForCreditRequestDTO;
            Map<String, comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'applyForCreditEnhanced',
              'http://com.dnbi.eai.service.CreditApplication',
              'applyForCreditEnhancedResponse',
              'comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
        public Boolean performECFAction(creditappDtoEaiDnbiCom.PerformECFActionRequestDTO in0) {
            comDnbiEaiServiceCreditapplication.performECFAction_element request_x = new comDnbiEaiServiceCreditapplication.performECFAction_element();
            comDnbiEaiServiceCreditapplication.performECFActionResponse_element response_x;
            request_x.in0 = in0;
            Map<String, comDnbiEaiServiceCreditapplication.performECFActionResponse_element> response_map_x = new Map<String, comDnbiEaiServiceCreditapplication.performECFActionResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://com.dnbi.eai.service.CreditApplication',
              'performECFAction',
              'http://com.dnbi.eai.service.CreditApplication',
              'performECFActionResponse',
              'comDnbiEaiServiceCreditapplication.performECFActionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.out;
        }
    }
    public class getApplication_element {
        public String in0;
        private String[] in0_type_info = new String[]{'in0','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0'};
    }
    public class getApplicationResponse_element {
        public creditappDtoEaiDnbiCom.CreditApplicationDTO out;
        private String[] out_type_info = new String[]{'out','http://creditapp.dto.eai.dnbi.com','CreditApplicationDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class getApplicationList_element {
        public creditappDtoEaiDnbiCom.GetListOfApplicationsRequestDTO in0;
        private String[] in0_type_info = new String[]{'in0','http://creditapp.dto.eai.dnbi.com','GetListOfApplicationsRequestDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0'};
    }
    public class applyForCreditEnhancedResponse_element {
        public creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult out;
        private String[] out_type_info = new String[]{'out','http://creditapp.message.eai.dnbi.com','ApplyForCreditEnhancedResult','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://www.w3.org/2001/XMLSchema','string','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class performECFAction_element {
        public creditappDtoEaiDnbiCom.PerformECFActionRequestDTO in0;
        private String[] in0_type_info = new String[]{'in0','http://creditapp.dto.eai.dnbi.com','PerformECFActionRequestDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0'};
    }
    public class updateCreditApplicationResponse_element {
        public creditappMessageEaiDnbiCom.UpdateCreditApplicationResult out;
        private String[] out_type_info = new String[]{'out','http://creditapp.message.eai.dnbi.com','UpdateCreditApplicationResult','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class matchCompany_element {
        public dtoEaiDnbiCom.MatchCompanyRequestDTO in0;
        private String[] in0_type_info = new String[]{'in0','http://dto.eai.dnbi.com','MatchCompanyRequestDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0'};
    }
    public class matchCompanyResponse_element {
        public dtoEaiDnbiCom.CompanySearchResultDTO out;
        private String[] out_type_info = new String[]{'out','http://dto.eai.dnbi.com','CompanySearchResultDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class getApplicationListResponse_element {
        public creditappDtoEaiDnbiCom.GetCreditApplicationsResultDTO out;
        private String[] out_type_info = new String[]{'out','http://creditapp.dto.eai.dnbi.com','GetCreditApplicationsResultDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class updateCreditApplication_element {
        public creditappDtoEaiDnbiCom.UpdateCreditApplicationRequestDTO in0;
        private String[] in0_type_info = new String[]{'in0','http://creditapp.dto.eai.dnbi.com','UpdateCreditApplicationRequestDTO','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0'};
    }
    public class applyForCredit_element {
        public dtoEaiDnbiCom.ArrayOfFieldDTO in0;
        public Boolean in1;
        private String[] in0_type_info = new String[]{'in0','http://dto.eai.dnbi.com','ArrayOfFieldDTO','1','1','true'};
        private String[] in1_type_info = new String[]{'in1','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'in0','in1'};
    }
    public class performECFActionResponse_element {
        public Boolean out;
        private String[] out_type_info = new String[]{'out','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class applyForCreditResponse_element {
        public creditappMessageEaiDnbiCom.ApplyForCreditResult out;
        private String[] out_type_info = new String[]{'out','http://creditapp.message.eai.dnbi.com','ApplyForCreditResult','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'out'};
    }
    public class applyForCreditEnhanced_element {
        public creditappMessageEaiDnbiCom.ApplyForCreditEnhancedRequest applyForCreditRequestDTO;
        private String[] applyForCreditRequestDTO_type_info = new String[]{'applyForCreditRequestDTO','http://creditapp.message.eai.dnbi.com','ApplyForCreditEnhancedRequest','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://com.dnbi.eai.service.CreditApplication','true','true'};
        private String[] field_order_type_info = new String[]{'applyForCreditRequestDTO'};
    }
}