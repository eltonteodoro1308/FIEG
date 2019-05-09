#INCLUDE "Protheus.ch"
#INCLUDE "Protheus.ch"
CTRBALIAS3
User Function AJUSDIC

	Local aTabSX1   := U_iRetDic("SX1")
	Local cTrbAlias1 := "SX1__iTmp"
	Local nLoop1     := Nil

	Local aTabSX3   := U_iRetDic("SX3")
	Local cTrbAlias3 := "SX3__iTmp"
	Local nLoop     := Nil

	Local aTabSXG   := U_iRetDic("SXG")
	Local cTrbAlias2 := "SXG__iTmp"
	Local nLoop2     := Nil

	Local aTabSX6   := U_iRetDic("SX6")
	Local cTrbAlias6 := "SX6__iTmp"
	Local nLoop6    := Nil

	Local aTabSX7   := U_iRetDic("SX7")
	Local cTrbAlias7 := "SX7__iTmp"
	Local nLoop7    := Nil

	Local aTabSXA   := U_iRetDic("SXA")
	Local cTrbAliasA := "SXA__iTmp"
	Local nLoopA    := Nil

	Local aTabSXB   := U_iRetDic("SXB")
	Local cTrbAliasB := "SXB__iTmp"
	Local nLoopB    := Nil	
	
	Local aTabSX9   := U_iRetDic("SX9")
	Local cTrbAlias9 := "SX9__iTmp"
	Local nLoop9    := Nil	
	
	If Select(cTrbAlias3) > 0
		(cTrbAlias3)->(dbCloseArea())
	Endif

	For nLoop := 1 To Len(aTabSX3)
		dbUseArea( .T., aTabSX3[nLoop, 5], aTabSX3[nLoop, 3], cTrbAlias3, .T. , .F. )
		Do While !Eof()

			if rtrim(X3_CAMPO)=='N1_GRUPO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1914")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_RELACAO :='U_XATFCA("N1_GRUPO") '
				MsUnlock()
			Endif
 
			if rtrim(X3_CAMPO)=='N1_CBASE'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1914")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_RELACAO :='U_XATFCA("N1_CBASE")' 
				MsUnlock()
			Endif
			
			if rtrim(X3_CAMPO)=='N1_ITEM'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1914")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_RELACAO :='U_XATFCA("N1_ITEM")' 
				MsUnlock()
			Endif				
			

			if rtrim(X3_CAMPO)=='N1_DESCRIC'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1914")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_RELACAO :='U_XATFCA("N1_DESCRIC")'
				MsUnlock()
			Endif			
			
			if rtrim(X3_CAMPO)=='AKC_UM' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")			
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif
			
			if rtrim(X3_CAMPO)=='AKC_KEYREF' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")			
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif
			
			if rtrim(X3_CAMPO)=='AKC_CODPLA'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")			
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif
			
			if rtrim(X3_CAMPO)=='AKC_VERSAO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")			
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif
			
			if rtrim(X3_CAMPO)=='AKC_UNIORC'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKC_ENT05' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKC_ENT06' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKC_ENT07' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKC_ENT08' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKC_ENT09' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_UM'     
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_KEYREF' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock() 
			Endif

			if rtrim(X3_CAMPO)=='AKI_CODPLA' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_VERSAO' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_UNIORC'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_ENT05' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_ENT06' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_ENT07' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3)
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif

			if rtrim(X3_CAMPO)=='AKI_ENT08' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO=250
				MsUnlock() 
			Endif
			
			if rtrim(X3_CAMPO)=='AKI_ENT09' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1912")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_TAMANHO:=250 
				MsUnlock()
			Endif			
						

			if rtrim(X3_CAMPO)=='C8_FORNECE' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1910")
				RecLock(cTrbAlias3) 
				(cTrbAlias3)->X3_VISUAL:='A'
				MsUnlock()
			Endif			
						

			if rtrim(X3_CAMPO)=='AL_DESCPER' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1909")
				RecLock(cTrbAlias3) 					
				(cTrbAlias3)->X3_RELACAO:='IF(!INCLUI,POSICIONE("DHL",1,XFILIAL("DHL")+SAL->AL_PERFIL,"DHL_DESCRI"),"")'
				MsUnlock()
			Endif				
			
			if rtrim(X3_CAMPO)=='AL_APROSUP' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1908	")
				RecLock(cTrbAlias3) 				
			   (cTrbAlias3)->X3_VALID:='(Vazio() .Or. ExistCpo("SAK"",FwFldGet("AK_APROSUP"))) .And. A114SuPDif(a)'
				MsUnlock()
			Endif		
			
			if rtrim(X3_CAMPO)=='AL_NOME' 
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1907	")
				RecLock(cTrbAlias3) 				
			   (cTrbAlias3)->X3_RELACAO:='If(!INCLUI,Posicione("SAK",2,xFilial("SAK")+SAL->AL_USER,"AK_NOME"),"")'                                                         '
				MsUnlock()
			Endif		
			
					
			if rtrim(X3_CAMPO)=='BM_GRUPO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1906	")
				RecLock(cTrbAlias3) 				
			   (cTrbAlias3)->X3_WHEN:=''                                                        '
				MsUnlock()
			Endif		
			
			if rtrim(X3_CAMPO)=='C8_FORMAIL'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1905	")
				RecLock(cTrbAlias3) 				
			   (cTrbAlias3)->X3_TAMANHO:=100                                                        '
				MsUnlock()
			Endif				
			
			if rtrim(X3_CAMPO)=='A2_MUN'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1904	")
				RecLock(cTrbAlias3) 				
			   (cTrbAlias3)->X3_TAMANHO:=60                                                        '
				MsUnlock()
			Endif					


			if rtrim(X3_CAMPO)=='ZX_CODEMP'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1882	")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VALID:='ExistCpo("SM0", cEmpAnt + M->ZX_CODEMP)'                                                                                        
				MsUnlock()
			Endif					

			if rtrim(X3_CAMPO)=='B1_LOCPAD'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1897")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL :='A'                                                                                       
				MsUnlock()
			Endif	

			if rtrim(X3_CAMPO)=='CT1_PREFIX'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1926")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_TAMANHO :=4                                                                                       
				MsUnlock()
			Endif	

			
			if rtrim(X3_CAMPO)=='CNB_ITEMCT'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1925")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_WHEN:=""                                                                                      
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='CNB_CC'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1925")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_WHEN:=""                                                                                       
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='CNB_CONTA'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1924")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL:="A"                                                                                       
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='CNB_CONTA'			
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1923")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_WHEN:=""                                                                                       
				MsUnlock()
			Endif	
			
			
			if rtrim(X3_CAMPO)=='C1_CODCOMP'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1922")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL:="A"
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='C1_UNIDREQ'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1921")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL:="A"
				MsUnlock()
			Endif	


			if rtrim(X3_CAMPO)=='CNB_PRODUTO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1920 /  1919")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VALID:='ExistCPO("SB1") .And. CN200VldProd(M->CNB_PRODUT) .And. cn200MultT() .And. Cn300VlServ(a,c,d)'
			   (cTrbAlias3)->X3_WHEN:=''
				MsUnlock()
			Endif				
 			
			if rtrim(X3_CAMPO)=='C8_PRAZO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1918")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_OBRIGAT:=""
				MsUnlock()
			Endif				


			if rtrim(X3_CAMPO)$'CNE_QUANT,CNE_QTDSOL,CNE_QTAMED,C6_QTDVEN,C7_QUANT,C7_QTDSOL,CNB_QUANT,CNB_QTDMED,C1_QUANT'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1943")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_TAMANHO:=18
			   (cTrbAlias3)->X3_DECIMAL:=8
			   (cTrbAlias3)->X3_PICTURE:='@E 999,999,999.99999999'
				MsUnlock()
			Endif			
			
			if rtrim(X3_CAMPO)$'CNB_VLUNIT,CNE_VLUNIT,CNE_VUNORI,C1_VUNIT,C1_PRECO,C8_PRECO,C7_PRECO,D1_VUNIT,C6_PRCVEN,C6_PRUNIT,C9_PRCVEN,D2_PRCVEN,CK_PRUNIT,CNF_VLPREV,CNF_VLREAL'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1943")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_TAMANHO:=18
			   (cTrbAlias3)->X3_DECIMAL:=4
			   (cTrbAlias3)->X3_PICTURE:='@E 99,999,999,999.9999'
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='NG_GRUPO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1976")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_RELACAO:='GetSX8Num("SNG","NG_GRUPO")'
				MsUnlock()
			Endif			
			
			if rtrim(X3_CAMPO)=='AI6_NOMEWS'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1984")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_TAMANHO := 120
				MsUnlock()
			Endif		
			
			if rtrim(X3_CAMPO)=='AI5_NOMFOR'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 1984")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_TAMANHO := 40
				MsUnlock()
			Endif		


			if rtrim(X3_CAMPO)=='CN9_TPCTO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2026")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL :='A'
				MsUnlock()
			Endif		

			if rtrim(X3_CAMPO)=='CN9_TIPREV'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2026")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL :='A'
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='AL_TPLIBER'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2041")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL :='A'
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='AL_NOME'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2035")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_CONTEXT  :='R'
				MsUnlock()
			Endif	

			if rtrim(X3_CAMPO)=='CT1_CCOBRG'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2064")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL  :='V'
			   (cTrbAlias3)->X3_RELACAO  :='"1"'                                                                                                                             
				MsUnlock()
			Endif	

			if rtrim(X3_CAMPO)=='B1_COD'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2066")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_RELACAO  :='GetSX8Num("SB1","B1_COD")'                                                                                                                             
				MsUnlock()
			Endif	
			
			if (rtrim(X3_CAMPO)+';')$'SY1_EMAIL;SY1_TEL;SY1_FAX;SY1_GRAPROV;SY1_GRUPOCOM;SY1_GRAPRCP;'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2028")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VISUAL := 'A'                                                                                                                           
				MsUnlock()
			Endif	
			
			if rtrim(X3_CAMPO)=='CNN_CONTRA'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2099")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_RELACAO  :='CN9->CN9_NUMERO'                                                                                                                            
			MsUnlock()
			
			if rtrim(X3_CAMPO)=='CNN_TRACOD'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2099")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_RELACAO  :='"001"'                                                                                                                           
			MsUnlock()

			if rtrim(X3_CAMPO)=='AKD_ITCTB'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2038")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_F3  :='XCTA'                                                                                                                           
			MsUnlock()			
				
			if rtrim(X3_CAMPO)=='E2_PREFIXO'
				conout(rtrim(cTrbAlias3)+" "+rtrim(X3_CAMPO)+ " Redmine: 2038")
				RecLock(cTrbAlias3) 			
			   (cTrbAlias3)->X3_VLUSER  :="VAZIO.OR.(EXISTCPO.AND.If(If(Type('lF050Auto')#'U',lF050Auto,.F.),.T.,!'TTX'$M->E2_PREFIXO))"                                                                                                                           
			MsUnlock()			
				

				
				
			dbSkip()
		Enddo

		(cTrbAlias3)->(dbCloseArea())
	Next

	If Select(cTrbAlias6) > 0
		(cTrbAlias6)->(dbCloseArea())
	Endif

	For nLoop6 := 1 To Len(aTabSX6)
		dbUseArea( .T., aTabSX6[nLoop6, 5], aTabSX6[nLoop6, 3], cTrbAlias6, .T. , .F. )

		Do While ! Eof()
		
			if rtrim(X6_VAR)=='MV_APROVSC'
				conout(rtrim(cTrbAlias6)+" "+rtrim(X6_VAR)+ " Redmine: 2084")
				RecLock(cTrbAlias6) 			
			   (cTrbAlias6)->X6_CONTEUD :=  '.F.'                                                                                                                        
			MsUnlock()				
			
			if rtrim(X6_VAR)=='MV_PCOWFCT'
				conout(rtrim(cTrbAlias6)+" "+rtrim(X6_VAR)+ " Redmine: 2085")
				RecLock(cTrbAlias6) 			
			   (cTrbAlias6)->X6_TIPO :=  'N'    
			   (cTrbAlias6)->X6_CONTEUD :=  1    			   
			MsUnlock()
			
			
			if rtrim(X6_VAR)=='MV_PABRUTO'
				conout(rtrim(cTrbAlias6)+" "+rtrim(X6_VAR)+ " Redmine: 1975")
				RecLock(cTrbAlias6) 			
			   (cTrbAlias6)->X6_CONTEUD :=  '1'    			   
			MsUnlock()				
			 
			dbskip()

		Enddo
		(cTrbAlias6)->(dbCloseArea())
	Next

	If Select(cTrbAlias7) > 0
		(cTrbAlias7)->(dbCloseArea())
	Endif

	For nLoop7 := 1 To Len(aTabSX7)
		dbUseArea( .T., aTabSX7[nLoop7, 5], aTabSX7[nLoop7, 3], cTrbAlias7, .T. , .F. )
		Do While ! Eof()

			if rtrim(X7_CAMPO)=='CT1_CONTA' .and. rtrim(X7_SEQUENC)=='002'
				conout(rtrim(cTrbAlias7)+" "+rtrim(X7_CAMPO)+ " Redmine: 1941")
				RecLock(cTrbAlias7) 			
			   (cTrbAlias7)->X7_REGRA:="SubStr(M->CT1_CONTA,1,4)"
				MsUnlock()
			Endif				
		
			if rtrim(X7_CAMPO) == 'C1_XCONTPR' .and. rtrim(X7_SEQUENC) == '002'
				conout(rtrim(cTrbAlias7)+" "+rtrim(X7_CAMPO)+ " Redmine: 2152")
				RecLock(cTrbAlias7) 			
			   (cTrbAlias7)->X7_REGRA := "IIF(!Empty(M->C1_XCONTPR),'1',M->C1_TPSC)"
				MsUnlock()
			Endif		
					
			dbskip()
		Enddo
		(cTrbAlias7)->(dbCloseArea())
	Next

	If Select(cTrbAlias1) > 0
		(cTrbAlias1)->(dbCloseArea())
	Endif

	For nLoop1 := 1 To Len(aTabSX1)
		dbUseArea( .T., aTabSX1[nLoop1, 5], aTabSX1[nLoop1, 3], cTrbAlias1, .T. , .F. )
		Do While ! Eof()

			if rtrim(X1_GRPSXG)=='001'
				conout(rtrim(cTrbAlias1)+" "+rtrim(X1_PERGUNT)+ " Redmine: 2025")
				RecLock(cTrbAlias1) 			
			   (cTrbAlias1)->X1_TAMANHO := 8
				MsUnlock()
			Endif			
	
			
			dbskip()
		Enddo
		(cTrbAlias1)->(dbCloseArea())
	Next



	
/*
SXA
*/	
	
If Select(cTrbAliasA) > 0
		(cTrbAliasA)->(dbCloseArea())
	Endif

	For nLoopA := 1 To Len(aTabSXA)
		dbUseArea( .T., aTabSXA[nLoopA, 5], aTabSXA[nLoopA, 3], cTrbAliasA, .T. , .F. )
		Do While ! Eof()



			dbskip()
		Enddo
		(cTrbAliasA)->(dbCloseArea())
	Next

/*  SXB */

If Select(cTrbAliasB) > 0
		(cTrbAliasB)->(dbCloseArea())
	Endif

	For nLoopB := 1 To Len(aTabSXB)
		dbUseArea( .T., aTabSXA[nLoopB, 5], aTabSXB[nLoopB, 3], cTrbAliasB, .T. , .F. )
		Do While ! Eof()



			dbskip()
		Enddo
		(cTrbAliasB)->(dbCloseArea())
	Next


/*  SX9 */

If Select(cTrbAlias9) > 0
		(cTrbAlias9)->(dbCloseArea())
	Endif

	For nLoop9 := 1 To Len(aTabSX9)
		dbUseArea( .T., aTabSX9[nLoop9, 5], aTabSX9[nLoop9, 3], cTrbAlias9, .T. , .F. )
		Do While ! Eof()

			if rtrim(X9_DOM)=='SA6' .and. rtrim(X9_CDOM)$'SA1,SE1,SEB,SEJ'
				conout(rtrim(cTrbAlias9)+" "+rtrim(X9_DOM )+ " Redmine: 1881")			
				RecLock(cTrbAlias9)
				(cTrbAlias9)->D_E_L_E_T_='*'
				MsUnlock()
			Endif		
		
		


			dbskip()
		Enddo
		(cTrbAlias9)->(dbCloseArea())
	Next
	
	
	conout("---- FIM ----")

/*
If Select(cTrbAlias3) > 0
(cTrbAlias3)->(dbCloseArea())
Endif
For nLoop3 := 1 To Len(aTabSX1)
dbUseArea( .T., aTabSX1[nLoop3, 5], aTabSX1[nLoop3, 3], cTrbAlias3, .T. , .F. )
Do While ! Eof()
If (ALLTRIM(X1_GRUPO) == "MTA996") .and. (ALLTRIM(X1_ORDEM)=="07" .or. ALLTRIM(X1_ORDEM)=="10")
RecLock(cTrbAlias3)
(cTrbAlias3)->X1_GRPSXG := ""
MsUnlock()
Endif
dbskip()
Enddo
(cTrbAlias3)->(dbCloseArea())
Next
*/