#ifndef _FUNCS_H_
#define _FUNCS_H_

#include "CLASSES.H"
#include <stdio.h>

int Build_Node(FILE* file, Graph** gr);
char* Get_Lexema(FILE* fin);

Trace* do_Circle(Graph* graph, Node* from, Node* to);
Trace* do_Way(Graph* graph, Node* from, Node* to);
Traces* do_Way_Z(Graph* graph, Node* from, Node* to);


#endif
