IncludeFile "globals.pbi"
IncludeFile "language.pbi"
IncludeFile "declares.pbi"
IncludeFile "proc_utils.pbi"
IncludeFile "proc_math_core.pbi"
IncludeFile "proc_hashtable.pbi"
IncludeFile "proc_cuda_driver.pbi"
;-START
InitLanguage()

OnErrorCall(@ErrorHandler())

Define  i, pointcount, ndev, a$, starttime, jobperthread, res, totalCPUcout, restjob, begintime, workingtime, Title$,  result.comparsationStructure, finditems, lastlogtime,totalhash, perf$
Define cnt$, infostr$, hashd.d, hashd2.d, wald.d = Log(waletcounter*2)/Log(2) ;due to use x2GS

begintime=Date()
SetEnvironmentVariable("GPU_FORCE_64BIT_PTR", "0")
SetEnvironmentVariable("GPU_MAX_HEAP_SIZE", "100")
SetEnvironmentVariable("GPU_USE_SYNC_OBJECTS", "1")
SetEnvironmentVariable("GPU_MAX_ALLOC_PERCENT", "100")
SetEnvironmentVariable("GPU_MAX_ALLOC_PERCENT", "100")
usedgpucount = retGPUcount()
If Not usedgpucount
  exit("  CUDA gpu is not present")
EndIf

If waletcounter>=Pow(2,31)
  exit("  -w should be less than 31")
EndIf

If HT_POW>30
  exit("  -htsz should be less than 31")
EndIf

If Int(Log(waletcounter)/Log(2))-HT_POW>2
  PrintN(L("warn_htsz_low")+Str(Int(Log(waletcounter)/Log(2))-2))
EndIf

*CenterBig=AllocateMemory(32)
If *CenterBig=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*CenterX=AllocateMemory(32)
If *CenterX=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*CenterY=AllocateMemory(32)
If *CenterY=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

*GlobKey=AllocateMemory(32)
If *GlobKey=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
GlobPub\x=AllocateMemory(32)
If GlobPub\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
GlobPub\y=AllocateMemory(32)
If GlobPub\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*WINKEY=AllocateMemory(32)
If *WINKEY=0
  PrintN("Nao foi possivel alocar memoria")
  exit("")
EndIf

*WidthRange=AllocateMemory(32)
If *WidthRange=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*PrivBIG=AllocateMemory(32)
*PrivBIG2=AllocateMemory(32)
*PrivBIG3=AllocateMemory(32)
If *PrivBIG=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
PubkeyBIG\x=AllocateMemory(32)
PubkeyBIG\y=AllocateMemory(32)
If PubkeyBIG\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
If PubkeyBIG\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*MaxNonceBIG=AllocateMemory(32)
If *MaxNonceBIG=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
ADDPUBG\x=AllocateMemory(32)
If ADDPUBG\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
ADDPUBG\y=AllocateMemory(32)
If ADDPUBG\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*bufferResult=AllocateMemory(32)
If *bufferResult=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*addX=AllocateMemory(32)
If *addX=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*addY=AllocateMemory(32)
If *addY=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

*PRKADDBIG=AllocateMemory(32)
If *PRKADDBIG=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

PUBADDBIG\x=AllocateMemory(32)
If PUBADDBIG\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
PUBADDBIG\y=AllocateMemory(32)
If PUBADDBIG\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf


FINDPUBG\x=AllocateMemory(32)
If FINDPUBG\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
FINDPUBG\y=AllocateMemory(32)
If FINDPUBG\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

REALPUB\x=AllocateMemory(32)
If REALPUB\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
REALPUB\y=AllocateMemory(32)
If REALPUB\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

Two\x=AllocateMemory(32)
If Two\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
Two\y=AllocateMemory(32)
If Two\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

Curve::m_ADDPTX64(Two\x, Two\y, *CurveGX, *CurveGY, *CurveGX, *CurveGY, *CurveP)

If pparam &1=1
   exit("  vaule -p must be a multiple of 2")
 EndIf
 
 If threadtotal &1=1
   exit("  vaule -t must be a multiple of 2")
 EndIf
 
 If blocktotal &1=1
   exit("  vaule -b must be a multiple of 2")
 EndIf
 
If pubfile$ And FileSize(pubfile$)=-1
  exit("  File["+pubfile$+"] not found!")
EndIf



;generate fingerprint of settings
settingsvalue$ = Str(threadtotal)+Str(blocktotal)+Str(pparam)+Str(waletcounter)+privkey+privkeyend+Str(HT_POW)
settingsFingerPrint$ = SHA1Fingerprint(@settingsvalue$, StringByteLength(settingsvalue$))

;PrintN("  Current config: hash["+settingsFingerPrint$+"]")
If recovery
  If FileSize(recoveryfilename$) = -1
    exit("  Recovery file ["+recoveryfilename$+"] does not exist")    
  EndIf
  If OpenFile(0,recoveryfilename$,#PB_File_NoBuffering)  
    a$=ReadString(0)
    If a$
      recoverypos = Val(a$)
      a$=ReadString(0)
      If a$
        recoverypub$ = a$
        a$=ReadString(0)
        If a$
          recoveryCNT$ = a$
          a$=ReadString(0)
          If a$
            recoveryfingerprint$ = a$
            CloseFile(0)
          Else
            CloseFile(0)
            exit("  Empty line in recovery file")
          EndIf          
        Else
          CloseFile(0)
          exit("  Empty line in recovery file")
        EndIf
      Else
        CloseFile(0)
        exit("  Empty line in recovery file")
      EndIf
    Else
      CloseFile(0)
      exit("  Empty line in recovery file")
    EndIf
    
  Else
     exit("  Can`t open recovery file ["+recoveryfilename$+"]")
   EndIf
    PrintN("  ******Recovery Setttings******")
    PrintN("  Position   ["+Str(recoverypos)+"]")
    PrintN("  Chave Publica ["+recoverypub$+"]")
    PrintN("  CNT        ["+recoveryCNT$+"]")
    PrintN("  Config hash["+recoveryfingerprint$+"]")
    PrintN("  ******************************")
    If recoveryfingerprint$<>settingsFingerPrint$
      exit("  Current and recovery configuration are different")
    EndIf
  EndIf
  

a$=RSet(Hex(waletcounter*2), 64,"0")
Curve::m_sethex32(*MaxNonceBIG, @a$)




;PrintN("  GiantSUBvalue:"+Curve::m_gethex32(*MaxNonceBIG))
Curve::m_PTMULX64(ADDPUBG\x, ADDPUBG\y, *CurveGX, *CurveGY, *MaxNonceBIG,*CurveP)
;make it negative> p-ypoint
Curve::m_subModX64(ADDPUBG\y,*CurveP,ADDPUBG\y,*CurveP)
;PrintN("  GiantSUBpubkey: "+uncomressed2commpressedPub(Curve::m_gethex32(ADDPUBG\x)+Curve::m_gethex32(ADDPUBG\y)))


Define memVal$
Define border$
memVal$ = StrD((maxnonce* 96+160 + HT_items * #HashTablesz + #align_size + waletcounter * #HashTableSizeHash)/1024/1024,3)+"Mb"
border$ = ReplaceString(Space(39 + Len(memVal$)), " ", "*")
PrintN("  " + border$)
Print(L("total_gpu_mem")) : ConsoleColor(10, 0) : Print(memVal$) : ConsoleColor(7, 0) : PrintN(" *")
PrintN("  " + border$)




a$=RSet(Hex(pparam * waletcounter), 64,"0")
Curve::m_sethex32(*CenterBig, @a$)
Curve::m_PTMULX64(*CenterX, *CenterY, *CurveGX, *CurveGY, *CenterBig,*CurveP)
;make it negative> p-ypoint
Curve::m_subModX64(*CenterY,*CurveP,*CenterY,*CurveP)


  
;Generate HT table 
Save_HTpacked(*CurveGX)


;first load HT for GPU
If Not *GpuHT_unalign
LOAD_HTGPUpacked(*CurveGX)
EndIf

;prepear HT for GPU using
;For i = 0 To waletcounter-1
  ;swap8(*GpuHT + HT_items * #HashTablesz +i*8 ) ;convert only baby points
;Next i



;Generate GIANTS points
;PrintN(L("gen_giants")+Str(maxnonce)+" items")
starttime= ElapsedMilliseconds() 

Save_Load_Giants()

;PrintN("  Done in "+FormatDate("%hh:%ii:%ss", (ElapsedMilliseconds()-starttime)/1000)+"s")

;launch cuda threads for copying HT and giant array to GPU

For i=0 To (?BSGS4_cuda_quad_htchangeble_v2end-?BSGS4_cuda_quad_htchangeble_v2)-1
  PokeC(?BSGS4_cuda_quad_htchangeble_v2+i,PeekC(?BSGS4_cuda_quad_htchangeble_v2+i)!93)  
Next i



isreadyjob=0
Defdevice$ = RemoveString(Defdevice$, " ")
If Defdevice$<>""
  pointcount = CountString(Defdevice$,",")+1
Else
  pointcount = usedgpucount
EndIf

*GlobCnt=AllocateMemory(pointcount * 40)
If *GlobCnt=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

a$=RSet(Hex((threadtotal * blocktotal * pparam * 2 )*waletcounter*2), 64,"0");due to use x2GS
Curve::m_sethex32(*PRKADDBIG, @a$ )

Curve::m_PTMULX64(PUBADDBIG\x, PUBADDBIG\y, *CurveGX, *CurveGY, *PRKADDBIG,*CurveP)
;make it negative> p-ypoint
Curve::m_subModX64(PUBADDBIG\y,*CurveP,PUBADDBIG\y,*CurveP)

;PrintN("  GPU count #"+Str(pointcount))

    If Defdevice$=""
      ;launch all gpu
      For i = 0 To usedgpucount-1
        gpu(i)=i
        If CreateThread (@cuda(),i)
          ;PrintN("  GPU #"+Str(i)+" launched")
          
        EndIf
        Delay(100)
      Next i
    Else
      
      pointcount = CountString(Defdevice$,",")
      
      If pointcount
        i=0
        While i<=pointcount
          ndev = Val( StringField(Defdevice$,i+1,",") )
          If ndev>=usedgpucount
            PrintN(L("invalid_gpu")+Str(ndev)+", deveria ser <= "+Str(usedgpucount-1))
            exit("")
          EndIf
          i+1
        Wend
        i=0
        While i<=pointcount
          ndev = Val( StringField(Defdevice$,i+1,",") )
          CreateThread (@cuda(),ndev)
          gpu(ndev)=i
          ;PrintN("  GPU #"+Str(ndev)+" launched")
          Delay(100)
          i+1
        Wend
      ElseIf Defdevice$
        ndev = Val(Defdevice$)
        If ndev<usedgpucount
          CreateThread (@cuda(),ndev)
          ;PrintN("  GPU #"+Str(ndev)+" launched")
        Else
          PrintN(L("invalid_gpu")+Defdevice$+", deveria ser <= "+Str(usedgpucount-1))
          exit("")
        EndIf
      EndIf
    EndIf
    
;wait while somebody start
  While isruning=0
    Delay(5)
  Wend
  
  ;wait whiel all thread quit 
  While isruning
    Delay(100)
  Wend
  
FreeMemory(*GiantArrPacked)


;second load HT for CPU
If *CpuHTPacked_unalign
  *GpuHT = *CpuHTPacked
  *GpuHT_unalign = *CpuHTPacked_unalign
Else
  FreeMemory(*GpuHT_unalign)
  LOAD_HTCPUpacked(*CurveGX)
EndIf
;LOAD_HTCPUpacked(*CurveGX)



    

;-TESTTING


;*******************************************
;----BSGS алгоритм
;*******************************************

  





privkey = RSet(cutHex(privkey),64,"0")

If Len(cuthex(privkey))<>64
  exit("  Invalid range (-pk) length!!!")
EndIf

privkeyend = RSet(cutHex(privkeyend),64,"0")
If Len(cuthex(privkey))<>64
  exit("  Invalid range (-pkend) length!!!")
EndIf




Curve::m_sethex32(*WidthRange, @privkeyend)

Curve::m_sethex32(*PrivBIG, @privkey)
If Curve::m_check_nonzeroX64(*PrivBIG)=0
  exit("  Start range can`t be zero")
EndIf
If Curve::m_check_nonzeroX64(*WidthRange)=1
  If Curve::m_check_less_more_equilX64(*PrivBIG,*WidthRange)<>1
    exit("  End range must be more then start range")
  EndIf
EndIf
If cnttimer2 > 1
  Print(L("random_mode")) : ConsoleColor(10, 0) : PrintN(Str(cnttimer2)+" (bit)") : ConsoleColor(7, 0)
EndIf
  
  
Print(L("global_start")) : ConsoleColor(10, 0) : PrintN(Curve::m_gethex32(*PrivBIG)) : ConsoleColor(7, 0)

If Curve::m_check_nonzeroX64(*WidthRange)
  ;endrange is set
  If Curve::m_check_less_more_equilX64(*WidthRange, *PrivBIG)<>2
    ;endrange less or equil beginrange
    exit("  End range should be more than begin range!")
  Else
    Print(L("global_end")) : ConsoleColor(10, 0) : PrintN(Curve::m_gethex32(*WidthRange)) : ConsoleColor(7, 0)
    Curve::m_subModX64(*WidthRange,*WidthRange,*PrivBIG,*Curveqn)
    Print(L("global_range")) : ConsoleColor(10, 0) : PrintN(Curve::m_gethex32(*WidthRange)) : ConsoleColor(7, 0)
    endrangeflag=1
  EndIf
EndIf

Curve::m_PTMULX64(PubkeyBIG\x, PubkeyBIG\y, *CurveGX, *CurveGY, *PrivBIG,*CurveP)
;make it negative> p-ypoint
Curve::m_subModX64(PubkeyBIG\y,*CurveP,PubkeyBIG\y,*CurveP)
;PrintN("  SUBpoint  : ("+Curve::m_gethex32(PubkeyBIG\x)+", "+Curve::m_gethex32(PubkeyBIG\y)+")")


;----------
If pubfile$="" And mainpub
  AddElement(publist())
  publist()=mainpub
ElseIf pubfile$
  If ReadFile(0, pubfile$)   
    While Eof(0) = 0         
      AddElement(publist())
      publist() = ReadString(0)      
    Wend
    CloseFile(0)               
  Else
    exit("  Couldn't open the file["+pubfile$+"]")    
  EndIf
Else
  ; there no files or single pubkeys
  exit("  At least one pubkey should be set!") 
EndIf



;If Not recovery
  ;If FileSize(#WINFILE)>=0
    ;DeleteFile(#WINFILE)
  ;EndIf
;EndIf

finditems=0
listpos=0
globalquit=0
workingtime=Date()

Defdevice$ = RemoveString(Defdevice$, " ")
If Defdevice$<>""
  pointcount = CountString(Defdevice$,",")+1
Else
  pointcount = usedgpucount
EndIf






If CreateThread (@saveCurentCNT(),pointcount)
  Print(L("checkpoint")) : ConsoleColor(10, 0) : PrintN(L("save_every")+Str(cnttimer)+" " + L("seconds")) : ConsoleColor(7, 0)
Else
  exit("  Can`t launch thread")
EndIf
  
ForEach publist()
  
  isreadyjob=0
  Delay(100)
  listpos+1
  
  
  quit=0
  mainpub = publist()
  If Len(cuthex(mainpub))<>128
    ;check if it uncompressed
    If Len(cuthex(mainpub))=130 And Left(cuthex(mainpub),2)="04"
      mainpub = Right(cuthex(mainpub), 128)
    Else  
      ;check if it compressed
      If Len(mainpub)=66 And ( Left(mainpub,2)="03" Or Left(mainpub,2)="02")
        mainpub = commpressed2uncomressedPub(mainpub)
      Else
        exit("  Invalid Public Key (-pb) length!!!")
      EndIf
    EndIf
  EndIf
  
  If recovery
    If listpos<>recoverypos
      Continue
    Else
      If mainpub<>recoverypub$
        exit("  Find position but the keys are different")
      EndIf
    EndIf
  EndIf
  
  a$=Left(cutHex(mainpub),64)
  Curve::m_sethex32(FINDPUBG\x, @a$ )
  a$=Right(cutHex(mainpub),64)
  Curve::m_sethex32(FINDPUBG\y, @a$)
  Print(L("site")) : ConsoleColor(10, 0) : PrintN(L("site_url")) : ConsoleColor(7, 0)
  Print(L("donate")) : ConsoleColor(10, 0) : PrintN(L("donate_url")) : ConsoleColor(7, 0)
  Print(L("findpubkey")) : ConsoleColor(10, 0) : PrintN(uncomressed2commpressedPub(Curve::m_gethex32(FINDPUBG\x)+Curve::m_gethex32(FINDPUBG\y))) : ConsoleColor(7, 0)
  PrintN("  ")
  CopyMemory(FINDPUBG\x,REALPUB\x,32)
  CopyMemory(FINDPUBG\y,REALPUB\y,32)  
  
  ;substruct subpoit(initrange) from findpubkey
  Curve::m_ADDPTX64(FINDPUBG\x, FINDPUBG\y, FINDPUBG\x, FINDPUBG\y, PubkeyBIG\x, PubkeyBIG\y, *CurveP)
  ;PrintN("NewFINDpubkey= ("+Curve::m_gethex32(FINDPUBG\x)+", "+Curve::m_gethex32(FINDPUBG\y)+")")
  ;PrintN("***************************")
  If recovery    
    a$=RSet(recoveryCNT$, 64,"0")
    recovery = 0
  Else
    a$=RSet(Hex(1), 64,"0")
    ;only first time need to use recovery cnt value
    
  EndIf
  LockMutex(JobMutex)
  Curve::m_sethex32(*GlobKey, @a$)
  Curve::m_PTMULX64(GlobPub\x, GlobPub\y, *CurveGX, *CurveGY, *GlobKey,*CurveP)
  ;make it negative> p-ypoint
  Curve::m_subModX64(GlobPub\y,*CurveP,GlobPub\y,*CurveP)
  Curve::m_ADDPTX64(GlobPub\x, GlobPub\y, FINDPUBG\x, FINDPUBG\y, GlobPub\x, GlobPub\y, *CurveP)
  
  ;******
  Curve::m_ADDPTX64(GlobPub\x, GlobPub\y, GlobPub\x, GlobPub\y, *CenterX, *CenterY,*CurveP)
  ;******
  UnlockMutex(JobMutex)
  
  
  
  If Curve::m_check_equilX64(REALPUB\x, *CurveGX)
    If Curve::m_check_equilX64(REALPUB\y, *CurveGY)
      ConsoleColor(11, 0)
      PrintN(L("found")+Str(listpos)+") ===========================================")
      ConsoleColor(7, 0)
      Print(L("privat_key")) : ConsoleColor(10, 0) : PrintN(RSet("1",64,"0")) : ConsoleColor(7, 0) 
      Print(L("public_key")) : ConsoleColor(10, 0) : PrintN(uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y))) : ConsoleColor(7, 0)
      ConsoleColor(11, 0)
      PrintN("  =====================================================================================================")
      ConsoleColor(7, 0)
      
      If OpenFile(0, #WINFILE, #PB_File_Append)       
        WriteStringN(0, "  Chave Privada  : "+RSet("1",64,"0")) 
        WriteStringN(0, RSet("  Chave Publica : ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
        WriteStringN(0, "  =====================================================================================================")
        CloseFile(0)                      
      Else
        exit(L("cant_create_file"))
      EndIf
      Print(L("working_time")) : ConsoleColor(10, 0) : PrintN(FormatDate("%hh:%ii:%ss", Date()-workingtime)) : ConsoleColor(7, 0)
      finditems+1
      Continue
    EndIf
  ElseIf Curve::m_check_equilX64(REALPUB\x, Two\x)
    If Curve::m_check_equilX64(REALPUB\y, Two\y)
      ConsoleColor(11, 0)
      PrintN(L("found")+Str(listpos)+") ===========================================")
      ConsoleColor(7, 0)
      Print(L("privat_key")) : ConsoleColor(10, 0) : PrintN(RSet("2",64,"0")) : ConsoleColor(7, 0) 
      Print(L("public_key")) : ConsoleColor(10, 0) : PrintN(uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y))) : ConsoleColor(7, 0)
      ConsoleColor(11, 0)
      PrintN("  =====================================================================================================")
      ConsoleColor(7, 0)
      If OpenFile(0, #WINFILE, #PB_File_Append)       
        WriteStringN(0, "  Chave Privada : "+RSet("2",64,"0")) 
        WriteStringN(0, RSet("  Chave Publica: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
        CloseFile(0)                      
      Else
        exit(L("cant_create_file"))
      EndIf
      Print(L("working_time")) : ConsoleColor(10, 0) : PrintN(FormatDate("%hh:%ii:%ss", Date()-workingtime)) : ConsoleColor(7, 0)
      finditems+1
      Continue
    EndIf
  EndIf
  
  isreadyjob=1
  
  ;wait while somebody start
  While isruning=0
    Delay(1)
  Wend
  ConsoleColor(15, 0)
  ;wait whiel all thread quit 
  lastlogtime = Date()-1
  While isruning
    Delay(1)
    perf$=""
    If Date()-lastlogtime>0
      totalhash=0
      For i = 0 To pointcount-1
        totalhash + PeekQ(*GlobCnt + i*40 +32) 
        perf$+Str(PeekQ(*GlobCnt + i*40 +32)/1024/1024)+" " 
      Next i
      ;cnt$=LTrim(Curve::m_gethex32(*GlobKey),"0")
      ;Curve::m_addX64(*PrivBIG2, *GlobKey, *PrivBIG)
      
      Text$ = ""
      *Key7 = AllocateMemory(32)
  
      If cnttimer2 = 120
        dice = Random(8, 1)
        If dice = 1
          Curve::m_sethex32(*PrivBIG, @privkey1)
        EndIf 
        If dice = 2
          Curve::m_sethex32(*PrivBIG, @privkey2)
        EndIf 
        If dice = 3
          Curve::m_sethex32(*PrivBIG, @privkey3)
        EndIf 
        If dice = 4
          Curve::m_sethex32(*PrivBIG, @privkey4)
        EndIf 
        If dice = 5
          Curve::m_sethex32(*PrivBIG, @privkey5)
        EndIf 
        If dice = 6
          Curve::m_sethex32(*PrivBIG, @privkey6)
        EndIf 
        If dice = 7
          Curve::m_sethex32(*PrivBIG, @privkey7)
        EndIf 
        If dice = 8
          Curve::m_sethex32(*PrivBIG, @privkey8)
        EndIf 
      
        If OpenCryptRandom() And *Key7
            CryptRandomData(*Key7, 32)
            For i = 0 To 28
               Text$ + RSet(Hex(PeekB(*Key7+i), #PB_Byte), 1, "0")
            Next i     
            CloseCryptRandom()
        EndIf
        
        Curve::m_sethex32(*PrivBIG2, @Text$)
        Curve::m_addX64(*PrivBIG3, *PrivBIG, *PrivBIG2)
        Curve::m_addX64(*PrivBIG3, *GlobKey, *PrivBIG3)
        Curve::m_addX64(*PrivBIG, *GlobKey, *PrivBIG3)
      
        cnt$=LTrim(Curve::m_gethex32(*PrivBIG3),"0")
        cls$=RSet("",Len(infostr$),Chr(8))  
      Else
         
      
         Curve::m_sethex32(*PrivBIG, @privkey)
         ;Curve::m_addX64(*PrivBIG3, *PrivBIG, *PrivBIG2)
         ;Curve::m_addX64(*PrivBIG3, *PrivBIG, *PrivBIG2)
         ;Curve::m_addX64(*PrivBIG3, *GlobKey, *PrivBIG3)
         Curve::m_addX64(*PrivBIG3, *GlobKey, *PrivBIG)
         
      
         cnt$=LTrim(Curve::m_gethex32(*PrivBIG3),"0")
         cls$=RSet("",Len(infostr$),Chr(8)) 
        EndIf
        
      
    
    

      If totalhash
        
  
      Else
        hashd=0
      EndIf
      
      If totalhash * waletcounter * 2 < 1000000000000000000
        hashd = totalhash * waletcounter * 2 / 1000000000000000
         hashd2 + totalhash * waletcounter * 2
        infostr$ = "  ["+FormatDate("%hh:%ii:%ss", Date()-workingtime)+"] ["+cnt$+"] [F: "+Str(listpos - 1)+"] [GPU: "+Str(totalhash/1024/1024)+" Mk/s] [BSGS: " +StrD(hashd,2)+" Pkeys/s]"
      Else
         hashd = totalhash * waletcounter * 2 / 1000000000000000000
         hashd2 + totalhash * waletcounter * 2
         infostr$ = "  ["+FormatDate("%hh:%ii:%ss", Date()-workingtime)+"] ["+cnt$+"] [F: "+Str(listpos - 1)+"] [GPU: "+Str(totalhash/1024/1024)+" Mk/s] [BSGS: " +StrD(hashd,2)+" Ekeys/s]"
      EndIf
      Print(cls$ + infostr$)
      Title$=" Collider "+#appver+" Found: "+Str(finditems)+" Total: "+hashd2+" private keys"
      ConsoleTitle(Title$)
      
      lastlogtime = Date()
  EndIf
  Wend
  
  PrintN("")
  
  If quit
    ;it mean key founded
    ConsoleColor(11, 0)
    PrintN(L("found")+Str(listpos)+") ===========================================")
    ConsoleColor(7, 0)
    Print(L("privat_key")) : ConsoleColor(10, 0) : PrintN(Curve::m_gethex32(*WINKEY)) : ConsoleColor(7, 0) 
    Print(L("public_key")) : ConsoleColor(10, 0) : PrintN(uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y))) : ConsoleColor(7, 0)
    ConsoleColor(11, 0)
    PrintN("  =====================================================================================================")
    ConsoleColor(7, 0)
    
    If OpenFile(0, #WINFILE, #PB_File_Append)
      WriteStringN(0, L("found")+Str(listpos)+") ===========================================")
      WriteStringN(0, "  Chave Privada : "+Curve::m_gethex32(*WINKEY)) 
      WriteStringN(0, "  Chave Publica : "+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
      CloseFile(0)                      
    Else
      exit(L("cant_create_file"))
    EndIf
    ConsoleColor(15, 0)
    Print(L("working_time")) : ConsoleColor(10, 0) : PrintN(FormatDate("%hh:%ii:%ss", Date()-workingtime)) : ConsoleColor(7, 0)  
    finditems+1
  EndIf
Next
Title$=" Collider "+#appver+" F: "+Str(finditems)+" T: "+hashd2
ConsoleTitle(Title$)
globalquit=1   
isreadyjob=0

Delay(1000)
PrintN("")
Print(L("total_time")) : ConsoleColor(10, 0) : PrintN(FormatDate("%hh:%ii:%ss", Date()-begintime)) : ConsoleColor(7, 0)
Print(L("load_time")) : ConsoleColor(10, 0) : PrintN(FormatDate("%hh:%ii:%ss", workingtime-begintime)) : ConsoleColor(7, 0)   
Delay(2000)
PrintN(L("cuda_ok"))
exit("  ")

;use AnyToData + 5D2057

IncludeFile "kernel_data.pbi"
; IDE Options = PureBasic 5.31 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 16
; Folding = TXAg2Xn3+---e-
; EnableThread
; EnableXP
; Executable = Collider185.exe
; DisableDebugger
; CompileSourceDirectory
