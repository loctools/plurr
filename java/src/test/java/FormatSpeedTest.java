import com.iafan.plurr.*;

public class FormatSpeedTest {
  public void testFormatSpeed() throws PlurrInternalException, PlurrSyntaxException, PlurrLocaleNotFoundException {
    Plurr p = new Plurr();
    String s = "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?";
    int x = 1000000;

    long start = System.nanoTime();

    for (int i = 0; i < x; i++) {
      String dummy = p.format(s, "N", "5");
      p.setLocale("ru");
    }

    long end = System.nanoTime();
    double time = new Long((end - start) / 1000000).doubleValue();
    System.out.printf("Execution time (%d calls): %f sec (%f ms per call)", x, time / 1000, time / x);
  }
}
