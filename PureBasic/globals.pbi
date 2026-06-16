EnableExplicit
#ENABLE_VERIFICATIONS = 0
IncludeFile "lib/Curve64.pb"
CompilerIf #PB_Compiler_Unicode
  Debug" switch to Ascii mode"
  End
CompilerEndIf
CompilerIf Not #PB_Compiler_Processor = #PB_Processor_x64
  Debug" only x64 processor support"
  End
CompilerEndIf

#array_dim=64
#line_dim=64
#alignMemoryGpu=64   
#LOGFILE=1
#WINFILE="Found.txt"
#appver="v2.0.0 (14.06.2026) Jefferson"
Structure JobSturucture
  *arr
  *NewPointsArr
  beginrangeX$
  beginrangeY$
  totalpoints.i  
  pointsperbatch.i
  isAlive.i
  isError.i  
  Yoffset.i
EndStructure

Structure sortjobStructure
  *ptarr
  *sortptarray
  totallines.i
  curpos.i
EndStructure

Structure comparsationStructure
  pos.i
  direction.i
EndStructure

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Import "lib\cuda.lib"
CompilerElse
  ImportC "-lcuda"
CompilerEndIf
  cuInit(Flags.i)
  
  cuMemGetInfo_v2(freebytes.i,totalbytes.i)
  cuEventCreate(phEvent.i,Flags.i)	
  cuEventDestroy 	(hEvent.i)  	
  cuEventQuery 	(hEvent.i) 
  cuEventRecord 	(hEvent.i,Stream.i) 
  cuEventSynchronize 	(hEvent.i)  	
  cuDeviceTotalMem(bytes.i,dev.i)
  cuDeviceTotalMem_v2(bytes.i,dev.i)
  cuDeviceComputeCapability(major.i,minor.i,dev.i) 	
  cuDeviceGetCount(count.i)
  cuDeviceGetName(name.s,len.i,dev.i)  
  cuDeviceGetAttribute(pi.i,attrib.i,dev.i)
  cuDeviceGet(device.i, ordinal.i)
  cuGetErrorName ( err.i, err_string.s )
  cuCtxCreate(pctx.i, flags.i, dev.i)
  cuCtxCreate_v2(pctx.i, flags.i, dev.i)
  cuMemAlloc(dptr.i, bytesize.i)
  cuMemAlloc_v2(dptr.i, bytesize.i)
  cuModuleGetGlobal (dptr.i, bytesize.i,hmodule.i,name.i)	
  cuModuleLoadData(hmodule.i, image.i)
  cuModuleLoad(hmodule.i, fname.i)
  cuModuleGetFunction(hfunc.i, hmod.i, name.s)
  cuParamSetSize(hfunc.i, numbytes.i)
  cuParamSetv(hfunc.i, offset.i, ptr.i, numbytes.i)
  cuParamSeti(hfunc.i, offset.i, value.i)
  cuFuncSetBlockShape(hfunc.i, x.i, y.i, z.i)
  cuLaunchGridAsync( hfunc.i, x.i, y.i, z.i,hstream.i)		
  cuLaunchGrid(f.i, grid_width.i, grid_height.i)
  cuFuncSetSharedSize(f.i,numbytes.i) 	
  cuFuncSetCacheConfig 	( f.i,config.i) 
  cuLaunch(f.i)
  
  cuFuncGetAttribute 	(pi.i,attrib.i,f.i) 	
  cuStreamCreate (hStream.i, Flags.i)
  cuStreamCreate_v2 (hStream.i, Flags.i)
  cuStreamDestroy (hStream.i)
  cuStreamSynchronize (hStream)
  cuStreamQuery 	(hStream.i)  	
  cuCtxSynchronize()
  cuMemcpyDtoH(dstHost.i, srcDevice.i, ByteCount.i)
  cuMemcpyDtoH_v2(dstHost.i, srcDevice.i, ByteCount.i)
  cuMemcpyHtoD(dstDevice.i, srcHost.i, ByteCount.i)
  cuMemcpyHtoD_v2(dstDevice.i, srcHost.i, ByteCount.i)
  cuMemFree(dptr.i)
  cuMemFree_v2(dptr.i)
  cuCtxDestroy(ctx.i)
  cuCtxDestroy_v2(ctx.i)
EndImport

Structure CoordPoint
  *x
  *y
EndStructure

#align_size=128
#HashTablesz=8;4B counter items and 4B offset in PointersTable 
#Pointersz=8
#HashTableSizeHash=4
#HashTableSizeItems=8
#maximumgpucount = 32

Structure HashTableResultStructure   
 size.l
 *contentpointer
EndStructure

Global Dim HTMutex(255)
Global HTCountMutex
Define cls$=RSet(cls$,80,Chr(8))
HTCountMutex = CreateMutex()
Define i
For i=0 To 255
  HTMutex(i) = CreateMutex()
Next


Define *CurveP, *CurveGX, *CurveGY, *Curveqn
*CurveP = Curve::m_getCurveValues()
*CurveGX = *CurveP+32
*CurveGY = *CurveP+64
*Curveqn = *CurveP+96

Global Dim a$(7)
Global Dim gpu(#maximumgpucount)
a$(0)="MAX_THREADS_PER_BLOCK "
a$(1)="SHARED_SIZE_BYTES "
a$(2)="CONST_SIZE_BYTES "
a$(3)="LOCAL_SIZE_BYTES "
a$(4)="NUM_REGS "
a$(5)="PTX_VERSION "
a$(6)="BINARY_VERSION" 
Define recovery=0
Define recoveryCNT$
Define recoverypos
Define recoveryfilename$
Define recoverypub$
Define recoveryfingerprint$
Define cnttimer=180
Define cnttimer2=0
Define dice
Define settingsvalue$, settingsFingerPrint$
Define cls$
Define  threadtotal.i
Define  blocktotal.i
Define pparam.w
Define.s Gx , Gy, p, privkey, privkeyend, pball$, walletall$, mainpub, addpubs, privkey1, privkey2, privkey3, privkey4, privkey5, privkey6, privkey7, privkey8 
Define waletcounter, usedgpucount, isruning
Define maxnonce, *BabyArr, *BabyArr_unalign, *BabyArrSorted, *BabyArrSorted_unalign, *GiantArr, *GiantArrPacked, *HelperArr, totallaunched, *Table_unalign, *Table, *GpuHT_unalign, *GpuHT, *CpuHTPacked_unalign, *CpuHTPacked
Define NewMap job.JobSturucture()
Define NewMap sortjob.sortjobStructure()
Define keyMutex, quit, *PointerTable_unalign, *PointerTable
Define *PrivBIG, *PrivBIG2, *PrivBIG3, *key7, PubkeyBIG.CoordPoint, *MaxNonceBIG, FINDPUBG.CoordPoint, ADDPUBG.CoordPoint, *bufferResult, *addX, *addY, *PRKADDBIG, PUBADDBIG.CoordPoint, REALPUB.CoordPoint, *WINKEY, Two.CoordPoint
Define *WidthRange
Define Defdevice$, HT_POW=26, endrangeflag=0, Text$="", pubfile$="", NewList publist.s() , globalquit, isreadyjob, listpos
Define JobMutex
Define *GlobKey
Define *key7
Define GlobPub.CoordPoint
Define *CenterBig, *CenterX, *CenterY
Define *GlobCnt
JobMutex = CreateMutex()
keyMutex = CreateMutex()

;-VARIABLES

threadtotal = 512;512
blocktotal = 68;68
pparam=256
waletcounter=Int(Pow(2, 27))

;mainpub.s = "0222479403f4eb300b997bc76feab5e9e0631be2d2b006e3d87ec586bd48a94720"
;mainpub.s = "9b46a5c1c66aa27ac6409414db3f7994c79c7b2aa22a63f79fec0b3a6c2ba706c8913a9abf96cc9dc6ea102e19ffea29a0845f2c6d12f88380aea8de61a368fe"
;mainpub.s = "11569442e870326ceec0de24eb5478c19e146ecd9d15e4666440f2f638875f42524c08d882f868347f8b69d3330dc1913a159d8fb2b27864f197693a0eb39a23"
;mainpub.s = "e1e5e6f7b0b8d67604e3940c87bf06b814cedc486112b9956c68e3d78b1bd81297fe4f65fbd6e9f7eb1eea80b144d1487f2a9b0aeae5fcf6f43b41491641884e" ;125357 1E9AD
;mainpub.s = "59A3BFDAD718C9D3FAC7C187F1139F0815AC5D923910D516E186AFDA28B221DC994327554CED887AAE5D211A2407CDD025CFC3779ECB9C9D7F2F1A1DDF3E9FF8"
mainpub.s = "02CEB6CBBCDBDF5EF7150682150F4CE2C6F4807B349827DCDBDD1F2EFA885A2630"
;privkey.s="0x0000000000000000000000000000000000000000000000000000fde000000000"
             
;privkey.s="0x0000000000000000000000000000000000000000000000000020000000000000"
;privkey.s="0x10000000000000000"
;privkeyend.s="0x1ffffffffffffffff"
privkey.s="800000000000000000000000000000"

privkey1.s="800000000000000000000000000000"
privkey2.s="900000000000000000000000000000"
privkey3.s="a00000000000000000000000000000"
privkey4.s="b00000000000000000000000000000"
privkey5.s="c00000000000000000000000000000"
privkey6.s="d00000000000000000000000000000"
privkey7.s="e00000000000000000000000000000"
privkey8.s="f00000000000000000000000000000"
privkeyend.s="ffffffffffffffffffffffffffffff";"0x80001F4"

Declare getprogparam()
Declare exit(str.s)
Declare Log2(Quad.q)
Declare ReadHTpack(*hash, *arr, *res.HashTableResultStructure)
Declare FilePutContents(filename.s, *mem, size)
Declare RemoveGiantArrTemp() 
Declare compareHTpack(*hash)
OpenConsole()
ConsoleColor(14, 0)

getprogparam()

Define BABYS_pow = log2(waletcounter)
Define HT_items = Int(Pow(2,HT_POW))
Define HT_mask = HT_items-1
Define HT_total_items = 0
Define HT_max_collisions = 0
Define HT_items_with_collisions = 0
Define HT_total_hashes = 0
Define initHTsize=1
If BABYS_pow>HT_POW
  ;initHTsize=Int(Pow(2,BABYS_pow-HT_POW))
  initHTsize=BABYS_pow-HT_POW
EndIf

maxnonce = threadtotal * blocktotal * pparam

*HelperArr=AllocateMemory(1024*96*CountCPUs(#PB_System_ProcessCPUs))
If *HelperArr=0
  PrintN("  Can`t allocate memory")
  exit("")
EndIf

Macro move16b_1(offset_target_s,offset_target_d)  
  !movdqa xmm0,[rdx++offset_target_s]
  !movdqa [rcx+offset_target_d],xmm0
EndMacro

Macro move32b_(s,d,offset_target_s,offset_target_d)
  !mov rdx, [s]
  !mov rcx, [d]  
  move16b_1(0+offset_target_s,0+offset_target_d)
  move16b_1(16+offset_target_s,16+offset_target_d) 
EndMacro



Global Dim HTHeaps(255)
