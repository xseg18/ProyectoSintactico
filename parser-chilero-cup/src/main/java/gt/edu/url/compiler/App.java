package gt.edu.url.compiler;

import java_cup.runtime.Symbol;

import java.io.InputStreamReader;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main(String[] args) {
        args = Flags.handleFlags(args);
        try {
            CoolTokenLexer lexer = new CoolTokenLexer(new InputStreamReader(System.in));
            CoolParser parser = new CoolParser(lexer);
            Symbol result = (Flags.parser_debug
                    ? parser.debug_parse()
                    : parser.parse());
            if (parser.omerrs > 0) {
                System.err.println("Compilation halted due to lex and parse errors");
                System.exit(1);
            }
            ((Program)result.value).dump_with_types(System.out, 0);
        } catch (Exception ex) {
            ex.printStackTrace(System.err);
            Utilities.fatalError("Unexpected exception in parser");
        }
    }

}
