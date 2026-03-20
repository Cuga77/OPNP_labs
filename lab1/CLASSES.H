#ifndef _CLASSES_H_
#define _CLASSES_H_

#define NotMarked 0
#define Marked 1

#ifndef NULL
#define NULL 0
#endif

//#include "funcs.h"
#include <stdio.h>

struct Arc;//
class Node;//
class Graph;
class Trace;
class Traces;

template <class T>
struct Pointer{
  T* Item;
  Pointer* Next;
  Pointer* Prev;
  Pointer(T* item = NULL)
     {
       Next = NULL;
       Prev = NULL;
       Item = item;
     };
  Pointer(Pointer<T>* p)
     {
       Next = p->Next;
       Prev = p->Prev;
       Item = p->Item;
     };
  ~Pointer()
     {
       Next = NULL;
       Prev = NULL;
       Item = NULL;
     };
};

typedef Pointer<Node> Node_Pointer;

struct Arc{
  Arc* Next;
  Arc* Prev;
  Node* node;
  unsigned Mark;
  unsigned Circle;

  Arc(Node* node);
  Arc();
  ~Arc(){};
};

class Node{
     char* Caption;
     char* Name;
     unsigned Mark;
     unsigned Length;

     Arc* First;
     Arc* Last;
     Arc* Curr_Arc;
     unsigned Curr_Num;
     unsigned Count_Arcs;

     friend Trace* do_Circle(Graph* , Node* , Node* );
     friend Trace* do_Way(Graph* , Node* , Node* );
     friend Traces* do_Way_Z(Graph* graph, Node* from, Node* to);

     friend class Graph;

  public:
     Node(char* name, char* caption = NULL);
     ~Node();

     Arc* Next_Arc();
     Arc* Prev_Arc();
     Arc* Get_Arc(unsigned num);
     Arc* Find_Not_Marked_Arc();
     Arc* Find_Circle_Arc();
     Node* Find_Not_Marked_Node();
     void Reset();

     char* name(){
     	return Name;
     }

     void Add_Node(Node* node);

     void Mark_Node()
     		{Mark = Marked;};
     void UnMark_Node()
     		{Mark = NotMarked;};

     void Mark_Curr_Arc()
     		{Curr_Arc->Mark = Marked;};
     void UnMark_Curr_Arc()
     		{Curr_Arc->Mark = NotMarked;};
     unsigned Arcs()
     		{ return Count_Arcs; };
};

class Graph{
	  Node_Pointer* First;
	  Node_Pointer* Last;

	  Node_Pointer* Way;

	  Node* Top;
     Node* End;

     unsigned Count_Nodes;
     int Find_Node(Node* node, Node_Pointer* way);
     void Detect_Circle(Node* node, Trace* TP);
     void Add_Node(char* name);
     Node* Find_Node(char* name);
     int Stop();
     int Test_Circle(Node* begin, Node* end);
     int Detect_All_Ways(Node* begin, Node* end, Trace* TRACE=NULL);
     Traces* Min_Ways;
     Traces* Z_Ways;
     Traces* Circle_Z_Ways;
     unsigned MMin, MZ;

    friend int Build_Graph(FILE*, Graph**);
    friend Trace* do_Circle(Graph* , Node* , Node* );
    friend Trace* do_Way(Graph* , Node* , Node* );
    friend Traces* do_Way_Z(Graph* graph, Node* from, Node* to);


    public:
           Graph();
           ~Graph();
           int Ways();
           int Z();
           Trace* Short_Way(Node* From, Node* To);
		     void Reset_Length();
           void Reset();
};


class Trace{
   Node_Pointer* Start, * Finish;
   unsigned Counter;
   Node_Pointer* Current;

public:
		Trace();
      ~Trace();
		int Reset();
      Node_Pointer* Item();
		int Next();
      int Prev();
      void Cat(Trace*);
      void Append(Node*);
      void Clear();
      void Print();
      void Delete_Node(Node* node);
      int Belong(Node* node);
      unsigned Count_M();
};

typedef Pointer<Trace> Trace_Pointer;

class Traces{
   Trace_Pointer* First, *Last;
   unsigned Count_Traces;
   Trace_Pointer* Current;

public:
	Traces();
   ~Traces();
   void Append(Trace* trace);
   int Belong(Node* node);
	int Next();
   int Prev();
   int Reset();
   void Clear();
   void Print();
   Trace_Pointer* Item();
   unsigned Count_M();
   void Cat(Traces*); 

};


#endif

