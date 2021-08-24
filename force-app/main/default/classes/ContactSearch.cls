public class ContactSearch {
    public static List<Contact> searchForContacts(string lastName, string postalCode){
        return [SELECT ID, Name FROM Contact WHERE LastName =: lastName AND MailingPostalCode =: postalCode];
    }
}