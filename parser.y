%{
	#include <stdio.h>
	#include <string.h>
	#include <vector>
	#include "varint.h"
	#include "ide.h"
	#include "stdlib.h"
	#include "qvariant.h"
	int line_counter = 1;
	short err = 0;
	short debug = 0;
	long block = 0;
	std::vector< VarInt * > BlockList;
	std::vector< char * > spaces;
	IDE *ide = 0;
	//typedef struct yy_buffer_state * YY_BUFFER_STATE;
void printCurrentSpace();
%}

%union{
	char* str;
	char* space;
	int integer;
}


%token DEFINE
%token AS
%token BLOCKS
%token VALUE_SENTENCE
%token SET
%token OUT
%token FOR
%token GO
%token <str> BACK
%token <str> STRAIGHT
%token TILL
%token TURN
%token LEFT
%token RIGHT
%token KEEP
%token GOING
%token SKIP
%token KEEPEND
%token FOR_CYCLE
%token TIMES
%token LEFT_SQUARE_BRACKED
%token WALK
%token RIGHT_SQUARE_BRACKED
%token FOREND
%token WHEN
%token THEN
%token WHEND
%token START
%token STOP
%token ON
%token REST
%token <integer> VALUE
%token <str> IDENTIFIER
%token <space> WHITE_SPACE
%token DOTCOMA
%token OPERATOR
%token LEFT_BLOCK_BRACKED
%token RIGHT_BLOCK_BRACKED

%token EQUAL
%token NOT_EQUAL
%token HIGH
%token LESS
%token EQUAL_HIGH
%token EQUAL_LESS
%token PRINT
%token <space>EMPTY;
%token END 0 "end of file"

%type <integer> mathematicExpresion
%type <integer> aValue
%type <str> error


%start initial


%%

initial:
	expresion
	| expresion initial
	| END {return 0;}
;

expresion:
	simple_expresion
	| errStatement simple_expresion
	| errStatement DOTCOMA {printDotComma();}
	| FOR_CYCLE {printResevedWord("For");} ForContinue
	| WHEN {printResevedWord("When");} WhenContinue
;



simple_expresion:
	GO {printResevedWord("Go");} GoContinue
	| VALUE_SENTENCE { printResevedWord("Value"); } ValueContinue
	| TURN { printResevedWord("Turn"); } TurnTurnOnContinue
	| START { printResevedWord("Start"); } StartStopContinue
	| STOP { printResevedWord("Stop"); } StartStopContinue
	| REST {printResevedWord("Rest");} RestForContinue
	| DEFINE {printResevedWord("Define");} DefineContinue
	| PRINT {printResevedWord("print");} PrintContinue
;


GoContinue:
	Ydirection DOTCOMA {printDotComma();}
	| Ydirection TILL {printResevedWord("Till");} aValue BLOCKS {printResevedWord("Blocks");}
	DOTCOMA {printDotComma();}
;

ValueContinue:
	mathematicExpresion 
	SET { printResevedWord("set");}
	OUT {printResevedWord("out");}
	FOR {printResevedWord("for");}
 	identif DOTCOMA {printDotComma();}
;

TurnTurnOnContinue:
	turndirection DOTCOMA {printDotComma();}
	| ON {printResevedWord("On");} DOTCOMA {printDotComma();}
;


StartStopContinue:
	DOTCOMA {printDotComma();}
;

RestForContinue:
	FOR {printResevedWord("for");} aValue DOTCOMA {printDotComma();}
;


DefineContinue:
	identif  AS {printResevedWord("as");} BLOCKS {printResevedWord("Blocks");} DOTCOMA {printDotComma();}
;

PrintContinue:
	aValue
;


WhenContinue:
	condition THEN {printResevedWord("Then");}
	LEFT_BLOCK_BRACKED {printOperator('{');}
	initial
	RIGHT_BLOCK_BRACKED {printOperator('}');}
	WHEND {printResevedWord("Whend");} DOTCOMA {printDotComma();}
	
;

ForContinue:
	mathematicExpresion
	TIMES {printResevedWord("Times");}
	LEFT_SQUARE_BRACKED {printOperator('[');}
	WALK {printResevedWord("Walk");} mathematicExpresion identif RIGHT_SQUARE_BRACKED {printOperator(']');}
	LEFT_BLOCK_BRACKED {printOperator('{');}
	initial
	RIGHT_BLOCK_BRACKED {printOperator('}');}
	ForContinue2
;
ForContinue2:
	FOREND {printResevedWord("ForEnd");} DOTCOMA {printDotComma();} 
;


condition:
    aValue comparator aValue
  ;


comparator:
    EQUAL {printOperator('=');}
    | NOT_EQUAL {printOperator('!');printOperator('=');}
    | HIGH {printOperator('>');}
    | LESS {printOperator('<');}
    | EQUAL_HIGH {printOperator('>');printOperator('=');}
    | EQUAL_LESS {printOperator('<');printOperator('=');}
;


errStatement:
 	error
{
	yyerrok;
	printError(yytext);
	QVariant word(yylineno);
	ide->ui->errors->append(QString("[Error type 1]: encontrado ").append(yytext).append( " at line ").append(word.toString()).append("\n"));
	fprintf(stderr,"[Error type 1]: encontrado %s at line %ld \n", yytext,yylineno);
	yyclearin;
}
	| errStatement error
{
	yyerrok;
	QVariant word(yylineno);
	printError(yytext);
	ide->ui->errors->append(QString("[Error type 1]: encontrado ").append(yytext).append( " at line ").append(word.toString()).append("\n"));
	fprintf(stderr,"[Error type n]: encontrado %s at line %ld \n", yytext,yylineno);
	yyclearin;
} 
;







identif:
IDENTIFIER {printIdentifier($1);}
;

mathematicExpresion:
    aValue
    | aValue OPERATOR {printOperator('+');} mathematicExpresion
;

aValue:
    IDENTIFIER 
	{
		printIdentifier($1);
	}

    | VALUE	{printNumberValue($1);}
    ;


Ydirection:
    STRAIGHT {printDirecction("Straight");}
    | BACK	{printf("in Back\n");printDirecction("Back");}
;

turndirection:
    LEFT	{printDirecction("Left");}
    | RIGHT	{printDirecction("Right");}
;


%%

#include "lex.yy.c"
int test(const char *s, IDE * pide){
	line_counter= yylineno = 1;
	printf("Test?\n");
	ide = pide;
	char* ss = (char*)malloc(strlen(s)+1);
	ss[strlen(s)] = '\0';
	strcpy(ss,s);
	printf("file: \n %s\n", ss);
	YY_BUFFER_STATE buffer =yy_scan_string(ss);
	//yyin = fopen(s,"r");
	yyparse();
	//fclose(yyin);
	return 0;
}

void printResevedWord(QString word){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#237355\"><b>").append(word).append("</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);
}

void printCurrentSpace(){
	ide->ui->langu->moveCursor (QTextCursor::End);
	if (spaces.size() > 0){
	ide->ui->langu->insertPlainText(spaces.front());
	free(spaces.front());
	spaces.erase(spaces.begin());
	}
	ide->ui->langu->moveCursor (QTextCursor::End);
}

void printNumberValue(int num){
	QVariant word(num);
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#B7CE06\">").append(word.toString()).append("</font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);

}

void printIdentifier(QString id){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#55aa66\"><b>").append(id).append("</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);

}

void printDirecction(QString dir){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#55aa66\"><b>").append(dir).append("</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);

}

void printError(QString dir){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#FF5555\"><b>").append(dir).append("</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);

}

void printDotComma(){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#FFFFFF\"><b>;</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);
}

void printOperator(char op){
	ide->ui->langu->moveCursor (QTextCursor::End);
	ide->ui->langu->insertHtml (QString("<font color=\"#FFFFFF\"><b>").append(op).append("</b></font>"));
	ide->ui->langu->moveCursor (QTextCursor::End);
}
int yyerror(const char* s ) {
	yyerrok;
	//printError(yytext);
	fprintf(stderr,"%s: %s at line %ld\n", s, yytext,line_counter);
    	yyclearin;
	err = 1;
//	return err;
}
