//Generated by wsdl2apex

public class faultEaiDnbiCom {
    public class ApplicationNumberNotFoundError {
        public String applicationNumber;
        public String ErrorMessage;
        private String[] applicationNumber_type_info = new String[]{'applicationNumber','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationNumber','ErrorMessage'};
    }
    public class DUNSNumberNotFoundError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class MatchNotFoundError {
        public String businessName;
        public String ErrorMessage;
        public String workflowStatus;
        private String[] businessName_type_info = new String[]{'businessName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] workflowStatus_type_info = new String[]{'workflowStatus','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'businessName','ErrorMessage','workflowStatus'};
    }
    public class EmptyInputStringError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class IncompleteMatchListReturnedError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class InvalidWorkflowStatusError {
        public String ErrorMessage;
        public String nodeName;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] nodeName_type_info = new String[]{'nodeName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage','nodeName'};
    }
    public class ActionAlreadyTakenError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class ApplicationIDNotProvidedError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class MandatoryFieldsMissingError {
        public String ErrorMessage;
        public String fieldName;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] fieldName_type_info = new String[]{'fieldName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage','fieldName'};
    }
    public class CompanyNotFoundError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class FieldErrorCode {
        public String value;
        private String[] value_type_info = new String[]{'value','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class ApplicationIDNotFoundError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class ApplicationAlreadyExistsInspecifiedStateError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class ActionNotExistsError {
        public String actionName;
        public String ErrorMessage;
        private String[] actionName_type_info = new String[]{'actionName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'actionName','ErrorMessage'};
    }
    public class BureauNotConfiguredError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class InvalidApplicationIDError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class ExactMatchNotFoundError {
        public String businessName;
        public String ErrorMessage;
        public String workflowStatus;
        private String[] businessName_type_info = new String[]{'businessName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] workflowStatus_type_info = new String[]{'workflowStatus','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'businessName','ErrorMessage','workflowStatus'};
    }
    public class BusinessNameNotProvidedError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
    public class BureauNotAvailableError {
        public String ErrorMessage;
        private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://fault.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'ErrorMessage'};
    }
}