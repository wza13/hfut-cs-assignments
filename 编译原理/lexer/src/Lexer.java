import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;


/**
 * A very limited Lexer.
 * @author yzj
 */
public class Lexer {
    public enum Type {
        ERROR, KEYWORD, SEPARATOR, ARITHMETIC_OP, RELATIONAL_OP, NUMBER, ID
    }

    private String[] k = {"do", "end", "for", "if", "printf", "scanf", "then", "while"};
    /* 0 - 5, 6 - 9, 10 - 15 */
    private String[] s = {",", ";", "(", ")", "[", "]",
            "+", "-", "*", "/",
            "<", "<=", "=", ">", ">=", "<>"};

    private char ch;
    private int row;
    private int line;
    private StringBuilder inString = new StringBuilder();
    private StringBuilder outToken = new StringBuilder();
    private int bufferPointer;

    private List<String> kList;
    private List<String> sList;


    public static void main(String[] args) throws IOException {
        Lexer lexer = new Lexer("./src/input.txt");
        lexer.start();
    }

    public Lexer(String filename) throws IOException {
        InputStreamReader reader =
                new InputStreamReader(new FileInputStream(filename));
        for (int ch; (ch = reader.read()) != -1; ) {
            inString.append((char) ch);
        }
        bufferPointer = 0;
        row = 1;
        line = 1;
        kList = Arrays.asList(k);
        sList = Arrays.asList(s);
    }

    public void start() {
        while (bufferPointer < inString.length()) {
            getChar();
            handleSpace();
            if (isLetter()) analyzeWord();
            else if (isDigit()) analyzeNumber();
            else if (isPunctuation()) analyzePunctuation();
            else if (ch == '\0') return;
            else {
                outToken.append(ch);
                log(Type.ERROR);
            }
        }
    }

    private void analyzeWord() {
        while (isLetter() || isDigit()) {
            outToken.append(ch);
            getChar();
        }
        backtrack();
        if (isKeyword()) log(Type.KEYWORD);
        else log(Type.ID);
    }

    private void analyzeNumber() {
        while (isDigit()) {
            outToken.append(ch);
            getChar();
        }
        if (!isLetter()) {
            backtrack();
            log(Type.NUMBER);
            return;
        }
        while (isLetter() || isDigit()) {
            outToken.append(ch);
            getChar();
        }
        backtrack();
        log(Type.ERROR);
    }

    private void analyzePunctuation() {
        /* punctuation has this feature that the length is 1 or 2
        and the first letter of all the 2-length ones is also one of the punctuation */
        outToken.append(ch);
        String tempPunctuation = outToken.toString();
        getChar();
        outToken.append(ch);
        if (!isPunctuation()) {
            backtrack();
            outToken.delete(0, outToken.length());
            outToken.append(tempPunctuation);
        }
        log(getPunctuationType());
    }

    private boolean isKeyword() {
        return _inList(kList, outToken.toString());
    }

    private boolean isPunctuation() {
        if (outToken.toString().equals("")) return _inList(sList, String.valueOf(ch));
        return _inList(sList, outToken.toString());
    }

    private boolean _inList(List<String> list, String item) {
        boolean flag = false;
        for (String str : list) {
            if (str.equals(item)) flag = true;
        }
        return flag;
    }

    private void backtrack() {
        if (ch != '\0') {
            --bufferPointer;
            --line;
        }
    }

    private boolean isLetter() {
        return Character.isLetter(ch);
    }

    private boolean isDigit() {
        return Character.isDigit(ch);
    }

    private void getChar() {
        if (bufferPointer < inString.length()) {
            ch = inString.charAt(bufferPointer++);
            ++line;
        } else {
            ch = '\0';
        }
    }

    private boolean isSpace() {
        return ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r';
    }

    private void handleSpace() {
        while (isSpace()) {
            if (ch == '\n') {
                ++row;
                line = 1;
            }
            if (ch == '\r') {
                line = 1;
            }
            getChar();
        }
    }

    private Type getPunctuationType() {
        int i = 0;
        for (; i < s.length; ++i) {
            if (outToken.toString().equals(s[i])) break;
        }
        if (i < 6) return Type.SEPARATOR;
        if (i < 10) return Type.ARITHMETIC_OP;
        return Type.RELATIONAL_OP;
    }

    private void log(Type type) {
        String str1 = outToken.toString();
        String str2;
        if (type == Type.ERROR) str2 = "ERROR";
        else str2 = String.format("(%d, %s)", type.ordinal(), str1);
        String str3 = type.toString();
        int _line = line - str1.length();
        String str4 = String.format("(%d, %d)", row, _line);

        System.out.println(_format(str1, str2, str3, str4));
        outToken.delete(0, outToken.length());
    }

    private String _format(String ...strings) {
        StringBuilder sb = new StringBuilder();
        for (String str : strings) sb.append(String.format("%16s", str));
        return sb.toString();
    }
}
