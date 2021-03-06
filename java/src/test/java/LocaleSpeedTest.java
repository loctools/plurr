import com.iafan.plurr.*;

public class LocaleSpeedTest {
  public void testLocaleSpeed() throws PlurrLocaleNotFoundException {
    Plurr p = new Plurr();
    int x = 1000000;

    long start = System.nanoTime();

    for (int i = 0; i < x; i++) {
      p.setLocale("ru");
    }

    long end = System.nanoTime();
    double time = new Long((end - start) / 1000000).doubleValue();
    System.out.printf("Execution time (%d calls): %f sec (%f ms per call)", x, time / 1000, time / x);
  }

  public static void main(String[] args) throws Exception {
    LocaleSpeedTest localeSpeedTest = new LocaleSpeedTest();
    localeSpeedTest.testLocaleSpeed();
  }
}
