%{
        #include<stdio.h>
        #include<string.h>
        void error(char *s);
        typedef struct _token{
            int clase;
            char valor[32];
            int line;
        }token;
        
        token TOKEN;

        enum clase{PR=1, ID, CON, SP, OP };
%}

%option yylineno 
%START COMENTARIO

letra [a-zA-Z]
digito [0-9]
constante (0?|[1-9]{digito}*).{digito}+
id #({letra}|{digito})+
reservadas @(if|else|while)
aritmetico [-+*/%]
relacional ((>=)|(<=)|(==)|(!=)|[<>])
asignacion =
logico ((&&)|("||")|!)
operador {aritmetico}|{logico}|{relacional}|{asignacion}
puntuacion [{}(),;]

%%

<INITIAL>{reservadas} {
        TOKEN.clase = PR;
        strcpy(TOKEN.valor, yytext);
        TOKEN.line = yylineno;
        return PR;
}


<INITIAL>{id} {
       TOKEN.clase = ID;
       strcpy(TOKEN.valor, yytext);
       TOKEN.line = yylineno;
       return ID;
}

<INITIAL>{constante} {
        TOKEN.clase = CON;
        strcpy(TOKEN.valor, yytext);
        TOKEN.line = yylineno;
        return CON;
}

<INITIAL>{puntuacion} {
       TOKEN.clase = SP;
       strcpy(TOKEN.valor, yytext);
       TOKEN.line = yylineno;
       return SP;
}

<INITIAL>{operador} {
       TOKEN.clase = OP;
       strcpy(TOKEN.valor, yytext);
       TOKEN.line = yylineno;
       return OP; 
}

<INITIAL>[ \t\n] {/*Ignora los espacios en blanco*/}

<INITIAL>. {error(yytext);}

<INITIAL>"/*" {BEGIN(COMENTARIO);}

<COMENTARIO>"*/" { BEGIN(INITIAL); }

<COMENTARIO>. {/*Ignora los comentarios*/}

%%

int yywrap(){ return 1;}

void error(char *s){ printf("Error léxico: %s\n",s);} 

int main(int argc, char **argv){
    FILE *f;
    if(argc < 2){
        printf("Falta archivo\n");
        exit(-1);
    }
    f = fopen(argv[1], "r");
    if(!f){
        printf("No se puede abrir el archivo\n");
        exit(-1);
    }
    yyin = f;
    int tok = yylex();
    while(tok != 0){
        printf("%d\n", tok);
        tok = yylex();
    }
    return 0;
}
