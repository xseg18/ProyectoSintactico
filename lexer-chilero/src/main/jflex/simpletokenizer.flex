package gt.edu.url.compiler;

import java_cup.runtime.Symbol;

%%

%{

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int counter = 0;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{

%init}

%eofval{
//switch de estados y si encuentra EOf en alguno de ellos
    switch(zzLexicalState) {
        case String:
        //retorno al estado inicial para que no se encicle
        yybegin(YYINITIAL);
        //no se cerraron las comillas en string
        return new Symbol(TokenConstants.ERROR, "EOF in string constant");
        case StringRecover:
        //retorno al estado inicial para que no se encicle
        yybegin(YYINITIAL);
        //no se cerraron las comillas en string (estado error)
        return new Symbol(TokenConstants.ERROR, "EOF in string constant");
        case CommentP:
        //retorno al estado incial para que no se encicle
        yybegin(YYINITIAL);
        //no se cerraron los parentesis de comentario
        return new Symbol(TokenConstants.ERROR, "EOF in comment");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup
//reglas
digit = [0-9]
ucase = [A-Z]
lcase = [a-z]
whitespace = [ \t\f]
newline =(\n\r|\r\n|\n|\r)


//estados adicionales
%state String, CommentP, CommentM, StringRecover
//string <= estado cuando encuentra un "
//CommentP <= Comentarios con parentesis
//CommentM <= comentarios con --
//StringRecover <= estado de recuperación para error en string
%%
<YYINITIAL>
{
//ignora espacios en blanco
    {whitespace}   {}
//nuevalinea
    {newline}      {curr_lineno++;}
//palabras reservadas
    [Cc][Ll][Aa][Ss]([eEsS])          {return new Symbol(TokenConstants.CLASS);}
    [Ii][Nn][Hh][Ee][Rr][iI][Tt][Ss]|
    [Hh][Ee][Rr][eE][dD][aA]  {return new Symbol(TokenConstants.INHERITS);}
    [Ii][Ff]|[Ss][Ii]  {return new Symbol(TokenConstants.IF);}
    [tT][Hh][Ee][Nn]|
    [Ee][Nn][Tt][Oo][Nn][Cc][Ee][Ss]  {return new Symbol(TokenConstants.THEN);}
    [Ee][lL][Ss][Ee]|
    [Dd][Ee][Ll][Oo][Cc][Oo][Nn][Tt][Rr][Aa][Rr][Ii][Oo] {return new Symbol(TokenConstants.ELSE);}
    [Ww][hH][Ii][Ll][Ee]|
    [Mm][Ii][Ee][Nn][Tt][Rr][Aa][Ss]	{return new Symbol(TokenConstants.WHILE);}
    [Ll][Oo]{2}[Pp]|[Cc][Ii][Cc][Ll][Oo]   {return new Symbol(TokenConstants.LOOP);}
    [Cc][Aa][Ss][Ee]|
    [Ee][Nn][Cc][Aa][Ss][Oo]  {return new Symbol(TokenConstants.CASE);}
    [Nn]([Oo][Tt]|[Ee][Ll])   {return new Symbol(TokenConstants.NOT);}
    [pp][Oo]{2}[Ll]|
    [Oo][Ll][Cc][iI][Cc]     {return new Symbol(TokenConstants.POOL);}
    [Ff][Ii]|[Ii][Ss]        {return new Symbol(TokenConstants.FI);}
    [Ee][Ss][Aa][Cc]|[Oo][Ss][Aa][Cc][Nn][Ee]  {return new Symbol(TokenConstants.ESAC);}
    [IiEe][Nn]        {return new Symbol(TokenConstants.IN);}
    [Oo][Ff]|[Dd][Ee]      {return new Symbol(TokenConstants.OF);}
    [Nn](([Ee][Ww])|([Uu][Ee][Vv][oO]))   {return new Symbol(TokenConstants.NEW);}
    [Ii][Ss][Vv][Oo][Ii][dD]|
    [Ee][Ss][Vv][aA][Cc][Ii][Oo] {return new Symbol(TokenConstants.ISVOID);}
    [Ll](([Ee][Tt])|([Aa][Vv][Aa][Rr])) {return new Symbol(TokenConstants.LET);}
//operadores
    "<-"     {return new Symbol(TokenConstants.ASSIGN);}
    "*"      {return new Symbol(TokenConstants.MULT);}
    "("      {return new Symbol(TokenConstants.LPAREN);}
    ")"      {return new Symbol(TokenConstants.RPAREN);}
    ";"      {return new Symbol(TokenConstants.SEMI);}
    "-"      {return new Symbol(TokenConstants.MINUS);}
    "<"      {return new Symbol(TokenConstants.LT);}
    ","      {return new Symbol(TokenConstants.COMMA);}
    "/"      {return new Symbol(TokenConstants.DIV);}
    "+"      {return new Symbol(TokenConstants.PLUS);}
    "."      {return new Symbol(TokenConstants.DOT);}
    "<="     {return new Symbol(TokenConstants.LE);}
    "="      {return new Symbol(TokenConstants.EQ);}
    ":"      {return new Symbol(TokenConstants.COLON);}
    "~"      {return new Symbol(TokenConstants.NEG);}
    "{"      {return new Symbol(TokenConstants.LBRACE);}
    "=>"     {return new Symbol(TokenConstants.DARROW);}
    "}"      {return new Symbol(TokenConstants.RBRACE);}
    "@"      {return new Symbol(TokenConstants.AT);}
//CONSTANTES
    t[Rr][Uu][Ee]|
    v[Ee][Rr][Dd][Aa][Dd][Ee][Rr][Oo]       {return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.TRUE);}
    f[Aa][Ll][Ss][EeOo]                     {return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.FALSE);}
    {digit}+                                {return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addInt(Integer.parseInt(yytext())));}
    {ucase}({lcase}|{ucase}|{digit}|_)*     {return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext()));}
    {lcase}({lcase}|{ucase}|{digit}|_)*     {return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext()));}
    \"                                      {string_buf.setLength(0); yybegin(String);}
 //comentarios
    "--"          {yybegin(CommentM);}
    "(*"           {counter=1; yybegin(CommentP);}
 //todos los comentarios se cierran en el estado COmmentP, si encuentra uno afuera, tira error
    "*)"          {return new Symbol(TokenConstants.ERROR, "Unmatched parenthesis");}
//todos los demás, error
    [^]              {return new Symbol(TokenConstants.ERROR, yytext());}
}
//estado string con nulo
<String>\0000 {
    yybegin(StringRecover);
    return new Symbol(TokenConstants.ERROR, "String contains null character");
}
//estado string con comillas
<String>\" {
    yybegin(YYINITIAL);
    return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString()));
}
//estado string con enter
<String>\n {
   curr_lineno++;
   yybegin(YYINITIAL);
   return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
}
//estado string con escape enter
<String>\\\n {
    curr_lineno++;
    string_buf.append(yytext().substring(1,yytext().length()));
}
//todo lo demás
<String>
{
    \\n     {string_buf.append('\n');}
    \\t     {string_buf.append('\t');}
    \\r     {string_buf.append('\r');}
    \\f     {string_buf.append('\f');}
    \\b     {string_buf.append('\b');}
    \\.     {string_buf.append(yytext().substring(1,yytext().length()));}
    //cualquier caracter válido dentro de la cadena
     [^]     {if(string_buf.length() <= MAX_STR_CONST) {string_buf.append(yytext());}
             else {yybegin(StringRecover); return new Symbol(TokenConstants.ERROR, "String constant too long");}}
}
<CommentP>{
//si encuentra un cierre de parentesis y el numero es par regresa al estado incial
    "*)"                                 {counter++; if(counter % 2 == 0) yybegin(YYINITIAL);}
//si encuentra parentesis que abre suma un parentesis más
    "(*"                                 {counter++;}
//suma nueva linea
     {newline}                           {curr_lineno++;}
//cualquier caracter no se registra
    [^]                                  {}
}
<CommentM>
{
//nueva linea acaba el comentario y suma la linea
    {newline}     {curr_lineno++; yybegin(YYINITIAL);}
//cualquier caracter no se registra
    [^]         {}
}
//recuperación de errores dentro de string
<StringRecover>{
//si encuentra enter se recupera, se suma la linea y regresa al estado inicial
    \n                                  {curr_lineno++; yybegin(YYINITIAL);}
//si encuentra comillas, se recupera y regresa al estado inicial
    \"                                  {yybegin(YYINITIAL);}
//si encuentra un escaped enter solo suma la linea
    \\\n                                {curr_lineno++;}
//cualquier cosa no la registra
    .                                   {}
}
//cualquier cosa que no entre en lo anterior, error
    [^]          {return new Symbol(TokenConstants.ERROR, yytext());}