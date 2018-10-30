public class AppViewWrapper  {

    public class Rubiks_details {
        public String bundle;
        public String feature_names;
        public String feature_details;
    }

    public class Lp_options {
        public String securePages;
    }

    public class RtpDetails {
        public String munchkin_id;
        public String name;
        public String number_of_reactions;
        public String default_time_zone;
        public String use_marketo_account;
        public String max_abm_records;
        public String max_audiences;
        public String custom_fields_limit;
        public String create_date;
        public String last_update_date;
    }

    public class Subscription {
        public String pod;
        public String customer_prefix;
        public String friendly_name;
        public String customer_db;
        public String dbexists;
        public String sub_id;
        public String sub_type;
        public String purpose;
        public String tracking_url;
        public String tracking_link;
        public String lp_domain;
        public Lp_options lp_options;
        public String munchkin_id;
        public String batch_vsg;
        public String txn_vsg;
        public String test_vsg;
        public String msi_vsg;
        public String multi_ip;
        public String total_users;
        public String active_cal_seats;
        public String cal_users;
        public String msiSeats;
        public String rca;
        public String rca_pod;
        public String social_enabled;
        public String blackcat;
        public String dailyquota;
        public String ratelimit;
        public String seo;
        public String rtp;
        public String created_on;
        public String updated_on;
        public String status;
        public String prefixMunchkin;
        public String munchkin;
        public String activityService;
        public String cv2;
        public String crm;
        public String tigger;
        public String abm;
        public String msiStars;
        public String msdSpark;
        public String leadRestApi;
        public String soapApi;
        public String activityLogUI;
        public String anonLeadStore;
        public String logUploader;
        public String sparkIndexer;
        public String emailReports;
        public String supporttools;
        public String googleadwords;
        public String emailinsights;
        public String webTrackingServiceReport;
    }

    public Subscription subscription;
    public List<Rubiks_details> rubiks_details;
    public List<List<String>> legacy_details;
    public RtpDetails rtpDetails;

    
    public static AppViewWrapper  parse(String json) {
        return (AppViewWrapper ) System.JSON.deserialize(json, AppViewWrapper .class);
    }
}