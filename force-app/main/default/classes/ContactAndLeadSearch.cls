public class ContactAndLeadSearch {
    public static List<List< SObject>> searchContactsAndLeads(string namePart){
        return [FIND :namePart IN ALL FIELDS RETURNING Contact(LastName), Lead(LastName)];
    }
}