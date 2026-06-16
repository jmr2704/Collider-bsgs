Global NewMap L.s()

Procedure LoadLanguage(lang.s)
  ClearMap(L())
  If UCase(lang) = "EN"
    L("site") = "  Project Site                     : "
    L("site_url") = "https://github.com/phrutis/Collider"
    L("donate") = "  Donate (BTC)                     : "
    L("donate_url") = "bc1qh2mvnf5fujg93mwl8pe688yucaw9sflmwsukz9"
    L("findpubkey") = "  Searching PubKey                 : "
    L("cant_found_solution") = "  False public key ignored (GPU Hash Collision)"
    L("privat_key") = "  Private Key                      : "
    L("public_key") = "  Public Key                       : "
    L("working_time") = "  Working Time                     : "
    L("total_time") = "  Total Time                       : "
    L("load_time") = "  Load Time                        : "
    L("found") = "  =============================================== FOUND ("
    L("cuda_ok") = "  Cuda finished successfully"
    L("cant_create_file") = "  Can't create the file!"
    L("invalid_gpu") = "  Invalid GPU number #"
    L("gen_babys") = "  Generating Babys Buffer: "
    L("job_thread") = "  Job per thread: "
    L("reset_points") = "  Reset points: "
    L("save_bin") = "  Saving BIN file                  : "
    L("load_bin") = "  Loading BIN file                 : "
    L("saved") = "  Saved                            : "
    L("err_saving") = "  Error when saving: save:"
    L("err_loading") = "  Error when loading: need:"
    L("cant_open_file") = "  Can't open the file:"
    L("cant_alloc_mem") = "  Can't allocate memory"
    L("pack_htcpu") = "  Packing HT CPU items..."
    L("pack_htgpu") = "  Packing HT GPU items..."
    L("verify_htcpu") = "  Verifying packed CPU items..."
    L("verify_htcpu_sort") = "  Verifying CPU sorting..."
    L("dest_heaps") = "  Destroying 256 Memory Heaps...wait"
    L("rm_temp_ht") = "  Temporary HashTable cleared successfully"
    L("add_babys_ht") = "  Adding Baby Points to HashTable using "
    L("sort_ht") = "  Sorting HT items..."
    L("val_exist") = "  Value already exists!!!>"
    L("try_inc_htsz") = "  Try increasing -htsz parameter"
    L("warn_free_mem") = "  Warning!!! To calculate arrays you need free "
    L("allocated") = "  Allocated ("
    L("gen_giants") = "  Generating Giants Buffer: "
    L("prep_giant_gpu") = "  Preparing Giant Buffer for GPU..."
    L("verify_giant") = "  Verifying Giant array..."
    L("freed_mem") = "  Freed RAM memory: "
    L("press_enter") = "  Press Enter to exit"
    L("used_gpu") = "  GPUs in Use                      : "
    L("used_gpu_card") = "  GPU Video Card                   : "
    L("recv_file") = "  Recovery work file               : "
    L("will_use_file") = "  Used pubkeys file                : "
    L("checkpoint") = "  Checkpoint                       : "
    L("save_every") = "Save every "
    L("warn_htsz_low") = "  WARNING! -htsz parameter is too low, should be at least "
    L("total_gpu_mem") = "  * Total GPU Memory Needed          : "
    L("global_start") = "  Global Start                     : "
    L("global_end") = "  Global End                       : "
    L("global_range") = "  Global Range                     : "
    L("random_mode") = "  RANDOM MODE : "
    L("should_le") = ", should be <="
    L("try_params") = "  Tested parameters                : "
    L("gen_ram") = " Generation RAM["
    L("table_size") = "  Table Size                       : "
    L("table_mask") = "  Table Mask                       : "
    L("table_used") = "  Table Used                       : "
    L("total_uniq_hex") = "  Total Unique Hex                 : "
    L("total_hashes") = "  Total Hashes                     : "
    L("total") = "  Total                            : "
    L("total_cols") = "  Total Collisions                 : "
    L("max_cols") = "  Max Collisions                   : "
    L("gpu_jobs") = " Jobs                       : "
    L("gpu_threads") = " Threads                    : "
    L("finished") = "Finished"
    L("seconds") = "seconds"
  Else
    L("site") = "  Site do Projeto                  : "
    L("site_url") = "https://github.com/jmr2704/Collider-bsgs"
    L("donate") = "  Doacao (BTC)                     : "
    L("donate_url") = "bc1q7s4m9cwlq8xtx2nz74mquh6ax0jqwsmkkd56s3"
    L("findpubkey") = "  Buscando Chave Pub               : "
    L("cant_found_solution") = "  Chave publica falsa ignorada (Colisao no Hash GPU)"
    L("privat_key") = "  Chave Privada                    : "
    L("public_key") = "  Chave Publica                    : "
    L("working_time") = "  Tempo Trabalho                   : "
    L("total_time") = "  Tempo Total                      : "
    L("load_time") = "  Tempo Leitura                    : "
    L("found") = "  ========================================== ENCONTRADO ("
    L("cuda_ok") = "  Cuda finalizado com sucesso"
    L("cant_create_file") = "  Nao foi possivel criar o arquivo!"
    L("invalid_gpu") = "  Numero de GPU invalido #"
    L("gen_babys") = "  Gerando Buffer de Babys: "
    L("job_thread") = "  trabalho por thread: "
    L("reset_points") = "  Pontos de reset: "
    L("save_bin") = "  Salvando arquivo BIN             : "
    L("load_bin") = "  Lendo arquivo BIN                : "
    L("saved") = "  Salvo                            : "
    L("err_saving") = "  Erro ao salvar: save:"
    L("err_loading") = "  Erro ao carregar: need:"
    L("cant_open_file") = "  Nao foi possivel abrir o arquivo:"
    L("cant_alloc_mem") = "  Nao foi possivel alocar memoria"
    L("pack_htcpu") = "  Empacotando itens HT CPU..."
    L("pack_htgpu") = "  Empacotando itens HT GPU..."
    L("verify_htcpu") = "  Verificando empacotamento CPU..."
    L("verify_htcpu_sort") = "  Verificando ordenacao CPU..."
    L("dest_heaps") = "  Destruindo 256 Galpoes de Memoria...aguarde"
    L("rm_temp_ht") = "  HashTable Temporaria limpa com Sucesso"
    L("add_babys_ht") = "  Adicionando Baby Points na HashTable usando "
    L("sort_ht") = "  Ordenando itens HT..."
    L("val_exist") = "  Valor ja existe!!!>"
    L("try_inc_htsz") = "  Tente aumentar o parametro -htsz"
    L("warn_free_mem") = "  Aviso!!! Para calcular os arrays voce precisa ter livre "
    L("allocated") = "  Alocado ("
    L("gen_giants") = "  Gerando Buffer de Giants: "
    L("prep_giant_gpu") = "  Preparando Buffer Giant para a GPU..."
    L("verify_giant") = "  Verificando array Giant..."
    L("freed_mem") = "  Memoria RAM liberada: "
    L("press_enter") = "  Pressione Enter para sair"
    L("used_gpu") = "  Total GPUs em uso                : "
    L("used_gpu_card") = "  Placa de Video GPU               : "
    L("recv_file") = "  Arquivo de recup de progresso    : "
    L("will_use_file") = "  Arquivo de pubkeys utilizado     : "
    L("checkpoint") = "  Checkpoint                       : "
    L("save_every") = "Salva a cada "
    L("warn_htsz_low") = "  AVISO! O parametro -htsz esta muito baixo, deve ser pelo menos "
    L("total_gpu_mem") = "  * Total de Memoria GPU Necessaria  : "
    L("global_start") = "  Inicio Global                    : "
    L("global_end") = "  Fim Global                       : "
    L("global_range") = "  Range Global                     : "
    L("random_mode") = "  MODO ALEATORIO : "
    L("should_le") = ", deveria ser <="
    L("try_params") = "  Parametros testados              : "
    L("gen_ram") = " RAM Geracao["
    L("table_size") = "  Tam. da Tabela                   : "
    L("table_mask") = "  Mascara Tabela                   : "
    L("table_used") = "  Tabela Usada                     : "
    L("total_uniq_hex") = "  Hex unicos total                 : "
    L("total_hashes") = "  Hashes totais                    : "
    L("total") = "  Total                            : "
    L("total_cols") = "  Total Colisoes                   : "
    L("max_cols") = "  Colisoes Max.                    : "
    L("gpu_jobs") = " Trabalhos                  : "
    L("gpu_threads") = " Threads                    : "
    L("finished") = "Finalizado"
    L("seconds") = "segundos"
  EndIf
EndProcedure

Procedure InitLanguage()
  Protected lang.s = ""
  Protected i.i
  
  For i = 0 To CountProgramParameters() - 1
    If LCase(ProgramParameter(i)) = "-lang" And i < CountProgramParameters() - 1
      lang = UCase(ProgramParameter(i + 1))
      If lang = "EN" Or lang = "PT"
        If CreatePreferences("settings.ini")
          PreferenceGroup("Global")
          WritePreferenceString("Language", lang)
          ClosePreferences()
        EndIf
        If lang = "EN"
          PrintN("  Language changed to EN. Run without -lang to start.")
        Else
          PrintN("  Idioma alterado para PT. Rode sem -lang para iniciar.")
        EndIf
        End
      EndIf
    EndIf
  Next
  
  If lang = "" And FileSize("settings.ini") >= 0
    OpenPreferences("settings.ini")
    PreferenceGroup("Global")
    lang = ReadPreferenceString("Language", "")
    ClosePreferences()
  EndIf
  
  While lang <> "EN" And lang <> "PT"
    ConsoleColor(14, 0)
    PrintN("==========================================")
    PrintN(" Select Language / Selecione o Idioma")
    PrintN(" [1] English (EN)")
    PrintN(" [2] Portugues (PT-BR)")
    PrintN("==========================================")
    ConsoleColor(7, 0)
    Print(" > ")
    Protected choice.s = Input()
    If choice = "1"
      lang = "EN"
    ElseIf choice = "2"
      lang = "PT"
    EndIf
  Wend
  
  If CreatePreferences("settings.ini")
    PreferenceGroup("Global")
    WritePreferenceString("Language", lang)
    ClosePreferences()
  EndIf
  
  LoadLanguage(lang)
EndProcedure
