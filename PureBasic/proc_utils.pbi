Procedure toLittleInd32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]
  !bswap eax
  !mov [rsi],eax
  !bswap ecx
  !mov [rsi+4],ecx  
EndProcedure

Procedure toLittleInd32_64(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]
  !bswap eax
  !mov [rsi+4],eax
  !bswap ecx
  !mov [rsi],ecx  
EndProcedure

Procedure.s commpressed2uncomressedPub(ha$)
  Protected y_parity, ruc$, x$, a$, *a, *res
  Shared *CurveP
  *a = AllocateMemory(64)  
  *res=*a + 32  
  
  y_parity = Val(Left(ha$,2))-2
  x$ = Right(ha$,Len(ha$)-2)
  
  a$=RSet(x$, 64,"0")
  Curve::m_sethex32(*a, @a$)  
  Curve::m_YfromX64(*res,*a, *CurveP)  
  
  If PeekB(*res)&1<>y_parity
    Curve::m_subModX64(*res,*CurveP,*res,*CurveP)
  EndIf
  
  ruc$ = Curve::m_gethex32(*res)
  
  FreeMemory(*a)
  ProcedureReturn x$+ruc$

EndProcedure

Procedure.s uncomressed2commpressedPub(ha$)
  Protected Str1.s, Str2.s, x$,y$,ru$,rc$
  ha$=LCase(ha$)
  If Left(ha$,2)="04"
    ha$=Right(ha$,Len(ha$)-2)
  EndIf
  Str1=Left(ha$,64)
  Str2=Right(ha$,64)
  Debug Str1
  Debug Str2
  
  x$=PeekS(@Str1,-1,#PB_Ascii)
  x$=RSet(x$,64,"0")
  y$=PeekS(@Str2,-1,#PB_Ascii)
  y$=RSet(y$,64,"0")
  ru$="04"+x$+y$
  If FindString("13579bdf",Right(y$,1))>0
    rc$="03"+x$
  Else
    rc$="02"+x$
  EndIf
  
  ProcedureReturn rc$

EndProcedure

Procedure Log2(Quad.q)
Protected Result
   While Quad <> 0
      Result + 1
      Quad>>1
   Wend
   ProcedureReturn Result-1
 EndProcedure

Procedure swap8(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]  
  !mov [rsi+4],eax
  !mov [rsi],ecx  
EndProcedure

Procedure swap32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+24]
  !mov ecx,[rsi+4]
  !mov [rsi+4],eax
  !mov [rsi+24],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+28]
  !mov ecx,[rsi]
  !mov [rsi],eax
  !mov [rsi+28],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+20]
  !mov ecx,[rsi+8]
  !mov [rsi+8],eax
  !mov [rsi+20],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+16]
  !mov ecx,[rsi+12]
  !mov [rsi+12],eax
  !mov [rsi+16],ecx 
EndProcedure

Procedure exit(a$)
  PrintN(a$)
  PrintN(L("press_enter"))
  Input()
  CloseConsole()
  End
EndProcedure

Procedure.s cutHex(a$)
  a$=Trim(UCase(a$)) 
  If Left(a$,2)="0X" 
    a$=Mid(a$,3,Len(a$)-2)
  EndIf 
  If Len(a$)=1
    a$="0"+a$
  EndIf
ProcedureReturn LCase(a$)
EndProcedure

Procedure getprogparam()
  Protected parametrscount, datares$, i, walid
  Shared Defdevice$,  privkey, privkeyend
  Shared threadtotal, blocktotal, pparam, waletcounter,mainpub, HT_POW, pubfile$, recovery, recoveryfilename$, cnttimer, cnttimer2
  parametrscount=CountProgramParameters()
  
  i=0
  While i<parametrscount  
    Select LCase(ProgramParameter(i))
      Case "-h"
        Debug "found -h"
        
           PrintN( "  -t      Number of GPU threads, default "+Str(threadtotal))
           PrintN( "  -b      Number of GPU blocks, default "+Str(blocktotal))
           PrintN( "  -p      Number of pparam, default "+Str(pparam))
           PrintN( "  -d      Select GPU IDs, default "+Defdevice$)
           PrintN( " -pb      Set single uncompressed/compressed pubkey for searching")
           PrintN( " -pk      Range start from , default "+privkey)
           PrintN( " -pke     End range ")
           PrintN( " -w       Set number of baby items 2^")
           PrintN( " -htsz    Set number of HashTable 2^ , default "+Str(HT_POW))
           PrintN( " -infile  Set file with pubkey for searching in uncompressed/compressed  format (search sequential)")
           PrintN( " -wl      Set recovery file from which the state will be loaded")
           PrintN( " -wt      Set timer for autosaving current state, default every "+Str(cnttimer)+" seconds")
           PrintN( " -lang    Select language (EN or PT). E.g. -lang EN")
           End
      
      Case "-wl"
        Debug "found -wl"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          recoveryfilename$ = datares$    
          recovery=1
          PrintN( "  Arquivo de recuperacao de progresso: "+recoveryfilename$)
         EndIf
      Case "-wt"
        Debug "found -wt"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          cnttimer = Val(datares$)
          If cnttimer<30
            cnttimer=30
          EndIf
          ;PrintN( "  Saving timer every "+Str(cnttimer)+" segundos")
        EndIf 
      Case "-r"
        Debug "found -r"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          cnttimer2 = Val(datares$)
          ;PrintN( "  Saving timer every "+Str(cnttimer)+" segundos")
         EndIf   
      Case "-infile"
        Debug "found -infile"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          pubfile$=datares$         
          PrintN( "  Arquivo de pubkeys utilizado: "+pubfile$)
        EndIf
      Case "-t"
        Debug "found -t"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          threadtotal=Val(datares$)
           Print("  Collider                         : ") : ConsoleColor(10, 0) : PrintN(#appver) : ConsoleColor(7, 0)
           ConsoleColor(15, 0)
           ;Print("  GPU threads   : ") : ConsoleColor(10, 0) : PrintN(threadtotal) : ConsoleColor(7, 0)
        EndIf
      Case "-b"
        Debug "found -b"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          blocktotal=Val(datares$)          
          ;Print("  GPU blocks    : ") : ConsoleColor(10, 0) : PrintN(blocktotal) : ConsoleColor(7, 0)
        EndIf
      Case "-p"
        Debug "found -p"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          pparam=Val(datares$)          
          ;Print("  Pparam        : ") : ConsoleColor(10, 0) : PrintN(pparam) : ConsoleColor(7, 0)
        EndIf  
      Case "-d"
        Debug "found -d"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          Defdevice$=datares$
          PrintN( "  Placas de Video GPU Utilizadas: "+Defdevice$)
        EndIf
        
      Case "-pb"
        Debug "found -pb"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          mainpub=LCase(cutHex(datares$))
          ;PrintN( "  Pubkey set to "+mainpub)
          walid + 1
        EndIf
              
       Case "-pk"
        Debug "found -pk"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          privkey=LCase(cutHex(datares$))
          ;PrintN( "  Range begin: "+privkey)         
        EndIf 
        
       Case "-pke"
        Debug "found -pke"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          privkeyend=LCase(cutHex(datares$))
          ;PrintN( "  Range end: "+privkeyend)         
        EndIf  
        
       Case "-w"
        Debug "found -w"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          waletcounter=Int(Pow(2, Val(datares$)))
          ;PrintN( "  Items number set to 2^"+Str(Val(datares$)))
        EndIf 
        
       Case "-htsz"
        Debug "found -htsz"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          HT_POW=Val(datares$)
          ;PrintN( "  HT size number set to 2^"+HT_POW) 
        EndIf 
        
      Case "-lang"
        i+1
        
      Default
        exit("  Unknown parameter ["+ProgramParameter(i)+"]")
    EndSelect
    
    


    i+1 
  Wend
EndProcedure

Procedure prntarr(initstr$,*arr, linestotal, lenbytes=32)
  Protected resser.s=Space(lenbytes*4)
  Protected i
  PrintN("**************")
  For i = 0 To linestotal-1
    serialize(*arr+i*lenbytes,0,@resser,lenbytes/2)
    PrintN(initstr$+"["+Str(i)+"]"+PeekS(@resser,lenbytes*2))
  Next i
  PrintN("")
EndProcedure

Procedure.s m_gethex8(*bin)  
  Protected *sertemp=AllocateMemory(16, #PB_Memory_NoClear)
  Protected res$  
  ;************************************************************************
  ;Convert bytes in LITTLE indian format to HEX string in BIG indian format
  ;************************************************************************ 
  Curve::m_serializeX64(*bin,0,*sertemp,2)  
  res$=PeekS(*sertemp,16, #PB_Ascii)
  FreeMemory(*sertemp)
ProcedureReturn res$
EndProcedure

Procedure prntarrBIG(*arr, linestotal, offset=96)
  
  Protected i
  
  For i = 0 To linestotal-1
    
    PrintN("["+Str(i)+"]"+Curve::m_gethex32(*arr+i*offset))
  Next i
  PrintN("")
EndProcedure

Procedure findMinMax8(*arr,totallines, *min,*max)
  Protected i,rescmp, err, len=8
  
  CopyMemory(*arr, *min, len)
  FillMemory(*max, len)
  
  For i=1 To totallines-1
    ;0 - s = t, 1- s < t, 2- s > t
    ;PrintN("0x"+getStrfrombin(*arr+i*len))
    
    ;get min
    rescmp = m_check_less_more_equilX8(*arr+i*len,*min)
    ;PrintN("rescmp:"+Str(rescmp))
    If rescmp=1;less
      CopyMemory(*arr+i*len, *min, len)    
    ElseIf rescmp=0
      err=1
      Break
    EndIf
    
    ;get max
    rescmp = m_check_less_more_equilX8(*arr+i*len,*max)
    ;PrintN("rescmp:"+Str(rescmp))
    If rescmp=2;more
      CopyMemory(*arr+i*len, *max, len)
    ElseIf rescmp=0
      err=1
      Break
    EndIf
    
      
  Next i
  If err
    PrintN("Warning!!!") 
  EndIf    
EndProcedure

Procedure foundinarr8(*findvalue, *arr, beginrange, endrange, *res.comparsationStructure)
  Protected temp_beginrange, temp_endrange, rescmp,   exit.b, center
 
  
  temp_beginrange = beginrange
  temp_endrange = endrange

  While (endrange-beginrange)>=0
    If beginrange=endrange
      If endrange<=temp_endrange
        ;0 - s = t, 1- s < t, 2- s > t        
        rescmp = m_check_less_more_equilX8(*findvalue,*arr+beginrange*8)        
        If rescmp=2;more
          *res\pos=-1
          *res\direction=endrange+1
          exit=1
          Break
        ElseIf rescmp=1;less
          If endrange>0
            *res\pos=-1
            *res\direction=endrange
            exit=1
            Break
          Else
            *res\pos=-1
            *res\direction=0
            exit=1
            Break
          EndIf
        Else;equil
         
          *res\pos=beginrange
          *res\direction=0
          exit=1
          Break
        EndIf
      Else
        exit("Unknown exeptions")
      EndIf
    EndIf
    center=(endrange-beginrange)/2+beginrange    
    rescmp = m_check_less_more_equilX8(*findvalue,*arr+center*8)
    If rescmp=2;more
      If (center+1)<=endrange:
        beginrange=center+1
      Else
        beginrange=endrange
      EndIf
    ElseIf rescmp=1;less
      If (center-1)>=beginrange:
        endrange=center-1
      Else
        endrange=beginrange
      EndIf
    Else;equil
      *res\pos=center
      *res\direction=0
      exit=1
      Break
    EndIf
  Wend
  If exit=0
    If beginrange=temp_endrange:
        *res\pos=-1
        *res\direction=1 
    Else
        *res\pos=-1
        *res\direction=-1
    EndIf
  EndIf
EndProcedure

 Procedure isInRange8(*arr,*min,*max)
  Protected rescmp, result
  rescmp = m_check_less_more_equilX8(*arr,*min)   
  If rescmp=2 Or rescmp=0;>=MIN
    rescmp = m_check_less_more_equilX8(*arr,*max)   
    If rescmp=1 Or rescmp=0;<=MAX
      result=1    
    EndIf      
  EndIf
ProcedureReturn result  
EndProcedure

Procedure Writeint(*Aptr, idx.i, blockDim.w, threadDim.w,  *targPtr)
  Protected *initAptr, threadIdx, blockIdx.i = 0, threadtotal.i, base.i, threadId.i, index.i, threadtotal64.i, temp.i
  Shared pparam
  ; ЭТО ПРАВИЛЬНЫЙ ВАРИАНТ
  ;PrintN("IDX:"+Str(idx))
  
  *initAptr = *Aptr
  
  blockIdx = idx / (threadDim*pparam)
  threadIdx = (idx -blockIdx * threadDim*pparam)/pparam
  
  idx = idx - (threadIdx * pparam + blockIdx*threadDim*pparam)
  
  ;PrintN( "ThreadID>"+Str(threadIdx))
  ;PrintN( "BlockID>"+Str(blockIdx))
  ;PrintN("idx local for thread>"+Str(idx))
 
 threadtotal.i = threadDim * blockDim
 base.i = idx *  threadtotal * 8
 
 threadId.i = threadIdx
 temp.i = blockIdx * threadDim 
 threadId.i = temp.i + threadId 
 
 index.i = base + threadId
 ;Debug "index: "+Str(index) 
 threadtotal64.i = index * 4
 
 
 *Aptr = *Aptr + threadtotal64
 
 threadtotal64.i = threadtotal * 4
 
 CopyMemory(*targPtr, *Aptr, 4)
 
 ;Debug "[0] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+4, *Aptr, 4)
 ;Debug "[1] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+8, *Aptr, 4)
 ;Debug "[2] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+12, *Aptr, 4)
 ;Debug "[3] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+16, *Aptr, 4)
 ;Debug "[4] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+20, *Aptr, 4)
 ;Debug "[5] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+24, *Aptr, 4)
 ;Debug "[6] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 *Aptr = *Aptr + threadtotal64
 
 
 CopyMemory(*targPtr+28, *Aptr, 4)
 ;Debug "[7] offest:"+Str(*Aptr-*initAptr)+" "+Hex(PeekL(*Aptr))
 ;Debug "-------------"
EndProcedure

Procedure.s getStrfrombin(*pointlocation,lenbytes=32)
  Protected resser.s=Space(lenbytes*4)
  serialize(*pointlocation,0,@resser,lenbytes/2)
  ProcedureReturn PeekS(@resser,lenbytes*2)
EndProcedure

Procedure FilePutContents(filename.s, *mem, size)
 Protected f,res,r
  f=CreateFile(#PB_Any,filename)

  If f    
    res=WriteData(f,*mem,size)
    CloseFile(f)    
    If res=size
      r=1
    Else
      r=0
    EndIf    
  EndIf
  ProcedureReturn r
EndProcedure

Procedure saveCurentCNT(gpcount)
  Protected lastsavigdate = Date(), i, mincntpos=0, a$
  Shared globalquit, JobMutex, cnttimer, *GlobCnt, listpos, mainpub, settingsFingerPrint$
  
  Repeat
    If Date() - lastsavigdate>cnttimer
      LockMutex(JobMutex)
      For i = 0 To gpcount-1
        ;PrintN("["+Str(i)+"] "+Curve::m_gethex32(*GlobCnt + i*40))
        If Curve::m_check_less_more_equilX64(*GlobCnt + i*40, *GlobCnt + mincntpos*40)=1 ;less
          mincntpos = i
        EndIf        
      Next i
      ;PrintN(">"+Str(mincntpos))
      a$  = Curve::m_gethex32(*GlobCnt + mincntpos*40)
      UnlockMutex(JobMutex)
      If CreateFile(1, "currentwork.txt",#PB_File_NoBuffering)       
        WriteStringN(1,Str(listpos))  
        WriteStringN(1,mainpub)
        WriteStringN(1,a$) 
        WriteStringN(1,settingsFingerPrint$)         
        CloseFile(1)                      
      Else
        ;exit("Nao foi possivel criar o arquivo!")
      EndIf
      lastsavigdate = Date()
    EndIf
    Delay(5000)
  Until globalquit
EndProcedure

Procedure ErrorHandler()
  Protected ErrorMessage$
  
  ErrorMessage$ = "A program error was detected:" + Chr(13) 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
  ErrorMessage$ + "Error Code:      " + Str(ErrorCode())    + Chr(13)  
  ErrorMessage$ + "Code Address:    " + Str(ErrorAddress()) + Chr(13)
 
  If ErrorCode() = #PB_OnError_InvalidMemory   
    ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
  EndIf
 
  If ErrorLine() = -1
    ErrorMessage$ + "Sourcecode line: Enable OnError lines support to get code line information." + Chr(13)
  Else
    ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
    ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
  EndIf
 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Register content:" + Chr(13)
 
  CompilerSelect #PB_Compiler_Processor 
    CompilerCase #PB_Processor_x86
      ErrorMessage$ + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
      ErrorMessage$ + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
      ErrorMessage$ + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
      ErrorMessage$ + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
      ErrorMessage$ + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
      ErrorMessage$ + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
      ErrorMessage$ + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
      ErrorMessage$ + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
 
    CompilerCase #PB_Processor_x64
      ErrorMessage$ + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
      ErrorMessage$ + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
      ErrorMessage$ + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
      ErrorMessage$ + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
      ErrorMessage$ + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
      ErrorMessage$ + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
      ErrorMessage$ + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
      ErrorMessage$ + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
      ErrorMessage$ + "Display of registers R8-R15 skipped."         + Chr(13)
 
    CompilerCase #PB_Processor_PowerPC
      ErrorMessage$ + "r0 = " + Str(ErrorRegister(#PB_OnError_r0)) + Chr(13)
      ErrorMessage$ + "r1 = " + Str(ErrorRegister(#PB_OnError_r1)) + Chr(13)
      ErrorMessage$ + "r2 = " + Str(ErrorRegister(#PB_OnError_r2)) + Chr(13)
      ErrorMessage$ + "r3 = " + Str(ErrorRegister(#PB_OnError_r3)) + Chr(13)
      ErrorMessage$ + "r4 = " + Str(ErrorRegister(#PB_OnError_r4)) + Chr(13)
      ErrorMessage$ + "r5 = " + Str(ErrorRegister(#PB_OnError_r5)) + Chr(13)
      ErrorMessage$ + "r6 = " + Str(ErrorRegister(#PB_OnError_r6)) + Chr(13)
      ErrorMessage$ + "r7 = " + Str(ErrorRegister(#PB_OnError_r7)) + Chr(13)
      ErrorMessage$ + "Display of registers r8-R31 skipped."       + Chr(13)
 
  CompilerEndSelect  
  
  
   If  CreateFile(#LOGFILE, FormatDate("%dd_%mm-%hh_%ii_%ss ", Date())+"_error_log.txt",#PB_File_SharedRead )
     WriteStringN(#LOGFILE,FormatDate("%dd/%mm/%hh:%ii:%ss:", Date())+ErrorMessage$,#PB_UTF8)
     FlushFileBuffers(#LOGFILE)
     CloseFile(#LOGFILE)
   EndIf
  ;If StratServ        
 ;       CloseNetworkServer(#Server)
  ;EndIf
End
EndProcedure


