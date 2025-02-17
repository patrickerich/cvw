/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *                                                                            
 *  Version:    C, Version 2.1
 *                                                                            
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */

 #include "dhry.h"

 #ifndef REG
 #define REG
 #endif

 /* Global Variables: */
 Rec_Pointer     Ptr_Glob,
                 Next_Ptr_Glob;
 int             Int_Glob;
 Boolean         Bool_Glob;
 char            Ch_1_Glob,
                 Ch_2_Glob;
 int             Arr_1_Glob [50];
 Arr_2_Dim       Arr_2_Glob;
 
 /* variables for time measurement: */
 struct tms      time_info;
 long            Begin_Time,
                 End_Time,
                 Begin_Insn,
                 End_Insn;
 float           Microseconds,
                 Dhrystones_Per_Second;
 
 /* end of variables for time measurement */
 
 int main() {
         One_Fifty       Int_1_Loc;
         One_Fifty       Int_2_Loc;
         One_Fifty       Int_3_Loc;
         char            Ch_Index;
         Enumeration     Enum_Loc;
         Str_30          Str_1_Loc;
         Str_30          Str_2_Loc;
         int             Run_Index;
         int             Number_Of_Runs;
 
         /* Initializations */
         Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
         Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
 
         Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
         Ptr_Glob->Discr                       = Ident_1;
         Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
         Ptr_Glob->variant.var_1.Int_Comp      = 40;
         strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
                 "DHRYSTONE PROGRAM, SOME STRING");
         strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");
 
         Arr_2_Glob [8][7] = 10;
 
         printf ("\n");
         printf ("Dhrystone Benchmark, Version 2.1 (Language: C)\n");
         printf ("\n");
 
         printf ("Please give the number of runs through the benchmark: ");
         {
             int n;
             scanf ("%d", &n);
             Number_Of_Runs = n;
         }
         printf ("\n");
 
         printf ("Execution starts, %d runs through Dhrystone\n", Number_Of_Runs);
 
         /***************/
         /* Start timer */
         /***************/
         times (&time_info);
         Begin_Time = (long) time_info.tms_utime;
         Begin_Insn = (long) time_info.tms_stime;
 
         for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index) {
             Proc_5();
             Proc_4();
             Int_1_Loc = 2;
             Int_2_Loc = 3;
             strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
             Enum_Loc = Ident_2;
             Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
             while (Int_1_Loc < Int_2_Loc) {
                 Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
                 Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
                 Int_1_Loc += 1;
             }
             Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
             Proc_1 (Ptr_Glob);
             for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index) {
                 if (Enum_Loc == Func_1 (Ch_Index, 'C')) {
                     Proc_6 (Ident_1, &Enum_Loc);
                     strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
                     Int_2_Loc = Run_Index;
                     Int_Glob = Run_Index;
                 }
             }
             Int_2_Loc = Int_2_Loc * Int_1_Loc;
             Int_1_Loc = Int_2_Loc / Int_3_Loc;
             Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
             Proc_2 (&Int_1_Loc);
         }
 
         /**************/
         /* Stop timer */
         /**************/
         times (&time_info);
         End_Time = (long) time_info.tms_utime;
         End_Insn = (long) time_info.tms_stime;
 
         printf ("Execution ends\n");
         printf ("\n");
         printf ("Final values of the variables used in the benchmark:\n");
         printf ("\n");
         printf ("Int_Glob:            %d\n", Int_Glob);
         printf ("        should be:   %d\n", 5);
         printf ("Bool_Glob:           %d\n", Bool_Glob);
         printf ("        should be:   %d\n", 1);
         printf ("Ch_1_Glob:           %c\n", Ch_1_Glob);
         printf ("        should be:   %c\n", 'A');
         printf ("Ch_2_Glob:           %c\n", Ch_2_Glob);
         printf ("        should be:   %c\n", 'B');
         printf ("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
         printf ("        should be:   %d\n", 7);
         printf ("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
         printf ("        should be:   Number_Of_Runs + 10\n\n");
         printf ("Ptr_Glob->\n");
         printf ("  Ptr_Comp:          %ld\n", (long) Ptr_Glob->Ptr_Comp);
         printf ("        should be:   (implementation-dependent)\n\n");
         printf ("  Discr:             %d\n", Ptr_Glob->Discr);
         printf ("        should be:   %d\n", 0);
         printf ("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
         printf ("        should be:   %d\n", 2);
         printf ("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
         printf ("        should be:   %d\n", 17);
         printf ("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
         printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n\n");
         printf ("Next_Ptr_Glob->\n");
         printf ("  Ptr_Comp:          %ld\n", (long) Next_Ptr_Glob->Ptr_Comp);
         printf ("        should be:   (implementation-dependent), same as above\n");
         printf ("  Discr:             %d\n", Next_Ptr_Glob->Discr);
         printf ("        should be:   %d\n", 0);
         printf ("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
         printf ("        should be:   %d\n", 1);
         printf ("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
         printf ("        should be:   %d\n", 18);
         printf ("  Str_Comp:          %s\n", Next_Ptr_Glob->variant.var_1.Str_Comp);
         printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n\n");
         printf ("Int_1_Loc:           %d\n", Int_1_Loc);
         printf ("        should be:   %d\n", 5);
         printf ("Int_2_Loc:           %d\n", Int_2_Loc);
         printf ("        should be:   %d\n", 13);
         printf ("Int_3_Loc:           %d\n", Int_3_Loc);
         printf ("        should be:   %d\n", 7);
         printf ("Enum_Loc:            %d\n", Enum_Loc);
         printf ("        should be:   %d\n", 1);
         printf ("Str_1_Loc:           %s\n", Str_1_Loc);
         printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n\n");
         printf ("Str_2_Loc:           %s\n", Str_2_Loc);
         printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n\n");
 
         long long User_Time_LL = End_Time - Begin_Time;
         long long User_Insn_LL = End_Insn - Begin_Insn;
 
         printf("Number_Of_Runs: %d\n", Number_Of_Runs);
         printf("User_Time: %lld cycles, %lld insn\n", User_Time_LL, User_Insn_LL);
 
         float Cycles_Per_Instruction = (float)User_Time_LL / User_Insn_LL;
         printf("Cycles/Instruction: ");
         print_float3(Cycles_Per_Instruction);
         printf("\n");
 
         float Dhrystones_Per_Second_Per_MHz = ((float)Number_Of_Runs * 1000000.0) / User_Time_LL;
         printf("Dhrystones/MHz: ");
         print_float1(Dhrystones_Per_Second_Per_MHz);
         printf("\n");

         float DMIPS_Per_MHz = Dhrystones_Per_Second_Per_MHz / 1757.0;
         printf("DMIPS/MHz: ");
         print_float3(DMIPS_Per_MHz);
         printf("\n");
 }
 
 /* Procedures for the benchmark */

void Proc_1(Rec_Pointer Ptr_Val_Par) {
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;

                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


void Proc_2 (Int_Par_Ref)
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
  One_Fifty  Int_Loc;  
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


void Proc_3 (Ptr_Ref_Par)
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


void Proc_4 () /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


void Proc_5 () /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */
#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif


