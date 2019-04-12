#Include "Protheus.ch"

Static aCntgBak	:= {} 										// Backup de Contingencias

/*/================================================================================================================================/*/
/*/{Protheus.doc} PC500LIB
Funcao para Liberar a Solicitação de Contingencia.

@type function
@author Thiago Rasmussen
@since 23/04/12
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function PC500LIB()

Local _cNumSc   := IIF(ALI->(FieldPos("ALI_XNUMSC")) > 0,ALI->ALI_XNUMSC,"")
Local _cNumCt   := ALI->ALI_CDCNTG
Local _aResult  := {}
Local _aAreaAtu := GetArea()
Local _aAreaALI := ALI->(GetArea())

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Verifica se é lançamento de SC >----------------------
IF ALI->ALI_PROCESS <> "000051"
	Return()
ENDIF

ALI->(dbsetorder(1))
If ALI->(dbSeek(xFilial("ALI") + _cNumCt))
	_cAreaALI := ALI->(GetArea())
	While ALI->(!Eof()) .and. ALI->ALI_FILIAL == XFilial("ALI") .and. ALI->ALI_CDCNTG == _cNumCt
		IF !(ALI->ALI_STATUS $ "03/05")
			Aadd(_aResult, ALI->ALI_NOME)
		ENDIF
		ALI->(dbSkip())
	EndDo
	RestArea(_cAreaALI)
EndIf

If Len(_aResult) == 0 										// liberado
	
	_cMail := UsrRetMail(ALI->ALI_SOLIC)
	_cBody := "Prezado  " +ALI->ALI_NOMSOL + CRLF + CRLF
	_cBody += "Sua contigência Nr. " + ALI->ALI_CDCNTG + " foi aprovada." + CRLF + CRLF
	_cBody += "Data da Aprovação : " + Dtoc(dDataBase)+"  -  Hora : " + Time() + CRLF + CRLF
	ACSendMail( ,,,,_cMail,"Contig. " + ALI->ALI_CDCNTG+" (APROVADA)",_cBody)
	
	dbSelectArea("ALJ")
	ALJ->(dbSetOrder(1))
	ALJ->(dbSeek( xFilial("ALJ") + _cNumCt ))
	
	While ALJ->(!Eof()) .and. ALJ->ALJ_FILIAL == XFilial("ALJ") .and. ALJ->ALJ_CDCNTG == _cNumCt
		
		aAreaAKD := AKD->(GetArea())
		
		DbSelectArea("ALJ")
		cChave := Padr("ALJ"+&(IndexKey())+ "02",Len(AKD->AKD_CHAVE))
		
		_cChaveSC1 := Right(Alltrim(ALJ->ALJ_CHAVE),TamSX3("C1_NUM")[1]+TamSX3("C1_ITEM")[1])
		
		SZW->(dbSetOrder(1))
		IF SZW->(MsSeek(xFilial("SZW")+_cChaveSC1))
			
			_cFilBkp := cFilAnt
			While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+_cChaveSC1
				
				cFilAnt := SZW->ZW_CODEMP					// Altera empresa
				
				_NPERCEMP := SZW->ZW_PERC
				
				_fPCOLib(cChave)
				
				cFilAnt := _cFilBkp							// Restaura filial
				
				SZW->(dbSkip())
			Enddo
		ELSE
			
			_fPCOLib(cChave)
			
		ENDIF
		
		RestArea(aAreaAKD)
		
		_NPERCEMP := 0
		ALJ->(dbSkip())
	Enddo
	
	//--< Libera SC >---------------------------------------
	SC1->(dbSetOrder(1))
	SC1->(dbSeek(XFilial("SC1")+_cNumSc))
	
	While SC1->(!Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == _cNumSc
		
		RecLock("SC1",.F.)
		SC1->C1_APROV := "L" 								//Liberado
		SC1->(MsUnlock())
		
		SZW->(dbSetOrder(1))
		IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))
			
			_cFilBkp := cFilAnt
			While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
				
				cFilAnt := SZW->ZW_CODEMP					// Altera empresa
				
				_NPERCEMP := SZW->ZW_PERC
				
				PcoIniLan('000051')
				PcoDetLan('000051','02','MATA110')
				PcoFinLan('000051')
				
				cFilAnt := _cFilBkp							// Restaura filial
				
				SZW->(dbSkip())
			Enddo
		ELSE
			PcoIniLan('000051')
			PcoDetLan('000051','02','MATA110')
			PcoFinLan('000051')
		ENDIF
		
		//--< FSW - Alteração para o Gap097 - CNI >---------
		//--< Se parametro SI_XMED for igual a 1 deve fazer a medição na liberação da solicitação de compras >--
		If GetMv("SI_XMED", .F.) == "1"
			_aRecSC1 := SC1->(GetArea())
			U_CNI109AL(_cNumSc,"SC",2)
			RestArea(_aRecSC1)
		EndIf
		
		_NPERCEMP := 0
		SC1->(dbSkip())
	Enddo
	
Endif

RestArea(_aAreaAtu)
ALI->(RestArea(_aAreaALI))

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} _fPCOLib
Funcao para Liberar a Solicitação de Contingencia.

@type function
@author Thiago Rasmussen
@since 08/06/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function _fPCOLib(cChave)

AKD->(dbSetOrder(10))
IF AKD->(dbSeek(xFilial("AKD") + cChave ))
	PcoBackupAKD(aCntgBak)									// Utilizado para recuperar lançamentos caso processo seja cancelado
	PcoIniLan("000356",.F.)
	PcoDetLan("000356","02","PCOA530",.T.)
	PcoFinLan("000356",,,.F.)
ENDIF

//--< O PcoIniLan deve ser repetido para nao dar erro de UNQ no Recall do Empenho >--
PcoIniLan("000356",.F.)
PcoDetLan("000356","01","PCOA530")
DbSelectArea("ALJ")											// Utilizado para apagar lançamento caso processo seja cancelado
cChave := Padr("ALJ"+&(IndexKey())+ "01",Len(AKD->AKD_CHAVE))

AKD->(dbSetOrder(10))
IF AKD->(dbSeek(xFilial("AKD") + cChave ))
	aAdd(aCntgBak, { AKD->(Recno()), {} } )
EndIf
PcoFinLan("000356",,,.F.)

Return()
