#include "FUNCS.H"
#include "CLASSES.H"

#include <string.h>
#include <ctype.h>
#include <stdio.h>


#define ZERO '\0'

//static char* _Nodes_ = "Nodes\0";
//static char* _Top_ = "Top\0";
//static char* _Arcs_ = "Arcs\0";
//static char* _Arc_ = "arc\0";

void Unget_Lexema(char* lex, FILE* fin)
{
  ungetc(' ', fin);
  for (int i = strlen(lex); i > 0; i--)
    ungetc(lex[i-1], fin);
}


int readch( FILE* fin, int& ch)
{
  ch = fgetc(fin);
  if (ch != EOF )
     return 1;
  else
     return 0;
};

int isseparator(int c)
{
int separators[] = {'\n','\r','\t',255,' ',ZERO}; // zero character must be the last in list
int i = 0;

   while (separators[i] != ZERO){
        if (separators[i] == c)
           return 1;
        i++;
   }

   return 0;
};

int iscontrol(int c)
{
int controls[] = {';',',','{','}','(',')',ZERO};// zero character must be the last in list
int i = 0;

   while (controls[i] != ZERO){
        if (controls[i] == c)
           return 1;
        i++;
   }

   return 0;
};

inline int _isalpha(int c)
{
	return (isalpha(c)||((char)c == '_'));
};

char* Get_Lexema(FILE* fin)
{
int Lex_Is_Ready = 0;
char* Lexema = NULL;
int ch;
int s = 0;

 while (!Lex_Is_Ready){
	if  (readch(fin, ch)){
    if (isseparator(ch)){
      while((s = readch(fin, ch))&&isseparator(ch));
      if (s)
      	ungetc(ch, fin);
    }
    else{
      Lexema = new char[33];
      Lexema[0] = ZERO;

     	if (iscontrol(ch)){
        Lexema[0] = (char)ch;
        Lexema[1] = ZERO;
        Lex_Is_Ready = 1;
      }
      else{
        while(_isalpha(ch)||isdigit(ch)){
           int l = strlen(Lexema);
           Lexema[l] = (char)ch;
           Lexema[l+1] = ZERO;
           readch(fin, ch);
        }
        Lex_Is_Ready = 1;
        ungetc(ch, fin);
      }
    }
   }
   else
   	Lex_Is_Ready = 1;
 } //while

 return Lexema;
};

int Build_Graph(FILE* fin, Graph** graph)
{
	 int error = 0;
   char *Lex = NULL;

   char* Node_Name_From = new char[33];
   char* Node_Name_To = new char[33];

   Node* Node_From = NULL;
   Node* Node_To = NULL;

//   Graph* graph = new Graph;
	(*graph) = new Graph;

   Lex = Get_Lexema(fin); //Nodes
 	 Lex = Get_Lexema(fin);//{
	 Lex = Get_Lexema(fin); //First node in list

  while(strcmp(Lex, "}\0")!=0){
     if (strcmp(Lex, ",\0")!=0)
        (*graph)->Add_Node(Lex);
     Lex = Get_Lexema(fin);
    }

   Lex = Get_Lexema(fin); //Top
   Lex = Get_Lexema(fin); //{
   Lex = Get_Lexema(fin); //top of the graph

   if ((*graph)->Find_Node(Lex)){
      (*graph)->Top = (*graph)->Find_Node(Lex);
      Lex = Get_Lexema(fin);
		}
    else{
      error = 1;//Unknown_Node;
      return error;
   }

   Lex = Get_Lexema(fin); //Last
   Lex = Get_Lexema(fin); //{
   Lex = Get_Lexema(fin); //end of the graph

   if ((*graph)->Find_Node(Lex)){
      (*graph)->End = (*graph)->Find_Node(Lex);
      Lex = Get_Lexema(fin);
		}
    else{
      error = 1;//Unknown_Node;
      return error;
   }

   Lex = Get_Lexema(fin); //Arcs
   Lex = Get_Lexema(fin); //{
   Lex = Get_Lexema(fin);

   while((strcmp(Lex, "}\0")!=0)&&!error){
      Node_Name_From[0] = ZERO;
      Node_Name_To[0] = ZERO;
      Lex = Get_Lexema(fin); //(
      Node_Name_From = Get_Lexema(fin);
      if ((Node_From = (*graph)->Find_Node(Node_Name_From))){
         Lex = Get_Lexema(fin); //,
         Node_Name_To = Get_Lexema(fin);
         if ((Node_To = (*graph)->Find_Node(Node_Name_To))){
          Node_From->Add_Node(Node_To);
            Lex = Get_Lexema(fin); //)
            Lex = Get_Lexema(fin);  //;
            if (!strcmp(Lex, ";\0")){
               Lex = Get_Lexema(fin);
             }
         }
         else{
           error = 1;//Unknown_Node;
           return error;
         }
      }
      else{
        error = 1;//Unknown_Node;
        return error;
      }
    }

    (*graph)->Detect_Circle((*graph)->Top, NULL);

  return error;
};

Trace* do_Circle(Graph* graph, Node* from, Node* to)
{
Trace* way = new Trace;
unsigned save = from->Count_Arcs;
Node* tmp = NULL;

  if (from != to){
  		from->Count_Arcs = 0;
      from->Mark_Node();
         do{
            way->Cat(do_Way(graph, to, from));
            tmp = to->Find_Not_Marked_Node();
          }
         while(tmp);
         from->UnMark_Node();
         from->Count_Arcs = save;
   }
   else{
   	way->Append(to);
   }
      //add Node to Way
return way;
};


Trace* do_Way(Graph* graph, Node* from, Node* to)
{
	Arc* t = NULL;
   Node* tt = NULL;
   Trace* way = new Trace;
   int Circle = 0;

  if (from != to){

     if((t = from->Find_Circle_Arc()))
     {
     	 if (!t->Mark){
         if (from != t->node)
			   way->Append(from);
	         t->Mark = 1;
   	  		way->Cat(do_Circle(graph, from, t->node));
            Circle = 1;
       }
     };//*/
     //add
     if (t = from->Find_Not_Marked_Arc()){
     	 t->Mark = Marked;
       if (!Circle)
			 way->Append(from);

       if (!(from->Find_Not_Marked_Arc())){
         from->Mark_Node();
       };

     	 way->Cat(do_Way(graph, t->node, to));
     }
     else{
        // find not marked node
       tt = from->Find_Not_Marked_Node();
       if (tt){
           if (from != tt){
		         graph->Reset_Length();
	            way->Cat(graph->Short_Way(from, tt));
           }
           if (tt != to){
            way->Delete_Node(tt);
            way->Cat(do_Way(graph, tt, to));
           }
       }
       else{
	  graph->Reset_Length();
          way->Cat(graph->Short_Way(from, to));
       }
     }
   }
   else{
   	way->Append(to);
   }

return way;
};

Traces* do_Way_Z(Graph* graph, Node* from, Node* to)
{
	Traces* t = NULL;
   Node* tt = NULL;
   Trace* way = new Trace;
   Traces* ways = new Traces;


  if (from != to){
  	if (!from->Mark){
		for (int i = 1; i <= from->Count_Arcs; i++){
       if (!from->Get_Arc(i)->Circle){
          tt = from->Get_Arc(i)->node;
          t = do_Way_Z(graph, tt, to);
          if (!t->Reset()){
             do {
                 Trace* w = new Trace;
                 w->Append(from);
                 w->Cat(t->Item()->Item);
                 ways->Append(w);
             }while (!t->Next());
          }
     	} //for
      from->Mark_Node();
     } //if
   }//if
	else{
       graph->Reset_Length();
		 way->Cat(graph->Short_Way(from, to));
		 ways->Append(way);
	}
  }
  else{
     way->Append(from);
     ways->Append(way);
  }

return ways;
};



