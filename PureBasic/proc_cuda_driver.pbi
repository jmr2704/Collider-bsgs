Procedure Tune(memsize, sm)
  Protected  treadN, blockN, pparamN, wN, htszN, k, httotsize, frmem, gsize, ramneed1, ramneed2
  ;Debug "freemem:"+Str(memsize)
  blockN=sm
  treadN=256
  pparamN=256
  gsize= treadN * blockN * pparamN *96 + 160 + #align_size
  ;Debug gsize
  If memsize - gsize>0
      k = Log(memsize - gsize)/Log(2)
      ;Debug k
      If k>30
        k=30
      EndIf
      k+1
      Repeat 
        k-1
        Select k
          ;Case 31
            ;htszN=30
          Case 30
            htszN=28
          Case 29
            htszN=28
          Case 28
            htszN=27
          Case 27
            htszN=25
        EndSelect
        
        httotsize = Pow(2,k)*4 + Pow(2,htszN)*8
        ;Debug "k:"+Str(k)+" htszN:"+Str(htszN)+" = "+Str(httotsize)
      Until (gsize+httotsize)<memsize Or k<25
      Repeat
        frmem = memsize - httotsize
        ;Debug frmem
        frmem = (frmem - 160 - #align_size)/96
        ;Debug frmem
        frmem = frmem / blockN
        ;Debug frmem
        frmem = frmem / treadN
        ;Debug frmem
        If frmem>512
          If treadN<512
            treadN+32
            ;Debug ">>thread set to "+Str(treadN)
          Else
            blockN + sm
            ;Debug ">>block set to "+Str(blockN)
          EndIf
        EndIf
        ;Debug "******"
        
      Until frmem<512 Or blockN/sm>=4
        frmem = memsize - httotsize    
        frmem = (frmem - 160 - #align_size-96)/96
        frmem = frmem / blockN / treadN
        If frmem&1
          frmem+1
        EndIf
        pparamN = frmem
        gsize= treadN * blockN * pparamN *96 + 160 + #align_size       
        If gsize+httotsize>memsize
          pparamN-2
           gsize= treadN * blockN * pparamN *96 + 160 + #align_size
         EndIf
         
     ramneed1 = (Pow(2,k)+1)*8 + #align_size ;baby array
     ramneed1 + Pow(2,htszN)*8 +#align_size + Pow(2,k)*8 +#align_size + Pow(2,k)*8 +#align_size;HT unpacked
     ;Debug "ramneed:"+StrD((ramneed1)/1024/1024,3)
     ramneed2 = Pow(2,htszN)*8 +#align_size + Pow(2,k)*8 +#align_size + Pow(2,k)*8 +#align_size;HT unpacked
     ramneed2 + Pow(2,htszN)*8 +#align_size + Pow(2,k)*8 +#align_size ;HTCPU packed
     ;Debug "ramneed:"+StrD((ramneed2)/1024/1024,3)
     If ramneed2>ramneed1
       ramneed1=ramneed2
     EndIf
     Print(L("try_params")) : ConsoleColor(10, 0) : PrintN("-t "+Str(treadN)+" -b "+Str(blockN)+" -p "+Str(pparamN)+" -w "+Str(k)+" -htsz "+Str(htszN)+" ["+StrD((gsize+httotsize)/1024/1024,3)+" MB]" + L("gen_ram") + Str(ramneed1/1024/1024)+" MB]") : ConsoleColor(7, 0)
     
     ;Debug "gsize: "+Str(gsize)
     ;Debug "htsize: "+Str(httotsize)
     ;Debug "total MB: "+StrD((gsize+httotsize)/1024/1024,3)+"/"+StrD(memsize/1024/1024,3)
   EndIf
EndProcedure

Procedure retGPUcount()
Protected namedev.s=Space(128)
Protected sizebytes.i
Protected piattrib.i
Protected major.i
Protected minor.i
Protected count.i
Protected mp.i
Protected cores.i
Protected pi.i    
Protected i.i
Protected result.i
Protected CudaDevice.i
Protected freebytes.i
Protected totalbytes.i
Protected CudaContext.i
cuInit(0)

cuDeviceGetCount(@count)
Print(L("used_gpu")) : ConsoleColor(10, 0) : PrintN(Str(count)) : ConsoleColor(7, 0)

For i = 0 To count-1
      result = cuDeviceGet(@CudaDevice, i)               
      If result
        exit("  cuDeviceGet - "+Str(result)+#CRLF$+"Try change -d param")
      EndIf
      result = cuDeviceGetName(namedev,128,CudaDevice)
      If result
        exit("  cuDeviceGetName - "+Str(result))
      EndIf
      result = cuDeviceTotalMem_v2(@sizebytes,CudaDevice)
      If result
        exit("  cuDeviceTotalMem - "+Str(result))
      EndIf
      result =  cuCtxCreate_v2(@CudaContext, 4, CudaDevice)    ; CU_CTX_BLOCKING_SYNC = 4 -- cuCtxSynchronize()
      If result
        exit("  cuCtxCreate - "+Str(result))
      EndIf
      result=cuMemGetInfo_v2 	(@freebytes,@totalbytes) 	
      If result
       exit("  error cuMemGetInfo_v2-"+Str(result))
      EndIf
      cuCtxDestroy_v2(CudaContext)
      
      
      Print(L("used_gpu_card")) : ConsoleColor(10, 0) : PrintN(namedev+" ("+StrD(freebytes/1048576)+"/"+Str(sizebytes/1048576)+" MB)") : ConsoleColor(7, 0)
      
      cuDeviceComputeCapability(@major,@minor,CudaDevice) 
      cuDeviceGetAttribute(@piattrib,16,CudaDevice)
      mp=piattrib
      Select major
          
          Case 2 ;Fermi
            Debug "Fermi"
            If minor=1
              cores = mp * 48
            Else 
              cores = mp * 32
            EndIf
          Case 3; Kepler 
            Debug "Kepler"
            cores = mp * 192
            
          Case 5; Maxwell 
            Debug "Maxwell"
            cores = mp * 128
            
          Case 6; Pascal 
            Debug "Pascal"
            cores = mp * 64
            
          Case 7; Pascal 
            Debug "Pascal RTX"
            cores = mp * 64
            
          Case 8; Ampere 
            Debug "Ampere RTX"
            cores = mp * 128
          Default
            Debug "Unknown device type"
        EndSelect
      
      ;PrintN("  GPU have      : MP: "+mp+ " and " +cores+ " cores")
      
      
      ;cuDeviceGetAttribute(@pi,8,CudaDevice)      
      ;PrintN("Shared memory total:"+Str(pi))
      
      ;cuDeviceGetAttribute(@pi,9,CudaDevice)     
      ;PrintN("Constant memory total:"+Str(pi))
      If mp
        Tune(freebytes, mp)
      EndIf
      
Next i
ProcedureReturn count
EndProcedure

Procedure GetJob(*key, *pubx,*puby)
  Shared JobMutex
  Shared *GlobKey
  Shared GlobPub
  Shared PUBADDBIG
  Shared *PRKADDBIG
  Shared *CurveP
  Shared *Curveqn
  LockMutex(JobMutex)
  CopyMemory(*GlobKey,*key,32)
  CopyMemory(GlobPub\x,*pubx,32)
  CopyMemory(GlobPub\y,*puby,32)
  Curve::m_ADDPTX64(GlobPub\x,GlobPub\y, GlobPub\x,GlobPub\y,PUBADDBIG\x,PUBADDBIG\y, *CurveP)
  Curve::m_addModX64(*GlobKey,*GlobKey,*PRKADDBIG,*Curveqn)
  UnlockMutex(JobMutex)
EndProcedure

Procedure cuda(gpuid.i)
Protected CudaDevice.i
Protected CudaContext.i
Protected CudaModule.i
Protected CudaFunction.i
Protected err
Protected fname$
Protected DeviceConstantPointer.i
Protected ReturnNumber.i
Protected bytesize.i
Protected myhashrate
Protected DeviceReturnNumber.i
Protected DeviceReturnNumberUnAlign.i
Protected *b
Protected *a
Protected *c
Protected *r
Protected *batch
Protected resser.s
Protected Time1.i
Protected Time1end.i
Protected totalsizeneeded.i
Protected w$, Jobprk$,JobMg$
Protected const_name$
Protected casharrsize.i
Protected desiredarrsize.i
Protected totalpubsizeneeded.i
Protected i.i
Protected pi.i 
Protected winset.l
Protected winpubid.l
Protected wintid.l
Protected isequil.i
Protected Yoffset
Protected *temper
Protected diference
Protected starttime
Protected res.comparsationStructure
Protected winflag, pos_param
Protected puboffset,paramsize
Protected batchsize, a$, rest.HashTableResultStructure, freebytes, totalbytes
Shared  maxnonce, waletcounter, privkey, isruning
Shared sortjob()
Shared *GiantArrPacked, *GpuHT, HT_items,HT_mask, quit, globalquit, *WidthRange, endrangeflag,isreadyjob
Shared *GlobCnt

Shared threadtotal
Shared blocktotal
Shared pparam, keyMutex, listpos
Shared *CurveGX, *CurveGy, *CurveP, *Curveqn, FINDPUBG, ADDPUBG, pubkeyBIG, *PRKADDBIG, PUBADDBIG, REALPUB, *WINKEY
Protected *counterBig, *counterBigTemp, *tempor, *MylocalPrk, MylocalPUB.CoordPoint, TestPUB.CoordPoint, *PRKADD, *px, *py
Protected hashd.d, gpupos
Shared *CenterBig, *CenterX, *CenterY

Shared *PrivBIG
Shared *PrivBIG2
Shared *PrivBIG3
LockMutex(keyMutex)
isruning+1
UnlockMutex(keyMutex)
Delay(5)

gpupos = gpu(gpuid)
*MylocalPrk= *GlobCnt + gpupos * 40

*temper=AllocateMemory(32)
If *temper=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

*batch=AllocateMemory(32)
If *batch=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf

*r=AllocateMemory(32)
If *r=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*counterBig=AllocateMemory(32)
If *counterBig=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*counterBigTemp=AllocateMemory(32)
If *counterBigTemp=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*tempor=AllocateMemory(32)
If *tempor=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf


MylocalPUB\x=AllocateMemory(32)
If MylocalPUB\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
MylocalPUB\y=AllocateMemory(32)
If MylocalPUB\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
TestPUB\x=AllocateMemory(32)
If TestPUB\x=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
TestPUB\y=AllocateMemory(32)
If TestPUB\y=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*PRKADD=AllocateMemory(32)
If *PRKADD=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
err = cuDeviceGet(@CudaDevice, gpuid)                 
If err
  exit("  cuDeviceGet - "+Str(err))
EndIf
err =  cuCtxCreate_v2(@CudaContext, 4, CudaDevice)    ; CU_CTX_BLOCKING_SYNC = 4 -- cuCtxSynchronize()
If err
  exit("  cuCtxCreate - "+Str(err))
EndIf


;fname$="BSGS4_cuda_quad_htchangeble_v2_1_6NEGx2.ptx"

;err=cuModuleLoad(@CudaModule, @fname$)
  err=cuModuleLoadData(@CudaModule, ?BSGS4_cuda_quad_htchangeble_v2 )
If err
  exit("  error cuModuleLoad1-"+Str(err))
EndIf
err=cuModuleGetFunction(@CudaFunction, CudaModule, "_test1")      ;получает адрес функции
If err
  exit("  error cuModuleGetFunction1-"+Str(err))
EndIf

err=cuFuncSetCacheConfig 	(CudaFunction,2) 
If err
 exit("  error cuFuncSetCacheConfig1-"+Str(err))
EndIf
                      

casharrsize = maxnonce 
desiredarrsize = waletcounter 
paramsize=128; do not change
totalsizeneeded = casharrsize * 96+#alignMemoryGpu
puboffset = totalsizeneeded+#alignMemoryGpu-(totalsizeneeded % #alignMemoryGpu)
puboffset = puboffset + paramsize
totalsizeneeded = totalsizeneeded + paramsize
totalpubsizeneeded = HT_items * #HashTablesz  + waletcounter * #HashTableSizeHash

batchsize = blocktotal * threadtotal * pparam


;PrintN("---------------")
;PrintN("Nonces per Thread: " + Str(pparam) )
;PrintN("Threads in block: " + Str(threadtotal) )
;PrintN("Blocks in grid: " + Str(blocktotal) )
;PrintN("Total nonces: " + Str(batchsize) )
;PrintN("Baby steps: " + Str(desiredarrsize) )
;PrintN("---------------")


*a=AllocateMemory(256)
If *a=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*b=AllocateMemory(paramsize) 
If *b=0
  PrintN(L("cant_alloc_mem"))
  exit("")
EndIf
*c=AllocateMemory(256) 
resser.s=Space(4096) 

;PrintN("GPU #"+Str(gpuid)+" GiantsBuff: "+Str(casharrsize)+" points(96b) = "+  StrD(totalsizeneeded/1024/1024,3)+"Mb")
;PrintN("GPU #"+Str(gpuid)+"     HTbuff: "+Str(desiredarrsize)+" points(8b) = "+  StrD(totalpubsizeneeded/1024/1024,3)+"Mb")
err=cuMemGetInfo_v2 	(@freebytes,@totalbytes) 	
If err
 exit("  error cuMemGetInfo_v2-"+Str(err))
EndIf
;Print("  GPU #"+Str(gpuid)+" Free memory  : " : ConsoleColor(10, 0) : PrintN(Str(freebytes/1048576) : ConsoleColor(7, 0)+" MB")
;Print("  GPU #"+Str(gpuid)+" Total memory : " : ConsoleColor(10, 0) : PrintN(Str(totalbytes/1048576) : ConsoleColor(7, 0)+" MB")
;Print("  GPU #"+Str(gpuid)+" TotalBuff    : " : ConsoleColor(10, 0) : PrintN( StrD((totalsizeneeded+totalpubsizeneeded) : ConsoleColor(7, 0)/1024/1024,3)+" MB")
;PrintN("---------------")



err=cuMemAlloc_v2(@DeviceReturnNumberUnAlign, (totalsizeneeded+totalpubsizeneeded+paramsize) + #alignMemoryGpu)  ;аллоцирует 200 байт на gpu
If err
  exit("  error cuMemAlloc-"+Str(err))
EndIf
DeviceReturnNumber=DeviceReturnNumberUnAlign+#alignMemoryGpu-(DeviceReturnNumberUnAlign % #alignMemoryGpu)




err=cuParamSetSize(CudaFunction, 8)           
If err
  exit("  error cuParamSetSize-"+Str(err))
EndIf
err=cuParamSeti(CudaFunction, 0, PeekL(@DeviceReturnNumber))  
If err
  exit("  error cuParamSeti-"+Str(err))
EndIf
err=cuParamSeti(CudaFunction,4, PeekL(@DeviceReturnNumber+4))  
If err
  exit("  error cuParamSeti-"+Str(err))
EndIf
err=cuFuncSetBlockShape(CudaFunction, threadtotal,1,1)
If err
  exit("  error cuFuncSetBlockShape-"+Str(err))
EndIf



;For i=0 To 6
  ;err = cuFuncGetAttribute 	(@pi,i,CudaFunction) 
  ;If err
    ;exit("cuFuncGetAttribute - "+Str(err))
  ;EndIf
  ;PrintN (a$(i)+Str(pi))
;Next i
;PrintN("---------------")


;структура глобальной памяти
;0-31 системные 0:3 результат гпу, 4:7 пубкаунтер 8:11 pparam 12:15 -maxnonce  16[при солюшене] - пубкейайди, нить
;32-95 magicpoint (pubkey for operation)
;96-104 puboffset (offset for baby points array)
;104-111 HT size
;112-119 HT mask
;128-N массив точек X,Y координаты по 64 б
;за ним идет массив бебистеп


PokeL(*b+4,waletcounter)
;поставим pparam
PokeL(*b+8,pparam)

PokeL(*b+12,casharrsize)

PokeI(*b+96,puboffset)

PokeI(*b+104,HT_items * #HashTablesz)

PokeL(*b+112,HT_mask)



;copy params to GPU
cuMemcpyHtoD_v2(DeviceReturnNumber,*b, paramsize)  
If err
  exit("  error cuMemcpyHtoD-"+Str(err))
EndIf
;copy giant points to GPU
cuMemcpyHtoD_v2(DeviceReturnNumber+paramsize,*GiantArrPacked, maxnonce*64)  
If err
  exit("  error cuMemcpyHtoD-"+Str(err))
EndIf

;copy packed HT(baby points) to GPU
cuMemcpyHtoD_v2(DeviceReturnNumber + puboffset,*GpuHT, totalpubsizeneeded)  
If err
  exit("  error cuMemcpyHtoD-"+Str(err))
EndIf

;-iteration BEGIN

LockMutex(keyMutex)
isruning-1
UnlockMutex(keyMutex)


Repeat 
PokeQ(*MylocalPrk+32,0)  
While isreadyjob=0
  Delay(1)
Wend
 
LockMutex(keyMutex)
isruning+1
UnlockMutex(keyMutex)
Delay(10)

a$=RSet(Hex(batchsize*2), 64,"0");due to use simmetry in addition points and x2GS
Curve::m_sethex32(*batch, @a$ )


a$=RSet(Hex(0), 64,"0")
Curve::m_sethex32(*counterBig, @a$ )
Curve::m_sethex32(*counterBigTemp, @a$ )

Time1 = ElapsedMilliseconds()
starttime =Date()

GetJob(*MylocalPrk, MylocalPUB\x, MylocalPUB\y)
;******

;******

;PrintN("CENTER-"+Curve::m_gethex32(*CenterBig))
;PrintN("CENTERpub-"+Curve::m_gethex32(*CenterX)+","+Curve::m_gethex32(*CenterY))
;Input()
;Curve::m_subModX64(*MylocalPrk,*MylocalPrk,*CenterBig,*Curveqn)

;PrintN("GPU#"+Str(gpuid)+" Cnt:"+Curve::m_gethex32(*MylocalPrk))









CopyMemory(MylocalPUB\x,*b+32,32)
CopyMemory(MylocalPUB\y,*b+64,32)
isequil=0

;PrintN(": "+Curve::m_gethex32(MylocalPUB\x) + " "+ Curve::m_gethex32(MylocalPUB\y))
;foundinarr8(*b+32+24, *BabyArrSorted, 0, waletcounter, @res.comparsationStructure)
;res\pos = compareHTpack(*b+32+24)
  ;If res\pos<>-1
    ;PrintN("FOUND on CPU!!!")  
    ;isequil = 1
  ;Else
    ;isequil = 0
  ;EndIf

*px=MylocalPUB\x
*py=MylocalPUB\y
 
Repeat
  

  ;PrintN("WorkPub: "+Curve::m_gethex32(*px)+","+Curve::m_gethex32(*py))
  res\pos = compareHTpack(*px+24)
  If res\pos<>-1
    ;PrintN("FOUND on CPU!!!")  
    isequil = 1
  Else
    isequil = 0
  EndIf
  If ElapsedMilliseconds()-Time1>2000
    
    Time1end = ElapsedMilliseconds()-Time1
    Time1 = ElapsedMilliseconds()
    Curve::m_subX64(*tempor,*counterBig,*counterBigTemp)
    
    diference =PeekQ(*tempor)
    mul8ui(*tempor,1000,*tempor)
    
   
    
    
    
    If Time1end
      div8(*tempor,Time1end,*tempor,*r)
      
      myhashrate =PeekQ(*tempor)
    Else
      myhashrate = 0
    EndIf
    CopyMemory(*counterBig, *counterBigTemp,32)
    ;save hashrate
    PokeQ(*MylocalPrk+32,myhashrate)
    
    hashd= Log(myhashrate)/Log(2)
    ;PrintN("GPU#"+Str(gpuid)+" Cnt:"+Curve::m_gethex32(*MylocalPrk)+" "+Str(myhashrate/1024/1024)+"MKey/s x"+Str(waletcounter) +" 2^"+ StrD(hashd,2)+" x2^"+StrD(wald,0)+"=2^"+StrD(hashd+wald,2))
    
  EndIf


  If isequil=0
    
    ;CopyMemory(MylocalPUB\x,*b+32,32)
    ;CopyMemory(MylocalPUB\y,*b+64,32)
    move32b_(p.p_px, p.p_b,0,32)
    move32b_(p.p_py, p.p_b,0,64)
    
    swap32(*b+32)
    swap32(*b+64)
    
    ;копируем magic point в gpu ГЛОБАЛЬНУЮ память
    cuMemcpyHtoD_v2(DeviceReturnNumber+32,*b+32, 64)  
    If err
      exit("  error cuMemcpyHtoD-"+Str(err))
    EndIf
    
    
   
    
    err=cuLaunchGrid(CudaFunction, blocktotal, 1)
    If err
      exit("  error cuLaunchGrid-"+Str(err))
    EndIf
    
    err=cuCtxSynchronize()
    
    If err
      exit("  error cuCtxSynchronize-"+Str(err))  
    EndIf
    
    
    
    err=cuMemcpyDtoH_v2(*a, DeviceReturnNumber, 4)  ;копирует 4 байта из gpu
    If err
        exit("  error cuMemcpyDtoH-"+Str(err))
    EndIf
      
    ;check if win set
    winset = PeekL(*a)
    
    
    If winset>0
      
      err = cuMemcpyDtoH_v2(*a, DeviceReturnNumber+16, winset*8)
      If err
        exit("  cuMemcpyDtoH - "+Str(err))
      EndIf
      
      
      winflag=0
      For i = 0 To winset-1
            winpubid = PeekL(*a+8*i)        
            wintid = PeekL(*a+8*i+4)
            
            
            
            
            ;PrintN("***********GPU#"+Str(gpuid)+"************")
            ;PrintN("Total solutions: "+Str(winset))            
            ;PrintN("Winnonce: "+Str(wintid))            
            ;PrintN("ArrayID: "+Str(winpubid))   ;pos in sorted array   
            ;PrintN("At: "+Curve::m_gethex32(*MylocalPrk))
            ;PrintN("Pub: "+Curve::m_gethex32(MylocalPUB\x)+" , "+ Curve::m_gethex32(MylocalPUB\y))
            ;PrintN("Fnd: "+Curve::m_gethex32(FINDPUBG\x))
            
            pos_param = wintid - Int(wintid / pparam) * pparam
            ;PrintN("pos_param:"+Str(pos_param))
            
            If winpubid=4
              a$=RSet(Hex((wintid+1) * (waletcounter*2)), 64,"0")
              Curve::m_sethex32(*tempor, @a$ )
              Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
              ;PrintN(Curve::m_gethex32(TestPUB\x)+","+Curve::m_gethex32(TestPUB\y))
              If Curve::m_check_equilX64(*px,TestPUB\x)=1 
                If Curve::m_check_equilX64(*py,TestPUB\y)=0                 
                  Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                EndIf
                ;PrintN(Curve::m_gethex32(*tempor))
                
                
                
                Curve::m_addModX64(*temper,*tempor,*CenterBig,*Curveqn)
                Curve::m_addModX64(*temper,*MylocalPrk,*temper,*Curveqn)
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *temper,*CurveP)
                
                ;PrintN(Curve::m_gethex32(TestPUB\x)+","+Curve::m_gethex32(TestPUB\y))
                If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=0                
                  Curve::m_subModX64(*temper,*tempor,*CenterBig,*Curveqn)
                  Curve::m_addModX64(*temper,*MylocalPrk,*temper,*Curveqn)
                  Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *temper,*CurveP)
                EndIf
                ;PrintN(Curve::m_gethex32(TestPUB\x)+","+Curve::m_gethex32(TestPUB\y))
                
                Curve::m_addModX64(*temper,*PrivBIG,*temper,*Curveqn) 
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *temper,*CurveP)
                If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                  If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0                 
                    Curve::m_subModX64(*temper,*Curveqn,*temper,*Curveqn)
                  EndIf
                  Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *temper,*CurveP)
                  CopyMemory(*temper, *tempor, 32)
                  ;PrintN("***********GPU#"+Str(gpuid)+"************")
                  ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                  ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                  ;PrintN("****************************")   
                  ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                  winflag=1
                  Break 
                Else
                   ;PrintN("False")
                EndIf
              Else
                ;PrintN("False")
              EndIf
              
              
              
            Else
              ;----
              a$=RSet(Hex(wintid+1), 64,"0")
            Curve::m_sethex32(*tempor, @a$ )
            Curve::m_PTMULX64(TestPUB\x, TestPUB\y, ADDPUBG\x, ADDPUBG\y, *tempor,*CurveP)

            If winpubid=2            
              Curve::m_subModX64(TestPUB\y,*CurveP,TestPUB\y,*CurveP)              
            EndIf
            pos_param  = winpubid
            Curve::m_ADDPTX64(TestPUB\x,TestPUB\y,MylocalPUB\x,MylocalPUB\y,TestPUB\x,TestPUB\y,*CurveP)
            
            
            
              winpubid =  compareHTpack(TestPUB\x+24)
              If winpubid<>-1
                ;PrintN("SolutionID: "+Str(winpubid))
              Else
                PrintN("Chave publica falsa ignorada (Colisao no Hash GPU)")
              EndIf
              
              
              a$=RSet(Hex((wintid+1)*waletcounter*2+winpubid+1), 64,"0")
              Curve::m_sethex32(*tempor, @a$ )
              
              If pos_param=1
                ;***
                Curve::m_addModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                ;***               
                Curve::m_addModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
               
              Else
                Curve::m_subModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                Curve::m_subModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
                
              EndIf
                ;2c675b852189a20
                
                ;2c675b852189a21
                ;PrintN("At: "+Curve::m_gethex32(*tempor))
                
              Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
              ;PrintN(">>: "+Curve::m_gethex32(TestPUB\x))            
              If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=1
                ;PrintN("Yay!!>"+Curve::m_gethex32(*tempor))
                Curve::m_addModX64(*tempor,*PrivBIG,*tempor,*Curveqn) 
                
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                  
                  If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                    Print("<*>")
                    Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                    Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                  EndIf
                  ;PrintN("***********GPU#"+Str(gpuid)+"************")
                  ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                  ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                  ;PrintN("****************************")   
                  ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                  winflag=1
                  Break               
                 
                Else
                  
                  ;PrintN("False collision")
                  ;PrintN(">"+Curve::m_gethex32(*tempor)) 
                  ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                  ;PrintN(Curve::m_gethex32(TestPUB\x))
                EndIf
                
              Else
                a$=RSet(Hex((wintid)*waletcounter*2+(waletcounter*2-winpubid-1)), 64,"0")
                Curve::m_sethex32(*tempor, @a$ )
                If pos_param=1
                  ;***
                  Curve::m_addModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                  ;***               
                  Curve::m_addModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
                 
                Else
                  Curve::m_subModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                  Curve::m_subModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
                  
                EndIf            
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                ;PrintN("At2: "+Curve::m_gethex32(*tempor))
                 ;PrintN(">>2: "+Curve::m_gethex32(TestPUB\x)) 
                If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=1
                  ;key was under zero
                  ;PrintN("Yay!!>"+Curve::m_gethex32(*tempor))
                  Curve::m_addModX64(*tempor,*PrivBIG,*tempor,*Curveqn) 
                
                  Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                  If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                    
                    If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                      Print("<*>")
                      Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                      Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                    EndIf
                    ;PrintN("***********GPU#"+Str(gpuid)+"************")
                    ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                    ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                    ;PrintN("****************************")   
                    ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                    winflag=1
                    Break               
                   
                  Else
                    
                    ;PrintN("False collision")
                    ;PrintN(">"+Curve::m_gethex32(*tempor)) 
                    ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                    ;PrintN("** "+Curve::m_gethex32(TestPUB\x))
                  EndIf
                Else
                  a$=RSet(Hex((wintid)*waletcounter*2+(waletcounter*2-winpubid+1)), 64,"0")
                  Curve::m_sethex32(*tempor, @a$ )
                  If pos_param=1
                    ;***
                    Curve::m_addModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                    ;***               
                    Curve::m_addModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
                   
                  Else
                    Curve::m_subModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                    Curve::m_subModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
                    
                  EndIf   
                  Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                  Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                  ;PrintN("At3: "+Curve::m_gethex32(*tempor))
                  ;PrintN(">>3: "+Curve::m_gethex32(TestPUB\x)) 
                
                  If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=1
                    ;key was under zero
                    ;PrintN("Yay!!>"+Curve::m_gethex32(*tempor))
                    Curve::m_addModX64(*tempor,*PrivBIG,*tempor,*Curveqn) 
                  
                    Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                    If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                      
                      If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                        Print("<*>")
                        Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                        Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                      EndIf
                      ;PrintN("***********GPU#"+Str(gpuid)+"************")
                      ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                      ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                      ;PrintN("****************************")   
                      ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                      winflag=1
                      Break               
                     
                    Else
                      
                      ;PrintN("False collision")
                      ;PrintN(">"+Curve::m_gethex32(*tempor)) 
                      ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                      ;PrintN("** "+Curve::m_gethex32(TestPUB\x))
                    EndIf
                  EndIf
                EndIf
                
             
                
              EndIf
            EndIf
            
            
           
            
      Next i
      ;clear collision
      PokeL(*b,0)
      cuMemcpyHtoD_v2(DeviceReturnNumber,*b, 4)  
      If err
        exit("  error cuMemcpyHtoD-"+Str(err))
      EndIf
      
      If winflag=0
        winset=0
      EndIf
    EndIf
  Else
    ;PrintN("*******CPU/GPU#"+Str(gpuid)+"**************")
    
    ;PrintN("At: "+Curve::m_gethex32(*MylocalPrk))
    ;PrintN("Pub: "+Curve::m_gethex32(MylocalPUB\x)+" , "+ Curve::m_gethex32(MylocalPUB\y))
    
    ;winpubid =  findsolution(*BabyArrSorted+res\pos*8, *BabyArr, waletcounter,8)
    winpubid=res\pos
            If winpubid<>-1
              ;PrintN("SolutionID: "+Str(winpubid))
            Else
              PrintN(L("cant_found_solution"))
            EndIf
            
            
            a$=RSet(Hex(winpubid+1), 64,"0")
            Curve::m_sethex32(*tempor, @a$ )   
            Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
            If Curve::m_check_equilX64(*px,TestPUB\x)=1
              If Curve::m_check_equilX64(*py,TestPUB\y)=0
                Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
              EndIf
              ;***
              Curve::m_addModX64(*tempor,*tempor,*CenterBig,*Curveqn)
              ;***
              Curve::m_addModX64(*tempor,*MylocalPrk,*tempor,*Curveqn)
              
              Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)              
              If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=1
                ;ok X points is equil
                If Curve::m_check_equilX64(FINDPUBG\y,TestPUB\y)=0
                  ;Print("<*>")
                  Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                  
                EndIf
                ;PrintN("Yay!!>"+Curve::m_gethex32(*tempor))
                CopyMemory(*tempor, *temper,32)
                Curve::m_addModX64(*tempor,*PrivBIG,*tempor,*Curveqn) 
                
                
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                    If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                      
                      If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                        ;Print("<*>")
                        Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                        Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                      EndIf
                      ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                      ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                      ;PrintN("****************************")   
                      ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                      winset=1
                      isequil=0
                      Break               
                     
                    Else
                      
                      ;Print("<*>")
                      CopyMemory(*temper, *tempor,32)
                      Curve::m_subModX64(*tempor,*tempor,*PrivBIG,*Curveqn)
                      Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                      If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                      
                        If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                          ;Print("<*>")
                          Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                          Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                        EndIf
                        ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                        ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                        ;PrintN("****************************")   
                        ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                        winset=1
                        isequil=0
                        Break               
                       
                      Else
                       
                        
                       ; PrintN("False collision")
                        ;PrintN(">"+Curve::m_gethex32(*tempor)) 
                        ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                        ;PrintN(Curve::m_gethex32(TestPUB\x))
                        winset=0
                        isequil=0
                      EndIf
                      
                    EndIf
                
                
              Else
                ;maybe under zero?
                a$=RSet(Hex(winpubid+1), 64,"0")
                Curve::m_sethex32(*tempor, @a$ )    
                ;***
                Curve::m_addModX64(*tempor,*tempor,*CenterBig,*Curveqn)
                ;***
                Curve::m_subModX64(*tempor,*tempor,*MylocalPrk,*Curveqn)
                Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                If Curve::m_check_equilX64(FINDPUBG\x,TestPUB\x)=1
                  
                  If Curve::m_check_equilX64(FINDPUBG\y,TestPUB\y)=0
                    ;Print("<*>")
                    Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                  EndIf 
                  Curve::m_addModX64(*tempor,*PrivBIG,*tempor,*Curveqn) 
                  Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                  If Curve::m_check_equilX64(REALPUB\x,TestPUB\x)=1
                      
                      If Curve::m_check_equilX64(REALPUB\y,TestPUB\y)=0
                        ;Print("<*>")
                        Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                        Curve::m_PTMULX64(TestPUB\x, TestPUB\y, *CurveGX, *CurveGY, *tempor,*CurveP)
                      EndIf
                      ;PrintN("KEY["+Str(listpos)+"]: 0x"+Curve::m_gethex32(*tempor)) 
                      ;PrintN(RSet("Pub: ",Len("KEY["+Str(listpos)+"]: ")," ")+uncomressed2commpressedPub(Curve::m_gethex32(TestPUB\x)+ Curve::m_gethex32(TestPUB\y)))
                      ;PrintN("****************************")   
                      ;PrintN("Found in "+Str(Date()-starttime)+" segundos")
                      winset=1
                      isequil=0
                      Break               
                     
                    Else
                      
                      ;Print("<*>")
                      Curve::m_subModX64(*tempor,*Curveqn,*tempor,*Curveqn)
                      
                      ;PrintN("False collision")
                      ;PrintN(">"+Curve::m_gethex32(*tempor)) 
                      ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                      ;PrintN(Curve::m_gethex32(TestPUB\x))
                      winset=0
                      isequil=0
                    EndIf
                Else
                  ;PrintN("False collision")
                  ;PrintN(Curve::m_gethex32(FINDPUBG\x))
                  ;PrintN(Curve::m_gethex32(TestPUB\x))
                  winset=0
                  isequil=0
                EndIf
                
                
              EndIf
            Else
              Exit("  Something wrong with calculation")
              
            EndIf
            
    
  EndIf
  
    If endrangeflag
      If Curve::m_check_less_more_equilX64(*MylocalPrk, *WidthRange )=2
        ;PrintN("GPU#"+Str(gpuid)+" Reached end of space")
        PokeQ(*MylocalPrk+32,0)
        Break
      EndIf
    EndIf 
    GetJob(*MylocalPrk, MylocalPUB\x, MylocalPUB\y)
    Curve::m_addX64(*counterBig, *counterBig,*batch)
    
     
Until winset Or quit

If winset
  CopyMemory(*tempor,*WINKEY,32)
EndIf

LockMutex(keyMutex)
isruning-1
UnlockMutex(keyMutex)
If winset
  quit=1
EndIf

While isreadyjob
  Delay(1)
Wend
Print("  GPU "+Str(gpuid)+L("gpu_jobs")) : ConsoleColor(10, 0) : PrintN(L("finished")) : ConsoleColor(7, 0)

Until globalquit

cuMemFree_v2(DeviceReturnNumberUnAlign)
cuCtxDestroy_v2(CudaContext)
FreeMemory(*batch)
FreeMemory(*r)
FreeMemory(*counterBig)
FreeMemory(*counterBigTemp)
FreeMemory(*tempor)
FreeMemory(MylocalPUB\x)
FreeMemory(MylocalPUB\y)
FreeMemory(TestPUB\x)
FreeMemory(TestPUB\y)
FreeMemory(*PRKADD)
FreeMemory(*a)
FreeMemory(*b)
FreeMemory(*c)
FreeMemory(*temper)


Print("  GPU "+Str(gpuid)+L("gpu_threads")) : ConsoleColor(10, 0) : PrintN(L("finished")) : ConsoleColor(7, 0)
EndProcedure

Procedure packHTGPU()   
  Protected *ptr, i, j, hash, res.HashTableResultStructure, offset, counter
  Shared *Table, *GpuHT, *PointerTable, HT_items, HT_total_items , HT_mask 
  ;for GPU we do not store xpoint position, only xpoint
  CopyMemory(*Table, *GpuHT, HT_items*#HashTablesz)
  *ptr=*GpuHT+HT_items*#HashTablesz
  counter=0
  For i =0 To HT_items-1 
    hash = ValueL(@i) & HT_mask   
    res\size = ValueL(*Table + hash * #HashTablesz)
    
    If res\size>0
      offset = hash*#Pointersz  
      res\contentpointer = PeekI(*PointerTable + offset) 
      For j = 0 To res\size-1
        CopyMemory(res\contentpointer + j*#HashTableSizeItems, *ptr + counter * #HashTableSizeHash + j*#HashTableSizeHash,  #HashTableSizeHash)
      Next j
      
      PokeL (*GpuHT + hash * #HashTablesz+4, counter) 
      ;PrintN("Hash:" +Str(hash)+" sz:"+Str(res\size)+ "offset: "+Str(*ptr-*GpuHT))
      counter+res\size
    EndIf
  Next i
EndProcedure

Procedure LOAD_HTGPUpacked(*xpoint)
  Protected i,j, filebinname$, full_size, len=8, hash.s, *pp, counters, totalpos, jobcomplete.d, prejobcomplete.d, wrbytes, savedbytes, maxsavebytes, loadedbytes, starttime
  Protected totalloadbytes, maxloadbytes, Yoffset, w$
  Shared *GpuHT, *GpuHT_unalign, *PointerTable_unalign, *PointerTable,  waletcounter, HT_items, *Table, *Table_unalign, *BabyArr, *BabyArr_unalign, *CurveGX, *CurveGY

  
    
  filebinname$=Curve::m_gethex32(*xpoint)+"_"+Str(waletcounter)+"_"+Str(HT_items)+"_htGPU.BIN"
  
  
  If FileSize(filebinname$) >0
    
    full_size= HT_items*#HashTablesz + waletcounter * #HashTableSizeHash
    *GpuHT_unalign=AllocateMemory(HT_items*#HashTablesz + #align_size + waletcounter * #HashTableSizeHash)
    If *GpuHT_unalign=0
      PrintN("  Nao foi possivel alocar memoria HTCPUpacked")
      exit("")
    EndIf
    *GpuHT=*GpuHT_unalign+#align_size-(*GpuHT_unalign % #align_size)
    
    If OpenFile(0,filebinname$,#PB_File_NoBuffering)   
      ;Load BIN if exist
      Print(L("load_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$) : ConsoleColor(7, 0)  
      totalloadbytes=0
      maxloadbytes=full_size
      If full_size>1024*1024*1024
        maxloadbytes = 1024*1024*1024
      EndIf
      *pp=*GpuHT
      i=0
      Repeat
        ;PrintN("  ["+Str(i)+"] chunk:"+Str(maxloadbytes)+"b")
        loadedbytes=ReadData(0, *pp, maxloadbytes)
        totalloadbytes + maxloadbytes
        
        If maxloadbytes<>loadedbytes
          Print(L("err_loading")+Str(maxloadbytes)+"b, got:"+Str(loadedbytes)+"b")
          CloseFile(0)
          exit("")
        EndIf
        
        *pp+maxloadbytes
        
        If totalloadbytes<full_size
          If totalloadbytes+maxloadbytes>full_size
            maxloadbytes = full_size-totalloadbytes
            ;PrintN("  Last chunk:"+Str(maxloadbytes)+"b")
          EndIf
        EndIf
        
        
        i+1
      Until totalloadbytes>=full_size
    
      
      CloseFile(0)
      
    Else
      exit(L("cant_open_file")+filebinname$)
    EndIf 
  Else
    exit("  File : "+filebinname$+" does not exist")
  EndIf
 
  
EndProcedure



