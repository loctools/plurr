import com.iafan.plurr.*;

class RenderingTest {

  private void pass_or_fail(String n, String reference, String result) {
    System.out.printf("%s: ", n);
    if (reference.equals(result)) {
      System.out.printf("pass\n");
    } else {
      System.out.printf("fail: [%s] vs [%s]\n", result, reference);
    }
  }

  private void t (String n, Plurr p, String s, String message, String exception, String... arg) {
    String result;

    try {
      result = p.format(s, arg);
      this.pass_or_fail(n, message, result);
    } catch (PlurrInternalException e) {
      this.pass_or_fail(n, exception, "PlurrInternalException: " + e.getMessage());
    } catch (PlurrSyntaxException e) {
      this.pass_or_fail(n, exception, "PlurrSyntaxException: " + e.getMessage());
    }
  }

  public void run() throws PlurrLocaleNotFoundException {
    Plurr p = new Plurr();
    String s;

    //this.t("e.1", p, "", undefined, undefined, "", "'params' is not a hash"); // not applicable in Java version
    this.t("e.2", p, "err {", "", "PlurrSyntaxException: Unmatched { found");
    this.t("e.3", p, "err }", "", "PlurrSyntaxException: Unmatched } found");
    this.t("e.4", p, "{foo}", "", "PlurrSyntaxException: 'foo' not defined");
    this.t("e.5", p, "{N_PLURAL}", "", "PlurrSyntaxException: Value of 'N' is not a zero or positive integer number", "N", "NaN");
    this.t("e.6", p, "{N_PLURAL}", "", "PlurrSyntaxException: Value of 'N' is not a zero or positive integer number", "N", "1.5");

    s = "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?";

    this.t("1.1", p, s, "Do you want to delete this 1 file permanently?", "", "N", "1");
    this.t("1.2", p, s, "Do you want to delete these 5 files permanently?", "", "N", "5");

    s = "Do you want to drink {CHOICE:coffee|tea|juice}?";

    this.t("2.1", p, s, "Do you want to drink coffee?", "", "CHOICE", "0");
    this.t("2.2", p, s, "Do you want to drink tea?", "", "CHOICE", "1");
    this.t("2.3", p, s, "Do you want to drink juice?", "", "CHOICE", "2");

    p.setLocale("ru");
    s = "Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?";

    this.t("3.1", p, s, "Удалить этот 1 файл навсегда?", "", "N", "1");
    this.t("3.2", p, s, "Удалить эти 2 файла навсегда?", "", "N", "2");
    this.t("3.3", p, s, "Удалить эти 5 файлов навсегда?", "", "N", "5");
    p.setLocale("en");
    this.t("3.4", p, s, "Удалить эти 5 файла навсегда?", "","N", "5");

    s = "{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found.";

    this.t("4.1", p, s, "No files found.", "", "X", "0");
    this.t("4.2", p, s, "One file found.", "", "X", "1");
    this.t("4.3", p, s, "2 files found.", "", "X", "2");

    this.t("4.4", p, s, "No files found.", "", "X", "0");
    this.t("4.5", p, s, "One file found.", "", "X", "1");
    this.t("4.6", p, s, "2 files found.", "", "X", "2");

    p.setLocale("ru");
    s = "{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}.";

    this.t("5.1", p, s, "Не найдено файлов.", "", "X", "0");
    this.t("5.2", p, s, "Найден один файл.", "", "X", "1");
    this.t("5.3", p, s, "Найдены 2 файла.", "", "X", "2");
    this.t("5.4", p, s, "Найдено 5 файлов.", "", "X", "5");

    p.setLocale("en");
    s = "{FOO}";

    this.t("6.1", p, s, "1", "", "FOO", "1");
    this.t("6.2", p, s, "5.5", "", "FOO", "5.5");
    this.t("6.3", p, s, "bar", "", "FOO", "bar");
  }
}

class rendering {
  public static void main(String[] args) throws PlurrLocaleNotFoundException {
    RenderingTest test = new RenderingTest();
    test.run();
  }
}
