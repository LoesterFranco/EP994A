* Erik Piehl (C) 2017 April
* test9900.asm
*
* Test program sequences to test drive the TMS9900 VHDL core.
*

	IDT 'TEST9900'
WRKSP  EQU >8300
WRKSP2 EQU >8320
    DATA WRKSP,BOOT   * RESET VECTOR
BLWPTEST
    DATA WRKSP2,TEST2
    DATA >BEEF,>BEEF
    DATA 0,0
    DATA 0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0
* Here are the XOP vectors
    DATA WRKSP2,MYXOP0
    DATA WRKSP2,MYXOP1

COCTEST DATA >0040
CZCTEST DATA >F000
    
BOOT
  BLWP @BLWPTEST
  LI  R12,>0240
  SBO 0          * debug marker
  LI  R2,>1
  XOR R12,R2
  COC @COCTEST,R2
  JEQ !
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck
! CZC @CZCTEST,R2
  JEQ !
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck  
!  
  SBO 0
  SBZ 1
  SBO 2
  SBZ -1
  TB  5
  JNE GOODO
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck
GOODO
  LI  R0,>3333
  XOP @>BEEF,0
  LI  R0,>5555
  XOP @>0011,1
* Test LDCR
  LI  R12,>550
  LI  R3,>0055
  LDCR R3,0
  LDCR R3,9
  LDCR R3,3  
  

  LI  R3,>8340    ** write to 8306 data 8340 1000001101000000
  LI  R7,>8350
  LI  R1,>0123
  LI  R2,>4567
  LI  R4,>89AB
  MOV R1,*R3
  MOV R2,@2(R3)
  MOV R4,@4(R3)
  CLR @6(R3)
  MOVB *R3+,*R7+
  MOVB *R3+,*R7+
  MOVB *R3+,*R7+
  MOVB *R3+,*R7+
  MOV  *R3+,*R7+
  MOVB @>8303,@>8350
  LI   R3,>8340
* Test byte operations
  MOVB R4,@>8340
  MOVB R2,@>8341
  MOV  R1,*R3   * Restore
  MOVB R4,*R3
  AB   R1,*R3+
  AB   R1,*R3
  AI   R3,-1
  MOVB *R3+,R1
  MOVB *R3,R1
  DEC  R3
  
  CLR *R3
  LI  R4,>8350
  LI  R2,2
  MOV *R3+,*R4+
  DECT R4
  A   R2,*R4+
  S   R2,@>8350
  CI  R3,>8342
  JEQ GOOD1
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck
GOOD1:
  LI  R1,>4444
  MOV R1,@>8360
  MOV @>8360,@>8350
  C   @>8350,R1
  JEQ GOOD2
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck
GOOD2:  
  LI  R0,>1234
  DATA >0381    ** RTWP but illegal on TMS9995, will get stuck
BACK  
  BL    @SUBROUTINE
  CLR R1
  CLR   @4(R3)
  SETO  @6(R3)
  CLR   @>8348
  SETO  *R3
  CLR   *R3+
  CLR   *R3+
  CLR   *R3+
  NEG R2
  MOV R2,*R3+
  JMP BACK
  NEG R2
  LI R2, >8002
  NEG R2
  NEG R2
  INCT R3
  MOV R3,R5
  INC R5
  DEC R5
  SWPB R5
  INV R5
  SETO *R3
  ABS R5
  NEG R5
  LI  R0,>1234    ** write to 8300 data 1234 0001001000110100
  LI  R1,1        ** write to 8302 data 0001 0000000000000001
  MOV R0,*R3      ** write to 8340 data 1234 0001001000110100
  MOV *R3+,R2     ** write to 8306 data 8342 1000001101000010 
*                 ** write to 8304 data 1234 0001001000110100 
  A   R1,R2       ** write to 8304 data 1235 0001001000110101 
  MOV R2,R8       ** write to 8310 data 1235 0001001000110101 
  MOV R1,*R3      ** write to 8342 data 0001 0000000000000001
  A   R1,*R3      ** write to 8342 data 0002 0000000000000010
  MOV @>4,@>8344
  BL  @SUBROUTINE
  B   @BOOT
  
SUBROUTINE  
  LI  R4,123
  RT

* Thus source modes Rx, *Rx, *Rx+, @addr work
* Destination modes Rx and *Rx work 
*   Also destination mode @addr works for MOV but not other instructions
* First iteration of MOV @>4,@>8344 takes 3375-2915=460ns from iaq to iaq

TEST2
  CKON
  STWP R0
  LI   R2,4
  MOV  R2,R3
  INC  R3
  S    R3,R2
  STST R1
  LI  R0,>0004
  MOV R0,R1
  LI R2,-4
  MOV R0,R3
  LI  R4,-4
  SLA R1,8
  SRA R2,1
  SRC R3,4
  SRL R4,1
  RTWP

MYXOP0
  LI R12,>0100
  STST R1
  SBO 0
  RTWP
MYXOP1
  LI R12,>0100
  STST R1
  SBO 1
  RTWP

  
SLAST  END  BOOT


* TESTED kind of
* NOP, LI, AI, ANDI, ORI
* LWPI
* JMP, JNE, JEQ
* 14.4.2017
* MOV
* A (without flags)

