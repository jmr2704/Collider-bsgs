Procedure checkSortedArray(*arr,totallines,len=32)
  
  Protected i,rescmp, err
  Protected *min=AllocateMemory(len)
  
  
  ;set zero as min
  FillMemory(*min, len)
  
  For i=0 To totallines-1
    ;0 - s = t, 1- s < t, 2- s > t
    ;PrintN("0x"+getStrfrombin(*arr+i*len,len))
    
    ;get min
    rescmp = m_check_less_more_equilX8(*arr+i*len,*min)
    ;PrintN("rescmp:"+Str(rescmp))
    If rescmp=2;more
      CopyMemory(*arr+i*len, *min, len)    
    Else
      PrintN("Warning!!!")
      PrintN("min set : "+m_gethex8(*min))
      Print("  value : ") : ConsoleColor(10, 0) : PrintN(m_gethex8(*arr+i*len)) : ConsoleColor(7, 0)
      err=i+1
      Break
    EndIf
  Next i
  FreeMemory(*min)
  If err
    PrintN("Value ["+Str(err-1)+"] is Not sorted!!!") 
  EndIf
  ProcedureReturn err   
  
EndProcedure

Procedure sortinghash(id)  
  Protected *arrPointer, *arrPointer_sorted, len=8
  Protected *min=AllocateMemory(len), *max=AllocateMemory(len)
  Protected err, i, rescmp, pos
  Protected res.comparsationStructure
  Shared sortjob.sortjobStructure()
  Shared keyMutex, totallaunched
  
  *arrPointer = sortjob(Str(id))\ptarr
  *arrPointer_sorted = sortjob(Str(id))\sortptarray
  CopyMemory(*arrPointer, *min, len)
  
  ;prntarr("",sortjob(Str(id))\ptarr, sortjob(Str(id))\totallines)
  
  ;PrintN("Total points in Array:"+Str(sortjob(Str(id))\totallines))
  ;first find min value
   
  findMinMax8(*arrPointer,sortjob(Str(id))\totallines, *min,*max)   
  pos=0
  CopyMemory(*min, *arrPointer_sorted+pos*len, len)
  PrintN("MIN:0x"+m_gethex8(*arrPointer_sorted))
  Print("Sorting")
  For i=0 To sortjob(Str(id))\totallines-1
    If Not i%1000
      Print(".")
    EndIf
    foundinarr8(*arrPointer+i*len, sortjob(Str(id))\sortptarray, 0, pos, @res.comparsationStructure)
    ;PrintN("("+res\pos+","+res\direction+")")
    If res\pos=-1
      ;that mean that value is Not found in range
      If res\direction>pos
        pos=res\direction
        CopyMemory(*arrPointer+i*len, *arrPointer_sorted+pos*len, len)
      Else
        ;move block forward
        ;PrintN("move block")
        pos+1
        CopyMemory(*arrPointer_sorted+res\direction*len, *arrPointer_sorted+res\direction*len+len, (pos-res\direction)*len)
        CopyMemory(*arrPointer+i*len, *arrPointer_sorted+res\direction*len, len)
      EndIf
    Else
      ;PrintN("Warning!!!>"+getStrfrombin(*arrPointer+i*len,len))
    EndIf
    ;prntarr("",sortjob(Str(id))\sortptarray, sortjob(Str(id))\totallines)
  Next i
  
  
  FreeMemory(*min)
  LockMutex(keyMutex)
    totallaunched-1
    PrintN("Sort thread id:"+Str(id)+" ended")
  UnlockMutex(keyMutex)
EndProcedure

Procedure sortinghashMinMax(id)  
  Protected *arrPointer, *arrPointer_sorted, len=8, msg$="["+Str(id)+"] ", counters,init, persent.d,curprocent.d
  Protected *min=AllocateMemory(len)
  Protected *max=AllocateMemory(len)
  Protected err, i, rescmp, pos
  Protected res.comparsationStructure
  Shared sortjob.sortjobStructure()
  Shared keyMutex, totallaunched
  Shared waletcounter
  
  *arrPointer = sortjob(Str(id))\ptarr
  *arrPointer_sorted = sortjob(Str(id))\sortptarray
  
  CopyMemory(*arrPointer_sorted, *min, len)  
  CopyMemory(*arrPointer_sorted+len, *max, len)
  FillMemory(*arrPointer_sorted, len*2)
  
  counters = sortjob(Str(id))\totallines  
    
  ;PrintN(msg$+"Total points in Source Array: "+Str(totallines))
  ;PrintN(msg$+"MIN: "+getStrfrombin(*min,len))
  ;PrintN(msg$+"MAX: "+getStrfrombin(*max,len))
  
   
  ;PrintN(msg$+"Total items: "+Str(counters))
   
    
  pos=0   
  init=0
  persent=0
  curprocent=0
  ;PrintN(msg$+"Sorting")
  For i=0 To waletcounter-1
    If Not isInRange8(*arrPointer+i*len,*min,*max)
      ;skip values that is out of range
      Continue
    EndIf
    If init=0
      ;initial
      CopyMemory(*arrPointer+i*len, *arrPointer_sorted+pos*len, len)
      ;PrintN(msg$+"II: "+getStrfrombin(*arrPointer_sorted+pos*len))
      init=1
      Continue
    EndIf  
    
    curprocent = pos*100/counters
    If curprocent-persent>0.5
      persent = curprocent
      sortjob(Str(id))\curpos = pos
      ;PrintN(msg$+"Sorting:"+Str(persent)+"%") : ConsoleColor(7, 0)
    EndIf
    
    ;PrintN(msg$+">>: "+getStrfrombin(*arrPointer+i*len))
    foundinarr8(*arrPointer+i*len, *arrPointer_sorted, 0, pos, @res.comparsationStructure)
    ;PrintN(msg$+"("+res\pos+","+res\direction+")")
    If res\pos=-1
      ;that mean that value is Not found in range
      If res\direction>pos
        pos=res\direction
        CopyMemory(*arrPointer+i*len, *arrPointer_sorted+pos*len, len)
      Else
        ;move block forward
        ;PrintN(msg$+"move block")
        pos+1
        CopyMemory(*arrPointer_sorted+res\direction*len, *arrPointer_sorted+res\direction*len+len, (pos-res\direction)*len)
        CopyMemory(*arrPointer+i*len, *arrPointer_sorted+res\direction*len, len)
      EndIf
    Else
      PrintN(msg$+"Warning!!!>"+m_gethex8(*arrPointer+i*len))
    EndIf
    ;prntarr("",sortjob(Str(id))\sortptarray, counters)
  Next i
  
    
  FreeMemory(*min)
  FreeMemory(*max)
  LockMutex(keyMutex)
    totallaunched-1
    ;PrintN("Sort thread id:"+Str(id)+" ended")
  UnlockMutex(keyMutex)
EndProcedure

Procedure SortingArrays(totalthread, *xpoint)
  Protected sortbatchperthr, sortrest, i,j, multimode, filebinname$, full_size, len=8, hash.s, *pp, counters, totalpos, jobcomplete.d, prejobcomplete.d, wrbytes, savedbytes, maxsavebytes, loadedbytes
  Protected totalloadbytes, maxloadbytes, A$
  Shared sortjob.sortjobStructure()  
  Shared totallaunched
  Shared mainpub
  Shared *BabyArr, *BabyArrSorted, *BabyArrSorted_unalign
  Shared waletcounter
  
  Protected *min, *max, *TotalRange, *A, *B, *Q8,*R8, *rb8, *re8
  
  *BabyArrSorted_unalign=AllocateMemory((waletcounter+1)*8 + #align_size)
  If *BabyArrSorted_unalign=0
    PrintN("  Nao foi possivel alocar memoria for sorted baby array")
    exit("")
  EndIf
  *BabyArrSorted=*BabyArrSorted_unalign+#align_size-(*BabyArrSorted_unalign % #align_size)


  *min=AllocateMemory(176)
  If *min=0
     PrintN(L("cant_alloc_mem"))
    exit("")
  EndIf
  *max = *min + 8
  *TotalRange = *max+8
  *A= *TotalRange + 32
  *B= *A + 32
  *Q8= *B + 32
  *R8= *Q8 + 8
  *rb8=*R8+8
  *re8=*rb8+8
  
  filebinname$=Curve::m_gethex32(*xpoint)+"_"+Str(waletcounter)+"_s.BIN"
  full_size=waletcounter*len
  
  If FileSize(filebinname$+"_htGPU.BIN") <= 0
    ; file does not exist    
    ;sort
    If waletcounter>totalthread*2 And totalthread>1
      multimode=1
    EndIf
    
    ;multimode=0; just for test
    
    
    
    
    If multimode
      PrintN("  Sorting Babys Array ["+Str(waletcounter)+"] with ["+Str(totalthread)+"] threads")
      
      ;prntarr("",*Arraypt, maxnonce)
    
      findMinMax8(*BabyArr,waletcounter, *min,*max)      
      
      
      PrintN("  MIN: "+m_gethex8(*min) )
      PrintN("  MAX: "+m_gethex8(*max) )
      
      sub8(*max,*min,*TotalRange)
      
      
      PrintN("  TOTAL RANGE: "+m_gethex8(*TotalRange))
            
      div8(*TotalRange,8,*Q8,*R8)      
      PrintN("  RANGE PER THREAD: "+m_gethex8(*Q8))
      
      CopyMemory(*max, *R8,8);temporary save
      
      CopyMemory(*min, *rb8,8)
      add8(*rb8,*Q8, *re8 )
      
      *pp=*BabyArrSorted 
      totallaunched=0
      For i=0 To totalthread-2
        PrintN("  RANGE ["+Str(i)+"]")
        PrintN("  FROM "+m_gethex8(*rb8))
        PrintN("  TO "+m_gethex8(*re8))
        
        ;copy rangeB to temporary array
        CopyMemory(*rb8, *min,8)
        ;copy rangeE to temporary array
        CopyMemory(*re8, *max,8)
        
        ;first need count items for our thread
        counters=0
        For j=0 To waletcounter-1    
          If isInRange8(*BabyArr+j*len,*min,*max)
            counters+1
          EndIf
        Next j
        
        sortjob(Str(i))\ptarr = *BabyArr
        sortjob(Str(i))\sortptarray = *pp
        sortjob(Str(i))\totallines = counters
        
        ;copy rangeB to destination array
        CopyMemory(*min, *pp, len)
        ;copy rangeE to destination array
        CopyMemory(*max, *pp+len, len)
        
        If CreateThread(@sortinghashMinMax(),i)
          totallaunched+1
        EndIf
        add8ui(*re8,1, *rb8 )
        add8(*re8,*Q8, *re8 )
        
        
        *pp+counters*len
        
        ;prntarr("",sortjob(Str(i))\sortptarray, sortjob(Str(i))\totallines)
      Next i
      ;last thread
      CopyMemory(*R8, *re8,8)
      
      ;copy rangeB to temporary array
        CopyMemory(*rb8, *min,8)
        ;copy rangeE to temporary array
        CopyMemory(*re8, *max,8)
      
      ;first need count items for our thread
      counters=0
      For j=0 To waletcounter-1    
        If isInRange8(*BabyArr+j*len,*min,*max)
          counters+1
        EndIf
      Next j  
      
      sortjob(Str(i))\ptarr = *BabyArr
      sortjob(Str(i))\sortptarray = *pp
      sortjob(Str(i))\totallines = counters
       
      ;copy rangeB to destination array
      CopyMemory(*min, *pp, len)
      ;copy rangeE to destination array
      CopyMemory(*max, *pp+len, len)
      
      PrintN("  RANGE ["+Str(i)+"]")
      PrintN("  FROM "+m_gethex8(*rb8))
      PrintN("  TO "+m_gethex8(*re8))
        
      If CreateThread(@sortinghashMinMax(),i)
        totallaunched+1
      EndIf
      
      Print("  Sorting Babys Array>00%")
      While totallaunched
        ;while waitin print persantage
        totalpos=0
        For i=0 To totalthread-1
          totalpos +sortjob(Str(i))\curpos
        Next i
        
        jobcomplete = totalpos*100/waletcounter
        If jobcomplete-prejobcomplete>=1          
          Print(Chr(8)+Chr(8)+Chr(8)+RSet(StrD(jobcomplete,0), 2)+"%") : ConsoleColor(7, 0)
          prejobcomplete=jobcomplete
        EndIf
        Delay(50)
      Wend
    Else
      PrintN("  Sorting Babys Array ["+Str(waletcounter)+"] with [1] thread")
      sortjob(Str(0))\ptarr = *BabyArr
      sortjob(Str(0))\sortptarray = *BabyArrSorted
      sortjob(Str(0))\totallines = waletcounter
      sortinghash(0)
    EndIf
    
    ;********************************
    For i = 0 To waletcounter-1
      toLittleInd32_64(*BabyArrSorted+i*8) 
    Next i
    ;********************************
     ;Saving BIN FILE
    Print(L("save_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$) : ConsoleColor(7, 0)
    savedbytes=0
    maxsavebytes=full_size
    If full_size>1024*1024*1024
      maxsavebytes = 1024*1024*1024
    EndIf
    *pp=*BabyArrSorted
    
    If CreateFile(0,filebinname$+"_htCPU.BIN")
      i=0
      Repeat
      ;PrintN("  ["+Str(i)+"] chunk:"+Str(maxsavebytes)+"b")
      wrbytes =WriteData(0, *pp, maxsavebytes) 
      savedbytes + maxsavebytes
      
      If maxsavebytes<>wrbytes
        Print(L("err_saving")+Str(maxsavebytes)+"b, got:"+Str(wrbytes)+"b")
        CloseFile(0)
        exit("")
      EndIf
      
      *pp+maxsavebytes
      
      If savedbytes<full_size
        If savedbytes+maxsavebytes>full_size
          maxsavebytes = full_size-savedbytes
          ;PrintN("  Last chunk:"+Str(maxsavebytes)+"b")
        EndIf
        
      EndIf
      i+1
      Until savedbytes>=full_size
      CloseFile(0) 
      Print(L("saved")) : ConsoleColor(10, 0) : PrintN(Str(savedbytes)+" bytes") : ConsoleColor(7, 0) : ConsoleColor(7, 0)
    Else
      Debug "  May not create the file!"
    EndIf
  Else
    If OpenFile(0,filebinname$,#PB_File_NoBuffering)   
      ;Load BIN if exist
      Print(L("load_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$) : ConsoleColor(7, 0)  
      totalloadbytes=0
      maxloadbytes=full_size
      If full_size>1024*1024*1024
        maxloadbytes = 1024*1024*1024
      EndIf
      *pp=*BabyArrSorted
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
  EndIf
  
  ;********************************
    For i = 0 To waletcounter-1
      toLittleInd32_64(*BabyArrSorted+i*8) 
    Next i
    ;********************************
  FreeMemory(*min)

EndProcedure

Procedure findsolution(*solution, *arr, linestotal, len=16)
  Protected result=-1, i
  For i =0 To linestotal-1
    If check_equil(*solution,*arr+i*len,len/4)
      result=i
      Break
    EndIf
  Next i
ProcedureReturn result
EndProcedure

Procedure HashTableInsert(*hash, position)  
  Protected *a=AllocateMemory(4), offset, hashcut, val, *pointer, sz, *contentpointer
  Shared HTMutex(), HTHeaps(), HTCountMutex, *Table, *PointerTable, HT_mask, HT_total_hashes, HT_items_with_collisions, HT_max_collisions, HT_total_items, initHTsize
  
  ;PrintN("hash insert>"+m_gethex8(*hash))
  
  hashcut = ValueL(*hash) & HT_mask 
  *pointer = *Table + hashcut*#HashTablesz
  
  LockMutex(HTMutex(hashcut & 255))
  
  sz = ValueL(*pointer)
  offset = hashcut*#Pointersz
  If sz = 0
     
    *contentpointer = HeapAlloc_(HTHeaps(hashcut & 255), 0, #HashTableSizeItems * initHTsize)
    If Not *contentpointer     
      exit("  Nao foi possivel alocar memoria in Heap")
    EndIf
    ;PrintN("Hash #"+Hex(hashcut)+" "+Str(*contentpointer))   
    ;store new pointer to PointTable
    PokeI(*PointerTable+offset, *contentpointer) 
    ;store part of hash
    CopyMemory(*hash+4, *contentpointer, #HashTableSizeHash)
    PokeL(*contentpointer+#HashTableSizeHash,position)
    ;increase counter
    INCvalue32(*pointer)
    HT_total_hashes + 1
  Else
    ;PrintN("Hash #"+Hex(hashcut)+" has "+Str(sz)+" items")
    ;PrintN("Need realocate")
    *contentpointer = PeekI(*PointerTable+offset)
    If sz>=initHTsize
      *contentpointer = HeapReAlloc_(HTHeaps(hashcut & 255), 0, *contentpointer, (sz+1)*#HashTableSizeItems)
      If Not *contentpointer     
        exit("  Can`t reallocate memory in Heap")
      EndIf      
      ;store new pointer to PointTable
      PokeI(*PointerTable+offset, *contentpointer) 
       
    EndIf
    CopyMemory(*hash+4, *contentpointer+ sz*#HashTableSizeItems, #HashTableSizeHash)
    PokeL(*contentpointer+ sz*#HashTableSizeItems+#HashTableSizeHash,position)
    ;increase counter
    INCvalue32(*pointer)
    
    HT_items_with_collisions + 1
    If ValueL(*pointer)>HT_max_collisions
      HT_max_collisions = ValueL(*pointer)
    EndIf
  EndIf
  
  
  HT_total_items+1  
  UnlockMutex(HTMutex(hashcut & 255)) 
  FreeMemory(*a)
EndProcedure

Procedure HashTableRead(*hash, *res.HashTableResultStructure)  
  Protected offset, hash
  Shared *Table, *PointerTable, HT_mask
  
  hash = ValueL(*hash) & HT_mask   
  *res\size = ValueL(*Table + hash * #HashTablesz)
  offset = hash*#Pointersz  
  *res\contentpointer = PeekI(*PointerTable + offset)
  ;PrintN("Hash:" +Str(hash)+" sz:"+Str(*res\size))
EndProcedure

Procedure HashTableSammary() 
  Protected totalbytes
  Shared HT_total_items, HT_total_hashes, HT_max_collisions, HT_items_with_collisions, HT_mask, HT_items, HT_POW
  PrintN("  ----------HashTable Info----------")
  Print(L("table_size")) : ConsoleColor(10, 0) : PrintN("2^"+Str(HT_POW)+"x"+Str(#HashTablesz)+"="+Str(HT_items * #HashTablesz)+" bytes") : ConsoleColor(7, 0)
  Print(L("table_mask")) : ConsoleColor(10, 0) : PrintN(Hex(HT_mask)) : ConsoleColor(7, 0)
  Print(L("table_used")) : ConsoleColor(10, 0) : PrintN(StrD(HT_total_hashes*100/HT_items,2)+"%") : ConsoleColor(7, 0)
  Print(L("total_uniq_hex")) : ConsoleColor(10, 0) : PrintN(Str(HT_total_hashes)+" = "+StrD(HT_total_hashes*100/HT_total_items,1)+"%") : ConsoleColor(7, 0)
  Print(L("total_hashes")) : ConsoleColor(10, 0) : PrintN(Str(HT_total_items)+"="+Str(HT_total_items)+"x"+Str(#HashTableSizeItems)+"="+Str(HT_total_items * #HashTableSizeItems)+" bytes") : ConsoleColor(7, 0)
  totalbytes = HT_total_items*#HashTableSizeItems + HT_items * #HashTablesz
  Print(L("total")) : ConsoleColor(10, 0) : PrintN(Str(totalbytes)+" bytes = "+StrD(totalbytes/1024/1024,1)+"Mb") : ConsoleColor(7, 0)
  Print(L("total_cols")) : ConsoleColor(10, 0) : PrintN(Str(HT_items_with_collisions)+" = "+StrD(HT_items_with_collisions*100/HT_total_items,1)+"%") : ConsoleColor(7, 0)
  Print(L("max_cols")) : ConsoleColor(10, 0) : PrintN(Str(HT_max_collisions)) : ConsoleColor(7, 0)
  PrintN("  ----------------------------------")
  
  ProcedureReturn HT_total_items*#HashTableSizeItems+HT_total_hashes * #HashTablesz
EndProcedure

Global Dim HTProgress.i(256)

Structure GenHT_Param
  thread_id.i
  start_idx.i
  end_idx.i
EndStructure

Procedure GenHashTable_Thread(*p.GenHT_Param)
  Protected i, *ponter, t_id
  Shared *BabyArr
  t_id = *p\thread_id
  *ponter = *BabyArr + (*p\start_idx * 8)
  For i = *p\start_idx To *p\end_idx
    HashTableInsert(*ponter, i)
    *ponter + 8
    HTProgress(t_id) + 1
  Next i
  FreeMemory(*p)
EndProcedure


  
  For i = 0 To 255
    HTHeaps(i) = HeapCreate_(0, 0, 0)
  Next i
Procedure GenHashTable()
  Protected i, num_threads, items_per_thread, *p.GenHT_Param, sum.q, persent.i
  Protected Dim threads(0)
  Shared waletcounter
  num_threads = CountCPUs(#PB_System_ProcessCPUs)
  If num_threads < 1 : num_threads = 1 : EndIf
  Print(L("add_babys_ht")+Str(num_threads)+" threads...00%")
  
  Dim threads(num_threads)
  items_per_thread = waletcounter / num_threads
  
  For i = 0 To num_threads - 1
    HTProgress(i) = 0
    *p = AllocateMemory(SizeOf(GenHT_Param))
    *p\thread_id = i
    *p\start_idx = i * items_per_thread
    If i = num_threads - 1
      *p\end_idx = waletcounter - 1
    Else
      *p\end_idx = ((i + 1) * items_per_thread) - 1
    EndIf
    threads(i) = CreateThread(@GenHashTable_Thread(), *p)
  Next i
  
  Repeat
    Delay(200)
    sum = 0
    For i = 0 To num_threads - 1
      sum = sum + HTProgress(i)
    Next i
    If sum > 0
      persent = (sum * 100) / waletcounter
      Print(Chr(8)+Chr(8)+Chr(8)+RSet(Str(persent), 2, "0")+"%") : ConsoleColor(7, 0)
    EndIf
  Until sum >= waletcounter
  
  For i = 0 To num_threads - 1
    WaitThread(threads(i))
  Next i
  PrintN(Chr(8)+Chr(8)+Chr(8)+"100%")
EndProcedure


Procedure findInHashTable32bit(*findvalue, *arr, beginrange, endrange, *res.comparsationStructure)
  Protected temp_beginrange, temp_endrange, rescmp,   exit.b, center
  
  temp_beginrange = beginrange
  temp_endrange = endrange

  While (endrange-beginrange)>=0
    If beginrange=endrange
      If endrange<=temp_endrange
        ;0 - s = t, 1- s < t, 2- s > t
        rescmp = check_LME32bit(*findvalue,*arr + beginrange * #HashTableSizeItems)
        ;Debug "cmp "+get64bithash(*findvalue)+" - "+get64bithash(*arr + beginrange * #HashTableSizeItems)+" = "+Str(rescmp)
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
        Debug("  Unknown exeptions")        
      EndIf
    EndIf
    center=(endrange-beginrange)/2+beginrange    
    rescmp = check_LME32bit(*findvalue,*arr + center * #HashTableSizeItems)
    ;Debug "cmp "+get64bithash(*findvalue)+" - "+get64bithash(*arr + beginrange * #HashTableSizeItems)+" = "+Str(rescmp)
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

Procedure findInHashTable32bitSimple(*findvalue, *arr, beginrange, endrange, *res.comparsationStructure)
  Protected temp_beginrange, temp_endrange, rescmp,   exit.b, center
  
  *res\pos=-1
  While endrange>=beginrange   
    center= beginrange+(endrange-beginrange)/2
    rescmp = check_LME32bit(*findvalue,*arr + center * #HashTableSizeItems)   
    If rescmp=2;more
      beginrange=center+1
    ElseIf rescmp=1;less
      endrange=center-1
    Else ;equil
      *res\pos=center
      Break
    EndIf     
  Wend 
EndProcedure

Procedure sortHashTable32bit(*arr, totalines)
  Protected err, i, rescmp,*temp, *INShash,pos, res.comparsationStructure
  *temp=AllocateMemory(#HashTableSizeItems)
  Shared HTMutex(), HTHeaps(), HTCountMutex
  
  pos = 0  
  LockMutex(HTCountMutex)
  While pos<totalines-1 And err=0
      *INShash = *arr+(pos+1) * #HashTableSizeItems
      findInHashTable32bit(*INShash, *arr, 0, pos, @res.comparsationStructure)
      ;Debug "pos:"+Str(pos)
      ;Debug get64bithash(*INShash)
      ;Debug "res\pos:"+Str(res\pos)+"res\dir:"+Str(res\direction)
      If res\pos=-1
        ;that mean that value is Not found in range
        If res\direction>pos
          pos=res\direction
          CopyMemory(*INShash, *arr + pos * #HashTableSizeItems, #HashTableSizeItems)       
        Else
          ;move block forward
          ;PrintN("move block")
          pos+1
          CopyMemory(*INShash, *temp, #HashTableSizeItems)
          CopyMemory(*arr + res\direction * #HashTableSizeItems, *arr + res\direction * #HashTableSizeItems + #HashTableSizeItems, (pos-res\direction) * #HashTableSizeItems)
          CopyMemory(*temp, *arr + res\direction * #HashTableSizeItems, #HashTableSizeItems)        
        EndIf
      Else
        err=1
      EndIf
      ;For i =0 To totalines-1
        ;Debug ("["+Str(i)+"] "+get64bithash(*arr + i * #HashTableSizeItems))  
      ;Next i
  Wend
  UnlockMutex(HTCountMutex)
  If err   
    PrintN(L("val_exist")+Hex(Valuel(*INShash)))
    For i =0 To totalines-1
      PrintN ("["+Str(i)+"] "+Hex(Valuel(*arr + i * #HashTableSizeItems))+" ("+Hex(Valuel(*arr + i * #HashTableSizeItems+#HashTableSizeHash))+")")  
    Next i
    exit(L("try_inc_htsz"))
  EndIf
  FreeMemory(*temp)
EndProcedure 

Procedure sortWholeHashTable(*arr, totalitems)
Protected i, res.HashTableResultStructure
  For i =0 To totalitems-1 
    HashTableRead(@i, @res) 
    If res\size    
      sortHashTable32bit(res\contentpointer, res\size)
    EndIf    
  Next i
EndProcedure

Procedure checkHashTableContent(*arr, contentsz)
  
  Protected i,rescmp, err
  Protected *min=AllocateMemory(#HashTableSizeHash)
  Shared HTMutex(), HTHeaps(), HTCountMutex
  
  ;set zero as min
  FillMemory(*min, #HashTableSizeHash)
  
  For i=0 To contentsz-1   
   
    rescmp = check_LME32bit(*arr + i * #HashTableSizeItems,*min)    
    If rescmp=2;more
      CopyMemory(*arr + i * #HashTableSizeItems, *min, #HashTableSizeHash)    
    Else
      If i<>0
        PrintN("  Warning!!!")
        Print("  min set : ") : ConsoleColor(10, 0) : PrintN(Hex(ValueL(*min))) : ConsoleColor(7, 0)
        Print("  value : ") : ConsoleColor(10, 0) : PrintN(Hex(ValueL(*arr + i * #HashTableSizeItems))) : ConsoleColor(7, 0)
        err=i
        Break
      EndIf
    EndIf
  Next i
  FreeMemory(*min)
  If err
    PrintN("  Values ("+Str(err)+") is Not sorted!!!")
    ProcedureReturn 1
  Else
    ProcedureReturn 0 ; no error
  EndIf 
  
EndProcedure

Procedure checkWholeHashTableContent()
  Protected  res.HashTableResultStructure, i, err
  Shared HT_items, HT_total_items
  
  For i =0 To HT_items-1 
    HashTableRead(@i, @res) 
    If res\size>1
      If checkHashTableContent(res\contentpointer, res\size)  
        ;if error
        err=1
        Break
      EndIf
    EndIf
  Next i
  
  If err
     PrintN("  false")  
   EndIf
   ProcedureReturn err
EndProcedure

Procedure compareWithHashtable(*hash)
  Protected  res.HashTableResultStructure, rescmp.comparsationStructure
  rescmp\pos=-1
  HashTableRead(*hash, @res) 
  ;PrintN( "cmp hash:"+m_gethex8(*hash))
  ;PrintN( "sz:"+Str(res\size))
  If res\size    
    findInHashTable32bitSimple(*hash+4, res\contentpointer, 0, res\size, @rescmp)
    ;PrintN("Content pos: "+Str(rescmp\pos))    
  EndIf
  ProcedureReturn rescmp\pos
EndProcedure

Procedure ReadHTpack(*hash, *arr, *res.HashTableResultStructure)  
  Protected offset, hash
  Shared HT_mask, HT_items
  
  hash = ValueL(*hash) & HT_mask   
  *res\size = ValueL(*arr + hash * #HashTablesz)  
  *res\contentpointer =*arr + HT_items * #HashTablesz + ValueL(*arr + hash * #HashTablesz+4) * #HashTableSizeItems
  ;PrintN("Hash:" +Str(hash)+" sz:"+Str(*res\size))
EndProcedure

Procedure compareHTpack(*hash)
  Protected  res.HashTableResultStructure, rescmp.comparsationStructure
  Shared *GpuHT
  rescmp\pos=-1
  ReadHTpack(*hash, *GpuHT, @res) 
  ;PrintN( "cmp hash:"+m_gethex8(*hash))
  ;PrintN( "sz:"+Str(res\size))
  If res\size
    findInHashTable32bitSimple(*hash+4, res\contentpointer, 0, res\size, @rescmp)
    ;PrintN("Content pos: "+Str(rescmp\pos)+", "+Str(ValueL(res\contentpointer+rescmp\pos*#HashTableSizeItems+#HashTableSizeHash))) 
    If rescmp\pos<>-1
      rescmp\pos=ValueL(res\contentpointer+rescmp\pos*#HashTableSizeItems+#HashTableSizeHash)
    EndIf
  EndIf
  ProcedureReturn rescmp\pos
EndProcedure

Procedure packHT()   
  Protected *ptr, i, hash, res.HashTableResultStructure, offset, counter
  Shared *Table, *GpuHT, *PointerTable, HT_items, HT_total_items , HT_mask 
  ;for CPU we store xpoint position and xpoint
  CopyMemory(*Table, *GpuHT, HT_items*#HashTablesz)
  *ptr=*GpuHT+HT_items*#HashTablesz
  counter=0
  For i =0 To HT_items-1 
    hash = ValueL(@i) & HT_mask   
    res\size = ValueL(*Table + hash * #HashTablesz)
    
    If res\size>0
      offset = hash*#Pointersz  
      res\contentpointer = PeekI(*PointerTable + offset)          
      CopyMemory(res\contentpointer, *ptr + counter * #HashTableSizeItems,  res\size*#HashTableSizeItems)
      PokeL (*GpuHT + hash * #HashTablesz+4, counter) 
      ;PrintN("Hash:" +Str(hash)+" sz:"+Str(res\size)+ "offset: "+Str(*ptr-*GpuHT))
      counter+res\size
    EndIf
  Next i
EndProcedure

Procedure checkHTpack(totalpoints, numberofrand=1024)
  Protected res=0,  randnum, a$, *bx= AllocateMemory(32), *by=AllocateMemory(32), *pos=AllocateMemory(32)
  Shared *CurveGX, *CurveGY,*CurveP
  If numberofrand<1024
    numberofrand=4096
  EndIf
  
  
  
  While numberofrand>0 And res=0
    randnum = Random(totalpoints-1,0)
    a$=RSet(Hex(randnum+1), 64,"0")
    Curve::m_sethex32(*pos, @a$ )
    ;PrintN("["+Str(randnum)+"] Est."+m_gethex8(*bx+24)) 
    Curve::m_PTMULX64(*bx, *by, *CurveGX, *CurveGY, *pos,*CurveP)
    If compareHTpack(*bx+24)=-1
      PrintN("  false")
      PrintN("  ["+Str(numberofrand)+"]["+Str(randnum)+"] Est."+m_gethex8(*bx+24))     
      res=1
      Break
    EndIf
    numberofrand-1
  Wend  
  
    FreeMemory(*bx)
    FreeMemory(*by)
    FreeMemory(*pos)
  ProcedureReturn res
EndProcedure

Procedure checkWholeHashTableContentPack(*arr)
  Protected  res.HashTableResultStructure, i, err
  Shared HT_items, HT_total_items
  
  For i =0 To HT_items-1 
    ReadHTpack(@i, *arr, @res) 
    If res\size>1
      If checkHashTableContent(res\contentpointer, res\size)  
        ;if error
        err=1
        Break
      EndIf
    EndIf
  Next i
  
  If err
     PrintN("  false")  
   EndIf
   ProcedureReturn err
 EndProcedure

 Procedure RemoveTempHashTable()   
  Protected i
  Shared *Table_unalign, *PointerTable_unalign, HTHeaps()
  
  PrintN(L("dest_heaps"))
  For i = 0 To 255
    If HTHeaps(i)
      HeapDestroy_(HTHeaps(i))
    EndIf
  Next i
  
  FreeMemory(*Table_unalign) 
  FreeMemory(*PointerTable_unalign) 
  PrintN(L("rm_temp_ht"))
EndProcedure

Procedure checkHT( totalpoints, numberofrand=1024)
  Protected res=0,  randnum, a$, *b= AllocateMemory(32)
  Shared *BabyArr
  If numberofrand<1024
    numberofrand=4096
  EndIf
  
  a$=RSet("0000000000000000", 64,"0")
  Curve::m_sethex32(*b, @a$ )
  
  While numberofrand>0 And res=0
    randnum = Random(totalpoints-1,0)
   
    If compareWithHashtable(*BabyArr+randnum*8)=-1
      PrintN("  false")
      PrintN("  ["+Str(numberofrand)+"]["+Str(randnum)+"] Est."+m_gethex8(*BabyArr+randnum*8))     
      res=1
      Break
    EndIf
    numberofrand-1
  Wend  
  If compareWithHashtable(*b)<>-1
      PrintN("  false")
      PrintN("  ["+Str(numberofrand)+"]Est."+m_gethex8(*BabyArr+randnum*8))     
      res=1
    EndIf
    FreeMemory(*b)
  ProcedureReturn res
EndProcedure

Procedure Save_HTpacked(*xpoint)
  Protected i,j, filebinname$, full_size, len=8, hash.s, *pp, counters, totalpos, jobcomplete.d, prejobcomplete.d, wrbytes, savedbytes, maxsavebytes, loadedbytes, starttime
  Protected totalloadbytes, maxloadbytes, Yoffset, w$, ramneed1, ramneed2
  Shared *CpuHTPacked, *CpuHTPacked_unalign, *GpuHT, *GpuHT_unalign, *PointerTable_unalign, *PointerTable,  waletcounter, HT_items, *Table, *Table_unalign, *BabyArr, *BabyArr_unalign, *CurveGX, *CurveGY

  
    
  filebinname$=Curve::m_gethex32(*xpoint)+"_"+Str(waletcounter)+"_"+Str(HT_items)
  
  
  If FileSize(filebinname$+"_htCPU.BIN") <= 0
    ; file does not exist    
     ramneed1 = (waletcounter+1)*8 + #align_size ;baby array
     ramneed1 + HT_items*#HashTablesz +#align_size + waletcounter*#Pointersz +#align_size + waletcounter*#HashTableSizeItems +#align_size;HT unpacked
     ;Debug "ramneed:"+StrD((ramneed1)/1024/1024,3)
     ramneed2 = HT_items*#HashTablesz +#align_size + waletcounter*#Pointersz +#align_size + waletcounter*#HashTableSizeItems +#align_size;HT unpacked
     ramneed2 + HT_items*#HashTablesz +#align_size + waletcounter*#HashTableSizeItems +#align_size ;HTCPU packed
     ;Debug "ramneed:"+StrD((ramneed2)/1024/1024,3)
     If ramneed2>ramneed1
       ramneed1=ramneed2
     EndIf
     If MemoryStatus(#PB_System_FreePhysical)<ramneed1
       PrintN(L("warn_free_mem")+Str(ramneed1/1024/1024)+" MB of RAM")
       Delay(2000)
     Else
       PrintN("  Free RAM["+Str(MemoryStatus(#PB_System_FreePhysical)/1024/1024)+" MB], need["+Str(ramneed1/1024/1024)+" MB]")
     EndIf
    
    *Table_unalign=AllocateMemory(HT_items*#HashTablesz + #align_size)
    If *Table_unalign=0
      PrintN("  Nao foi possivel alocar memoria for HT("+Str((HT_items*#HashTablesz + #align_size))+")")
      exit("")
    EndIf
    PrintN(L("allocated")+Str(HT_items*#HashTablesz + #align_size)+") for HT")
    *Table=*Table_unalign+#align_size-(*Table_unalign % #align_size)
    
    *PointerTable_unalign=AllocateMemory(HT_items*#Pointersz + #align_size)
    If *PointerTable_unalign=0
      PrintN("  Nao foi possivel alocar memoria Pointer array for HT")
      exit("")
    EndIf
    *PointerTable=*PointerTable_unalign+#align_size-(*PointerTable_unalign % #align_size)
    
    ;Generate Babys points array AGAIN
      starttime= ElapsedMilliseconds()
      GenBabys(*CurveGX, *CurveGY)
      PrintN("  Done in "+FormatDate("%hh:%ii:%ss", (ElapsedMilliseconds()-starttime)/1000)+"s")
      CompilerIf #ENABLE_VERIFICATIONS
Print("  Verify baby array...")
      If checkBabyArr(*BabyArr, *CurveGX, *CurveGY, waletcounter, waletcounter/65536)=1  
        exit("")
      Else
        PrintN("  ok")
      EndIf
      CompilerEndIf
      
    GenHashTable()
    HashTableSammary()
    
    Print(L("sort_ht"))
    sortWholeHashTable(*Table, HT_items)
    PrintN("ok")
    
    CompilerIf #ENABLE_VERIFICATIONS
Print("  Verify HT sorting...")
    If checkWholeHashTableContent()=1  
      exit("")
    Else
      PrintN("  ok")
    EndIf
    
    CompilerEndIf
    
    CompilerIf #ENABLE_VERIFICATIONS
Print("  Verify HT items...")
    If checkHT(waletcounter, 1024)=1  
      exit("")
    Else
      PrintN("  ok")
    EndIf
    
    CompilerEndIf
    
    ;freed baby array, don`t need any more
    FreeMemory(*BabyArr_unalign)
    
    If FileSize(filebinname$+"_htGPU.BIN") <= 0
      ;create CPU file
      full_size= HT_items*#HashTablesz + waletcounter*#HashTableSizeItems
      *CpuHTPacked_unalign=AllocateMemory(HT_items*#HashTablesz + #align_size + waletcounter*#HashTableSizeItems)
      If *CpuHTPacked_unalign=0
        PrintN("  Nao foi possivel alocar memoria HTCPUpacked")
        exit("")
      EndIf
     *CpuHTPacked=*CpuHTPacked_unalign+#align_size-(*CpuHTPacked_unalign % #align_size)
      *GpuHT = *CpuHTPacked ; temporarily point so packHT writes to it
      Print(L("pack_htcpu"))
      packHT()
      PrintN("ok")
      ; Save file for CPU using
      ;Saving BIN FILE
      CompilerIf #ENABLE_VERIFICATIONS
Print(L("verify_htcpu"))
      If checkHTpack(waletcounter, 1024)=1
        exit("")
      Else
        PrintN("  ok")
      EndIf
      CompilerEndIf
      
      CompilerIf #ENABLE_VERIFICATIONS
Print(L("verify_htcpu_sort"))
      If checkWholeHashTableContentPack(*GpuHT)
       exit("")
      Else
        PrintN("  ok")
      EndIf
      
      CompilerEndIf
      
      Print(L("save_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$+"_htCPU.BIN") : ConsoleColor(7, 0)
      savedbytes=0
      maxsavebytes=full_size
      If full_size>1024*1024*1024
        maxsavebytes = 1024*1024*1024
      EndIf
      *pp=*GpuHT
      
      If CreateFile(0,filebinname$+"_htCPU.BIN")
        i=0
        Repeat
        ;PrintN("["+Str(i)+"] chunk:"+Str(maxsavebytes)+"b")
        wrbytes =WriteData(0, *pp, maxsavebytes) 
        savedbytes + maxsavebytes
        
        If maxsavebytes<>wrbytes
          Print(L("err_saving")+Str(maxsavebytes)+"b, got:"+Str(wrbytes)+"b")
          CloseFile(0)
          exit("")
        EndIf
        
        *pp+maxsavebytes
        
        If savedbytes<full_size
          If savedbytes+maxsavebytes>full_size
            maxsavebytes = full_size-savedbytes
            ;PrintN("  Last chunk: "+Str(maxsavebytes)+"b")
          EndIf
          
        EndIf
        i+1
        Until savedbytes>=full_size
        CloseFile(0) 
        Print(L("saved")) : ConsoleColor(10, 0) : PrintN(Str(savedbytes)+" bytes") : ConsoleColor(7, 0) : ConsoleColor(7, 0)
        
        
  
      Else
        Debug "  May not create the file!"
      EndIf
      ;FreeMemory(*GpuHT_unalign)
      
    EndIf
    
    If FileSize(filebinname$+"_htGPU.BIN") <= 0
      ;create GPU file
      full_size= HT_items*#HashTablesz + waletcounter*#HashTableSizeHash
      *GpuHT_unalign=AllocateMemory(HT_items*#HashTablesz + #align_size + waletcounter*#HashTableSizeHash)
      If *GpuHT_unalign=0
        PrintN("  Nao foi possivel alocar memoria HTGPUpacked")
        exit("")
      EndIf
     *GpuHT=*GpuHT_unalign+#align_size-(*GpuHT_unalign % #align_size)
   
      Print(L("pack_htgpu"))
      packHTGPU()
      PrintN("ok")
      ; Save file for CPU using
      ;Saving BIN FILE
      Print(L("save_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$+"_htGPU.BIN") : ConsoleColor(7, 0)
      savedbytes=0
      maxsavebytes=full_size
      If full_size>1024*1024*1024
        maxsavebytes = 1024*1024*1024
      EndIf
      *pp=*GpuHT
      
      If CreateFile(0,filebinname$+"_htGPU.BIN")
        i=0
        Repeat
        ;PrintN("  ["+Str(i)+"] chunk:"+Str(maxsavebytes)+"b")
        wrbytes =WriteData(0, *pp, maxsavebytes) 
        savedbytes + maxsavebytes
        
        If maxsavebytes<>wrbytes
          Print(L("err_saving")+Str(maxsavebytes)+"b, got:"+Str(wrbytes)+"b")
          CloseFile(0)
          exit("")
        EndIf
        
        *pp+maxsavebytes
        
        If savedbytes<full_size
          If savedbytes+maxsavebytes>full_size
            maxsavebytes = full_size-savedbytes
            ;PrintN("  Last chunk:"+Str(maxsavebytes)+"b")
          EndIf
          
        EndIf
        i+1
        Until savedbytes>=full_size
        CloseFile(0) 
        Print(L("saved")) : ConsoleColor(10, 0) : PrintN(Str(savedbytes)+" bytes") : ConsoleColor(7, 0) : ConsoleColor(7, 0)
        
        
  
      Else
        Debug "  May not create the file!"
      EndIf
      ;FreeMemory(*GpuHT_unalign)
      
    EndIf
    
    
    RemoveTempHashTable()  
    
  Else
    ;PrintN("  Both HT files exist") 
  EndIf
  
  
EndProcedure

Procedure LOAD_HTCPUpacked(*xpoint)
  Protected i,j, filebinname$, full_size, len=8, hash.s, *pp, counters, totalpos, jobcomplete.d, prejobcomplete.d, wrbytes, savedbytes, maxsavebytes, loadedbytes, starttime
  Protected totalloadbytes, maxloadbytes, Yoffset, w$
  Shared *CpuHTPacked, *CpuHTPacked_unalign, *GpuHT, *GpuHT_unalign, *PointerTable_unalign, *PointerTable,  waletcounter, HT_items, *Table, *Table_unalign, *BabyArr, *BabyArr_unalign, *CurveGX, *CurveGY

  
    
  filebinname$=Curve::m_gethex32(*xpoint)+"_"+Str(waletcounter)+"_"+Str(HT_items)+"_htCPU.BIN"
  
  
  If FileSize(filebinname$) >0
    
    full_size= HT_items*#HashTablesz + waletcounter * #HashTableSizeItems
    *GpuHT_unalign=AllocateMemory(HT_items*#HashTablesz + #align_size + waletcounter * #HashTableSizeItems)
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
    exit("  File :"+filebinname$+" does not exist")
  EndIf
 
  
EndProcedure


