Procedure ValueL(*a)
  !mov rbx,[p.p_a]   
  !mov eax,[rbx]  
ProcedureReturn
EndProcedure

Procedure INCvalue32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !inc eax 
  !mov [rsi],eax  
EndProcedure

Procedure m_check_less_more_equilX8(*s,*t); 0 - s = t, 1- s < t, 2- s > t
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  
    
  !xor cx,cx
  !llm_check_less_continueQ:
  
  !mov rax,[rsi]
  !mov rbx,[rdi]
   
  !cmp rax,rbx
  !jb llm_check_less_exit_lessQ
  !ja llm_check_less_exit_moreQ 
  
  !xor rax,rax
  !jmp llm_check_less_exitQ  
  
  !llm_check_less_exit_moreQ:
  !mov rax,2
  !jmp llm_check_less_exitQ  
  
  !llm_check_less_exit_lessQ:
  !mov rax,1
  !llm_check_less_exitQ:
ProcedureReturn  
EndProcedure

Procedure check_equil(*s,*t,len=8)
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  !xor cx,cx
  !ll_check_equil_continue:
  
  !mov eax,[rsi]
  !mov ebx,[rdi]
  !add rsi,4
  !add rdi,4
  !bswap eax
  !bswap ebx
  !cmp eax,ebx
  !jne ll_check_equil_exit_noteqil
  !inc cx 
  !cmp cx,[p.v_len]
  !jb ll_check_equil_continue
  
  !mov eax,1
  !jmp ll_check_equil_exit  
  
  !ll_check_equil_exit_noteqil:
  !mov eax,0
  !ll_check_equil_exit:
ProcedureReturn  
EndProcedure

Procedure div8(*s,n,*q,*r);8 byte / n> *q, *r
  !mov rsi,[p.p_s]   
  !xor rdx,rdx
  !mov rax,[rsi]
  !mov rbx,[p.v_n]
  !div rbx
  !mov rsi,[p.p_r]   
  !mov [rsi],rdx
  !mov rsi,[p.p_q] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure sub8(*a,*b,*c);8 byte a-b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !mov rdi,[p.p_b]
  !sub rax,[rdi]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure add8(*a,*b,*c);8 byte a+b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !mov rdi,[p.p_b]
  !add rax,[rdi]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure add8ui(*a,n,*c);8 byte a+b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !add rax,[p.v_n]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure mul8ui(*s,n,*q);8 byte * n
  !mov rsi,[p.p_s]   
  !mov rax,[rsi]  
  !mov rbx,[p.v_n]
  !mul rbx
  !mov rsi,[p.p_q] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure deserialize(*a,b,*sptr,counter=32);fron hex
  Protected *ptr
    *ptr=*a+64*b  
  
  !mov rbx,[p.p_ptr] ;ebx > rbx
  !mov rdi,[p.p_sptr] ;edi > rdi  
  
  !xor cx,cx  
  !ll_MyLabelf:
  
  !push cx
  !mov eax,[rdi]
  !mov ecx,eax
  !xor edx,edx
  
   
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf1        
  !sub al,7
  
  !ll_MyLabelf1:
  !and al,15      ;1
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf2        
  !sub al,7
  
  !ll_MyLabelf2:
  !and al,15      ;2
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf3        
  !sub al,7
  
  !ll_MyLabelf3:
  !and al,15      ;3
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf4        
  !sub al,7
  
  !ll_MyLabelf4:
  !and al,15      ;4
  !or dl,al  
  
  !ror dx,8
  !mov [rbx],dx
  !add rdi,4
  !add rbx,2
  
  
  !pop cx   
  !inc cx 
  !cmp cx,[p.v_counter]
  !jb ll_MyLabelf 
  
  

EndProcedure

Procedure serialize(*a,b,*sptr,counter=32);>hex  
 Protected *ptr
  *ptr=*a+#array_dim*b  
  
  !mov rbx,[p.p_ptr] ;ebx > rbx
  !mov rdi,[p.p_sptr] ;edi > rdi
  
  !xor cx,cx
  !ll_MyLabel:
  
  !push cx
  
  !mov ax,[rbx]
  !xor edx,edx
  
  !mov cx,ax
  
  !and ax,0fh
  !cmp al,10     ;1
  !jb ll_MyLabel1        
  !add al,39
  
  !ll_MyLabel1:
  !add al,48   
  !or dx,ax
  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;2
  !jb ll_MyLabel2        
  !add al,39
  
  !ll_MyLabel2:
  !add al,48   
  !or dx,ax

  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;3
  !jb ll_MyLabel3        
  !add al,39
  
  !ll_MyLabel3:
  !add al,48   
  !or dx,ax
  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;4
  !jb ll_MyLabel4        
  !add al,39
  
  !ll_MyLabel4:
  !add al,48   
  !or dx,ax
  !ror edx,16
  !mov [rdi],edx
  !add rdi,4
  !add rbx,2
  
  !pop cx
  !inc cx
  !cmp cx,[p.v_counter]; words
  !jb ll_MyLabel 
EndProcedure

Procedure check_less_more_equil(*s,*t,len=8);0 - s = t, 1- s < t, 2- s > t
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  !xor cx,cx
  !ll_check_less_continue:
  
  !mov eax,[rsi]
  !mov ebx,[rdi]
  !add rsi,4
  !add rdi,4
  !bswap eax
  !bswap ebx
  !cmp eax,ebx
  !jb ll_check_less_exit_less
  !ja ll_check_less_exit_more  
  !inc cx 
  !cmp cx,[p.v_len]
  !jb ll_check_less_continue
  
  !mov eax,0
  !jmp ll_check_less_exit  
  
  !ll_check_less_exit_more:
  !mov eax,2
  !jmp ll_check_less_exit  
  
  !ll_check_less_exit_less:
  !mov eax,1
  !ll_check_less_exit:
ProcedureReturn  
EndProcedure

Procedure BabycompleteBatchAddWithDouble(*newpointarr,lenline, totalpoints, *apointX, *apointY,  *pointarr, *InvTotal)
  Protected *s, *pointer, *temp, i, *curvInv, *NewpointX, *NewpointY, *pointerdiff, *pointerToNew, *high
  Shared *CurveP
  *s=AllocateMemory(224+40)
  *temp=*s+32
  *curvInv=*s+64
  *NewpointX=*s+96
  *NewpointY=*s+128
  *high=*s+160
  move32b_(p.p_InvTotal, p.p_curvInv,0,0)
  
  *pointer=*pointarr+(totalpoints-1)*96
  *pointerToNew = *newpointarr+(totalpoints-1)*lenline
  totalpoints - 1   
  
  While totalpoints>0
    *pointerdiff = *pointer-96
    Curve::m_mulModX64(*s,*curvInv,*pointerdiff+64,*CurveP, *high)
       
    If Curve::m_check_equilX64(*apointX, *pointer)
      ;px==x
      ;addModP(py, py, x)      
      Curve::m_addModX64(*temp,*apointY,*apointY,*CurveP)
    Else
      ;px!=x
      ;subModP(px, x, x)      
      Curve::m_subModX64(*temp,*apointX,*pointer,*CurveP)
    EndIf
    
    Curve::m_mulModX64(*curvInv,*curvInv,*temp,*CurveP, *high)
    
    If Curve::m_check_equilX64(*apointX, *pointer)
      ;x1==x2
      Curve::m_DBLTX64(*NewpointX,*NewpointY,*apointX,*apointY,*CurveP)
    Else
      ;//slope=(y1-y2)*inverse(x1-x2,p)
      Curve::m_subModX64(*NewpointY,*apointY,*pointer+32,*CurveP)
      Curve::m_mulModX64(*s,*NewpointY,*s,*CurveP, *high)
      ;Rx = s^2 - Gx - Qx =>  pow_mod(slope,2,p)-(x1+x2)
      Curve::m_squareModX64(*NewpointY,*s,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointX,*CurveP)
      Curve::m_subModX64(*NewpointX,*NewpointY,*pointer,*CurveP)
      ;Ry = s(px - rx) - py
      Curve::m_subModX64(*NewpointY,*apointX,*NewpointX,*CurveP)
      Curve::m_mulModX64(*NewpointY,*NewpointY,*s,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointY,*CurveP)
      
    EndIf
    ;PrintN("["+Str(totalpoints)+"] x: "+Curve::m_gethex32(*NewpointX))
    ;PrintN("["+Str(totalpoints)+"] y: "+Curve::m_gethex32(*NewpointY))
    
    CopyMemory(*NewpointX+24,*pointerToNew,8)
    
    
    *pointer-96
    *pointerToNew-lenline
    totalpoints - 1
  Wend
  If totalpoints=0
     If Curve::m_check_equilX64(*apointX, *pointer)
      ;x1==x2
      Curve::m_DBLTX64(*NewpointX,*NewpointY,*apointX,*apointY,*CurveP)
    Else
      ;slope=(y1-y2)*inverse(x1-x2,p)
      Curve::m_subModX64(*NewpointY,*apointY,*pointer+32,*CurveP)
      Curve::m_mulModX64(*curvInv,*NewpointY,*curvInv,*CurveP, *high)
      ;Rx = s^2 - Gx - Qx =>  pow_mod(slope,2,p)-(x1+x2)
      Curve::m_squareModX64(*NewpointY,*curvInv,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointX,*CurveP)
      Curve::m_subModX64(*NewpointX,*NewpointY,*pointer,*CurveP)
      ;Ry = s(px - rx) - py
      ;Ry = s(px - rx) - py
      Curve::m_subModX64(*NewpointY,*apointX,*NewpointX,*CurveP)
      Curve::m_mulModX64(*NewpointY,*NewpointY,*curvInv,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointY,*CurveP)
    EndIf
    
    ;PrintN("["+Str(totalpoints)+"] x: "+Curve::m_gethex32(*NewpointX))
    ;PrintN("["+Str(totalpoints)+"] y: "+Curve::m_gethex32(*NewpointY))
    
    CopyMemory(*NewpointX+24,*pointerToNew,8)
  EndIf
  
  FreeMemory(*s)
EndProcedure

Procedure baby(id)
  Protected *my_pubX, *my_pubY, *arr, *newarrr, pointsperbatch, totalpoints, *inv, msg$="Baby #"+Str(id)+"  ", newbatchsz, calculatesz, leadzero, a$, *ptrarr
  Protected *bufferResult, temp$, *addX, *addY  
  Shared job(), totallaunched
  Shared *CurveGX, *CurveGY, *CurveP

  
  leadzero=32
  *inv = AllocateMemory(192)
  If *inv=0
    PrintN(msg$+L("cant_alloc_mem"))
    exit("")
  EndIf
  *bufferResult= *inv+32
  *addX= *inv+64
  *addY= *inv+96  
  *my_pubX = *inv+128
  *my_pubY = *inv+160
  
  *arr = job(Str(id))\arr  
  *newarrr = job(Str(id))\NewPointsArr
  totalpoints = job(Str(id))\totalpoints
  pointsperbatch = job(Str(id))\pointsperbatch
  
  Curve::m_sethex32(*my_pubX, @job(Str(id))\beginrangeX$)
  Curve::m_sethex32(*my_pubY, @job(Str(id))\beginrangeY$)
  
  ;PrintN(msg$+"("+Curve::m_gethex32(*my_pubX)+Curve::m_gethex32(*my_pubY)+")")
  
  a$=RSet(Hex(pointsperbatch), 64,"0")
  Curve::m_sethex32(*bufferResult, @a$)
  
  Curve::m_PTMULX64(*addX, *addY, *CurveGX, *CurveGY, *bufferResult,*CurveP)
    
    
  calculatesz=0
  While calculatesz<totalpoints
    
    CopyMemory(*my_pubX+24,*newarrr+calculatesz*8,8)
    
    If calculatesz<totalpoints
      newbatchsz = pointsperbatch
      If newbatchsz>=(totalpoints-calculatesz)
        newbatchsz = totalpoints-calculatesz
        a$=Hex(newbatchsz)
        Curve::m_sethex32(*bufferResult, @a$)      
        Curve::m_PTMULX64(*addX, *addY, *CurveGX, *CurveGY, *bufferResult,*CurveP)
      EndIf
      
      
      
      
      Curve::beginBatchAdd(*inv, newbatchsz-1, *my_pubX, *my_pubY,  *arr)
      BabycompleteBatchAddWithDouble(*newarrr+calculatesz*8+8,8, newbatchsz-1, *my_pubX, *my_pubY,  *arr, *inv)
      
      calculatesz  + newbatchsz    
      Curve::m_ADDPTX64(*my_pubX,*my_pubY,*my_pubX, *my_pubY,*addX,*addY,*CurveP)
   EndIf
  Wend
totallaunched-1

  FreeMemory(*inv)
EndProcedure

Procedure GenBabys(*xpoint, *ypoint)
  Protected totalCPUcout, i, jobperthread, restjob, a$, filebinname$, full_size, wrbytes, savedbytes, maxsavebytes, loadedbytes, *pp, totalloadbytes, maxloadbytes
  Shared *HelperArr, *BabyArr, *BabyArr_unalign, waletcounter, *CurveGX, *CurveGY, job(), totallaunched, FINDPUBG, *addX, *addY, *CurveP, *bufferResult, mainpub, waletcounter
  
  *BabyArr_unalign=AllocateMemory((waletcounter+1)*8 + #align_size)
  If *BabyArr_unalign=0
    PrintN("  Nao foi possivel alocar memoria for baby array")
    exit("")
  EndIf
  *BabyArr=*BabyArr_unalign+#align_size-(*BabyArr_unalign % #align_size)

  filebinname$=Curve::m_gethex32(*xpoint)+"_"+Str(waletcounter)+"_b.BIN"
  full_size=waletcounter*8
  
  If FileSize(filebinname$) <= 0
    PrintN(L("gen_babys")+Str(waletcounter)+" items")
 
    Curve::fillarrayN(*HelperArr , 1024, *CurveGX, *CurveGY)
    ;prntarrBIG(*HelperArr, 5)
    
    totalCPUcout = CountCPUs(#PB_System_ProcessCPUs)
    If totalCPUcout>1 And waletcounter>1024
      ;copythe same points to other threads
      For i =1 To totalCPUcout-1
        CopyMemory(*HelperArr, *HelperArr + i * 1024*96, 1024*96)
      Next
      
      jobperthread = waletcounter/totalCPUcout
      PrintN(L("job_thread")+Str(jobperthread)+" items")
      job(Str(0))\arr = *HelperArr
      job(Str(0))\NewPointsArr = *BabyArr
      job(Str(0))\totalpoints = jobperthread
      job(Str(0))\pointsperbatch = 1024
      job(Str(0))\beginrangeX$  = Curve::m_gethex32(*xpoint)
      job(Str(0))\beginrangeY$  = Curve::m_gethex32(*ypoint)
      
      restjob = waletcounter - (jobperthread * totalCPUcout)
      PrintN(L("reset_points")+Str(restjob))
      
    Else  
      PrintN(L("job_thread")+Str(waletcounter)+" items")
      job(Str(0))\arr = *HelperArr
      job(Str(0))\NewPointsArr = *BabyArr
      job(Str(0))\totalpoints = waletcounter
      job(Str(0))\pointsperbatch = 1024
      job(Str(0))\beginrangeX$  = Curve::m_gethex32(*xpoint)
      job(Str(0))\beginrangeY$  = Curve::m_gethex32(*ypoint)
    EndIf
    
    
    CreateThread(@baby(),0)
    totallaunched+1
    If totalCPUcout>1 And waletcounter>1024
      For i = 1 To totalCPUcout-1
        job(Str(i))\arr = *HelperArr+i*1024*96
        job(Str(i))\NewPointsArr = *BabyArr+i*jobperthread*8
        job(Str(i))\totalpoints = jobperthread
        job(Str(i))\pointsperbatch = 1024
        a$=Hex(jobperthread*i)
        Curve::m_sethex32(*bufferResult, @a$)
        Curve::m_PTMULX64(*addX, *addY, *CurveGX, *CurveGY, *bufferResult,*CurveP)
         Curve::m_ADDPTX64(*addX,*addY,*xpoint, *ypoint,*addX,*addY,*CurveP)
        job(Str(i))\beginrangeX$  = Curve::m_gethex32(*addX)
        job(Str(i))\beginrangeY$  = Curve::m_gethex32(*addY)
        CreateThread(@baby(),i)
        totallaunched+1
      Next i
    EndIf
    While totallaunched
      Delay(10)
    Wend
    
    If restjob
        a$=Hex(jobperthread*i)
        Curve::m_sethex32(*bufferResult, @a$)
        Curve::m_PTMULX64(*addX, *addY, *CurveGX, *CurveGY, *bufferResult,*CurveP)
         Curve::m_ADDPTX64(*addX,*addY,*xpoint, *ypoint,*addX,*addY,*CurveP)
        job(Str(0))\beginrangeX$  = Curve::m_gethex32(*addX)
        job(Str(0))\beginrangeY$  = Curve::m_gethex32(*addY)
        job(Str(0))\arr = *HelperArr
        job(Str(0))\NewPointsArr = *BabyArr+i*jobperthread*8
        job(Str(0))\totalpoints = restjob
        job(Str(0))\pointsperbatch = 1024
        baby(0)
    EndIf
    
    ;********************************
    For i = 0 To waletcounter-1
      toLittleInd32_64(*BabyArr+i*8) 
    Next i
    ;********************************
    ;Saving BIN FILE
    PrintN("  Total: "+Str(full_size)+" bytes")
    ; -- SAVE DAG FILE
    Print(L("save_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$) : ConsoleColor(7, 0)
    savedbytes=0
    maxsavebytes=full_size
    If full_size>1024*1024*1024
      maxsavebytes = 1024*1024*1024
    EndIf
    *pp=*BabyArr
    
    If CreateFile(0,filebinname$)           ; we create a new text file...
      i=0
      Repeat
      ;PrintN("  ["+Str(i)+"] chunk:"+Str(maxsavebytes)+"b")
      wrbytes =WriteData(0, *pp, maxsavebytes) 
      savedbytes + maxsavebytes
      
      If maxsavebytes<>wrbytes
        Print("  Error when saving chunk: save:"+Str(maxsavebytes)+"b, got:"+Str(wrbytes)+"b")
        CloseFile(0)
        exit("")
      EndIf
      
      *pp+maxsavebytes
      
      If savedbytes<full_size
        If savedbytes+maxsavebytes>full_size
          maxsavebytes = full_size-savedbytes
          ;PrintN("Last chunk:"+Str(maxsavebytes)+"b")
        EndIf        
      EndIf
      i+1
      Until savedbytes>=full_size
      CloseFile(0) 
      Print(L("saved")) : ConsoleColor(10, 0) : PrintN(Str(savedbytes)+" bytes") : ConsoleColor(7, 0)
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
      *pp=*BabyArr
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
            ;PrintN("  Last chunk: "+Str(maxloadbytes)+"b")
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
      toLittleInd32_64(*BabyArr+i*8) 
    Next i
    ;********************************
EndProcedure

Procedure GiantcompleteBatchAddWithDouble(*newpointarr,lenline,Yoffset, totalpoints, *apointX, *apointY,  *pointarr, *InvTotal)
  Protected *s, *pointer, *temp, i, *curvInv, *NewpointX, *NewpointY, *pointerdiff, *pointerToNew, *high
  Shared *CurveP
  *s=AllocateMemory(224+40)
  *temp=*s+32
  *curvInv=*s+64
  *NewpointX=*s+96
  *NewpointY=*s+128
  *high=*s+160
  move32b_(p.p_InvTotal, p.p_curvInv,0,0)
  
  *pointer=*pointarr+(totalpoints-1)*96
  *pointerToNew = *newpointarr+(totalpoints-1)*lenline
  totalpoints - 1   
  
  While totalpoints>0
    *pointerdiff = *pointer-96
    Curve::m_mulModX64(*s,*curvInv,*pointerdiff+64,*CurveP, *high)
       
    If Curve::m_check_equilX64(*apointX, *pointer)
      ;px==x
      ;addModP(py, py, x)      
      Curve::m_addModX64(*temp,*apointY,*apointY,*CurveP)
    Else
      ;px!=x
      ;subModP(px, x, x)      
      Curve::m_subModX64(*temp,*apointX,*pointer,*CurveP)
    EndIf
    
    Curve::m_mulModX64(*curvInv,*curvInv,*temp,*CurveP, *high)
    
    If Curve::m_check_equilX64(*apointX, *pointer)
      ;x1==x2
      Curve::m_DBLTX64(*NewpointX,*NewpointY,*apointX,*apointY,*CurveP)
    Else
      ;//slope=(y1-y2)*inverse(x1-x2,p)
      Curve::m_subModX64(*NewpointY,*apointY,*pointer+32,*CurveP)
      Curve::m_mulModX64(*s,*NewpointY,*s,*CurveP, *high)
      ;Rx = s^2 - Gx - Qx =>  pow_mod(slope,2,p)-(x1+x2)
      Curve::m_squareModX64(*NewpointY,*s,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointX,*CurveP)
      Curve::m_subModX64(*NewpointX,*NewpointY,*pointer,*CurveP)
      ;Ry = s(px - rx) - py
      Curve::m_subModX64(*NewpointY,*apointX,*NewpointX,*CurveP)
      Curve::m_mulModX64(*NewpointY,*NewpointY,*s,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointY,*CurveP)
      
    EndIf
    ;PrintN("["+Str(totalpoints)+"] x: "+Curve::m_gethex32(*NewpointX))
    ;PrintN("["+Str(totalpoints)+"] y: "+Curve::m_gethex32(*NewpointY))
    
    CopyMemory(*NewpointX,*pointerToNew,32)
    CopyMemory(*NewpointY,*pointerToNew+Yoffset,32)
    
    *pointer-96
    *pointerToNew-lenline
    totalpoints - 1
  Wend
  If totalpoints=0
     If Curve::m_check_equilX64(*apointX, *pointer)
      ;x1==x2
      Curve::m_DBLTX64(*NewpointX,*NewpointY,*apointX,*apointY,*CurveP)
    Else
      ;slope=(y1-y2)*inverse(x1-x2,p)
      Curve::m_subModX64(*NewpointY,*apointY,*pointer+32,*CurveP)
      Curve::m_mulModX64(*curvInv,*NewpointY,*curvInv,*CurveP, *high)
      ;Rx = s^2 - Gx - Qx =>  pow_mod(slope,2,p)-(x1+x2)
      Curve::m_squareModX64(*NewpointY,*curvInv,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointX,*CurveP)
      Curve::m_subModX64(*NewpointX,*NewpointY,*pointer,*CurveP)
      ;Ry = s(px - rx) - py
      ;Ry = s(px - rx) - py
      Curve::m_subModX64(*NewpointY,*apointX,*NewpointX,*CurveP)
      Curve::m_mulModX64(*NewpointY,*NewpointY,*curvInv,*CurveP, *high)
      Curve::m_subModX64(*NewpointY,*NewpointY,*apointY,*CurveP)
    EndIf
    
    ;PrintN("["+Str(totalpoints)+"] x: "+Curve::m_gethex32(*NewpointX))
    ;PrintN("["+Str(totalpoints)+"] y: "+Curve::m_gethex32(*NewpointY))
    
    CopyMemory(*NewpointX,*pointerToNew,32)
    CopyMemory(*NewpointY,*pointerToNew+Yoffset,32)
  EndIf
  
  FreeMemory(*s)
EndProcedure

Procedure giant(id)
  Protected *my_pubX, *my_pubY, *arr, *newarrr, pointsperbatch, totalpoints, *inv, msg$="Giant #"+Str(id)+"  ", newbatchsz, calculatesz, leadzero, a$, *ptrarr, Yoffset
  Protected *bufferResult, temp$, *addX, *addY , *Rbx, *Rby
  Shared job()
  Shared *CurveGX, *CurveGY, *CurveP

  
  leadzero=32
  *inv = AllocateMemory(256)
  If *inv=0
    PrintN(msg$+"Nao foi possivel alocar memoria")
    exit("")
  EndIf
  *bufferResult= *inv+32
  *addX= *inv+64
  *addY= *inv+96  
  *my_pubX = *inv+128
  *my_pubY = *inv+160
  *Rbx= *inv+192
  *Rby= *inv+224
  
  *arr = job(Str(id))\arr  
  *newarrr = job(Str(id))\NewPointsArr
  totalpoints = job(Str(id))\totalpoints
  pointsperbatch = job(Str(id))\pointsperbatch
  Yoffset = job(Str(id))\Yoffset
  
  Curve::m_sethex32(*Rbx, @job(Str(id))\beginrangeX$)
  Curve::m_sethex32(*Rby, @job(Str(id))\beginrangeY$)
   Curve::m_sethex32(*my_pubX, @job(Str(id))\beginrangeX$)
   Curve::m_sethex32(*my_pubY, @job(Str(id))\beginrangeY$)
   
  ;PrintN(msg$+"("+Curve::m_gethex32(*my_pubX)+Curve::m_gethex32(*my_pubY)+")")
  
  a$=Hex(pointsperbatch)
  Curve::m_sethex32(*bufferResult, @a$)
  
  Curve::m_PTMULX64(*addX, *addY, *Rbx, *Rby, *bufferResult,*CurveP)
  
  calculatesz=0
  
  
   While calculatesz<totalpoints
    
    CopyMemory(*my_pubX,*newarrr+calculatesz*32,32)
    CopyMemory(*my_pubY,*newarrr+calculatesz*32+Yoffset,32)
    
    If calculatesz<totalpoints
      newbatchsz = pointsperbatch
      If newbatchsz>=(totalpoints-calculatesz)
        newbatchsz = totalpoints-calculatesz
        a$=Hex(newbatchsz)
        Curve::m_sethex32(*bufferResult, @a$)      
        Curve::m_PTMULX64(*addX, *addY, *Rbx, *Rby, *bufferResult,*CurveP)
      EndIf
      
      
      
      
      Curve::beginBatchAdd(*inv, newbatchsz-1, *my_pubX, *my_pubY,  *arr)
      GiantcompleteBatchAddWithDouble(*newarrr+calculatesz*32+32,32,Yoffset, newbatchsz-1, *my_pubX, *my_pubY,  *arr, *inv)
      
      calculatesz  + newbatchsz    
      Curve::m_ADDPTX64(*my_pubX,*my_pubY,*my_pubX, *my_pubY,*addX,*addY,*CurveP)
   EndIf
  Wend
 
  

  FreeMemory(*inv)
EndProcedure

Procedure checkGiantArr(*arr, *x,*y, Yoffset, totalpoints, numberofrand=1024)
  Protected res=0, *MyX, *MyY,*bufferResult, a$, randnum
  Shared *CurveP
  *MyX = AllocateMemory(96)
  *MyY = *MyX+32
  *bufferResult= *MyX+64
  If numberofrand<1024
    numberofrand=1024
  EndIf
  CopyMemory(*x,*MyX,32)
  CopyMemory(*y,*MyY,32)
  If Curve::m_check_equilX64(*MyX,*arr)=0 Or  Curve::m_check_equilX64(*MyY,*arr+Yoffset)=0
    PrintN("  false")
    PrintN(Curve::m_gethex32(*MyX)  +"-"+Curve::m_gethex32(*arr))
    PrintN(Curve::m_gethex32(*MyY)  +"-"+Curve::m_gethex32(*arr+Yoffset))
    res=1
  EndIf
  numberofrand-1
  
  While numberofrand>0 And res=0
    randnum = Random(totalpoints-1,1)
    a$=Hex(randnum+1)
    Curve::m_sethex32(*bufferResult, @a$)
    Curve::m_PTMULX64(*MyX, *MyY, *x, *y, *bufferResult,*CurveP)
    If Curve::m_check_equilX64(*MyX,*arr+randnum*32)=0 Or  Curve::m_check_equilX64(*MyY,*arr+Yoffset+randnum*32)=0
      PrintN("  false")
      PrintN("  ["+Str(randnum)+"] Est."+Curve::m_gethex32(*MyX)  +"- got"+Curve::m_gethex32(*arr+randnum*32))
      PrintN("  ["+Str(randnum)+"] Est. "+Curve::m_gethex32(*MyY)  +"- got"+Curve::m_gethex32(*arr+Yoffset+randnum*32))
      res=1
      Break
    EndIf
    numberofrand-1
  Wend
  FreeMemory(*MyX)
  ProcedureReturn res
EndProcedure

Procedure checkBabyArr(*arr, *x,*y, totalpoints, numberofrand=1024)
  Protected res=0, *MyX, *MyY,*bufferResult, a$, randnum
  Shared *CurveP, *CurveGX, *CurveGY
  *MyX = AllocateMemory(96)
  *MyY = *MyX+32
  *bufferResult= *MyX+64
  If numberofrand<1024
    numberofrand=4096
  EndIf
  
  
  While numberofrand>0 And res=0
    randnum = Random(totalpoints-1,1)
    a$=Hex(randnum)
    Curve::m_sethex32(*bufferResult, @a$)
    Curve::m_PTMULX64(*MyX, *MyY, *CurveGX, *CurveGY, *bufferResult,*CurveP)
    ;Curve::m_ADDPTX64(*MyX,*MyY,*x,*y,*MyX,*MyY,*CurveP)
    If check_equil(*MyX+24,*arr+randnum*8-8,2)=0
      PrintN("false")
      PrintN("["+Str(randnum)+"] Est."+m_gethex8(*MyX+24)  +"- got"+m_gethex8(*arr+randnum*8))     
      res=1
      Break
    EndIf
    numberofrand-1
  Wend
  FreeMemory(*MyX)
  ProcedureReturn res
EndProcedure

Procedure Save_Load_Giants()
  Protected i,j, filebinname$, full_size, len=8, hash.s, *pp, counters, totalpos, jobcomplete.d, prejobcomplete.d, wrbytes, savedbytes, maxsavebytes, loadedbytes
  Protected totalloadbytes, maxloadbytes, *temper, Yoffset, w$
  Shared *HelperArr, *GiantArr, *GiantArrPacked, blocktotal, threadtotal, pparam, ADDPUBG, maxnonce, job(), waletcounter

  *GiantArrPacked=AllocateMemory((maxnonce+1)*64)
  If *GiantArrPacked=0
    PrintN("  Nao foi possivel alocar memoria for giantpacked array")
    exit("")
  EndIf
    
  filebinname$=Str(threadtotal)+"_"+Str(blocktotal)+"_"+Str(pparam)+"_"+Str(waletcounter)+"_g2.BIN"
  full_size=maxnonce * 64
  
  If FileSize(filebinname$) <= 0
    ; file does not exist    
    
    *GiantArr=AllocateMemory((maxnonce+1)*64)
    If *GiantArr=0
      PrintN("  Nao foi possivel alocar memoria for giant array")
      exit("")
    EndIf

    Curve::fillarrayN(*HelperArr , 1024, ADDPUBG\x, ADDPUBG\y)
    ;prntarrBIG(*HelperArr, 16)
    
    job(Str(0))\arr = *HelperArr
    job(Str(0))\NewPointsArr = *GiantArr
    job(Str(0))\totalpoints = maxnonce
    job(Str(0))\pointsperbatch = 1024
    job(Str(0))\beginrangeX$  = Curve::m_gethex32(ADDPUBG\x)
    job(Str(0))\beginrangeY$  = Curve::m_gethex32(ADDPUBG\y)
    job(Str(0))\Yoffset = maxnonce * 32
    giant(0)
    
    CompilerIf #ENABLE_VERIFICATIONS
    Print(L("verify_giant"))
    If checkGiantArr(*GiantArr, ADDPUBG\x,ADDPUBG\y, maxnonce * 32, maxnonce, maxnonce/65536)=1
      
      exit("")
    Else
      PrintN("  ok")
    EndIf
    
    CompilerEndIf

    Print(L("prep_giant_gpu"))
    *temper = AllocateMemory(64)
    If *temper=0
      PrintN(L("cant_alloc_mem"))
      exit("")
    EndIf
    Yoffset = maxnonce * 32
    For i =  0 To maxnonce - 1
      For j = 0 To 7
        PokeL(*temper + (7-j)*4, PeekL(*GiantArr + i*32 + j*4))
      Next j
      For j = 0 To 7
        PokeL(*temper + 32 + (7-j)*4, PeekL(*GiantArr + i*32 + Yoffset + j*4))
      Next j
      Writeint(*GiantArrPacked, i, blocktotal, threadtotal, *temper)
      Writeint(*GiantArrPacked+Yoffset, i, blocktotal, threadtotal, *temper+32)
    Next i
    PrintN("  ok")
    
    RemoveGiantArrTemp() 
    ;Saving BIN FILE
    Print(L("save_bin")) : ConsoleColor(10, 0) : PrintN(filebinname$) : ConsoleColor(7, 0)
    savedbytes=0
    maxsavebytes=full_size
    If full_size>1024*1024*1024
      maxsavebytes = 1024*1024*1024
    EndIf
    *pp=*GiantArrPacked
    
    If CreateFile(0,filebinname$)           ; we create a new text file...
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
      Print(L("saved")) : ConsoleColor(10, 0) : PrintN(Str(savedbytes)+" bytes") : ConsoleColor(7, 0)
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
      *pp=*GiantArrPacked
      i=0
      Repeat
        ;PrintN("  ["+Str(i)+"] chunk: "+Str(maxloadbytes)+"b")
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
  If *temper
    FreeMemory(*temper)
  EndIf
EndProcedure

Procedure check_LME32bit(*s,*t)
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
    
  !mov eax,[rsi]
  !cmp eax,[rdi]
  !jb llm_LME32bit_exit_less
  !ja llm_LME32bit_exit_more  
   
  !xor eax,eax
  !jmp llm_LME32bit_exit  
  
  !llm_LME32bit_exit_more:
  !mov eax,2
  !jmp llm_LME32bit_exit  
  
  !llm_LME32bit_exit_less:
  !mov eax,1
  !llm_LME32bit_exit:
ProcedureReturn  
EndProcedure

Procedure RemoveGiantArrTemp()   
  Protected memtotal
  Shared  *GiantArr
  
  memtotal + MemorySize(*GiantArr) 
  
  FreeMemory(*GiantArr) 
  PrintN(L("freed_mem")+StrD(memtotal/1024/1024,3)+" MB")
EndProcedure


