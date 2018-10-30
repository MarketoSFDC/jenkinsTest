public class SessionData {
    public String sessionId;
    public String userId;
    public String organizationId;
    public String serverTime;
    public String licenseType;

    public static SessionData parse(String json) {
        return (SessionData) System.JSON.deserialize(json, SessionData.class);
    }
}