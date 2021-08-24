public class StringArrayTest {
    public static List<String> generateStringArray(integer stringNumber){
        List<String> stringArray = new List<String>();
        for(Integer i = 0; i < stringNumber; i++){
            stringArray.add('Test '+i);
        }
        return stringArray;
    }
}