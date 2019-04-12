#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PC500BLQ
Funcao para Cancelar a Solicitação de Contingencia.

@type function
@author Daniel Tavares - TOTVS
@since 29/02/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function PC500BLQ()

Local _cNumCt   := ALJ->ALJ_CDCNTG
Local _aResult  := {}
Local _aAreaAtu := GetArea()
Local _aAreaALI := ALI->(GetArea())

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("ALI")
_cFilter := dbFilter()
SET FILTER TO

IF ALI->(dbSeek(XFilial("ALI")+_cNumCt)) .and. ALI->(FieldPos("ALI_XNUMSC")) > 0
	_cNumSc := ALI->ALI_XNUMSC
ELSE
	_cNumSc := ""
ENDIF

//--< Verifica se é lançamento de SC >----------------------
IF ALI->ALI_PROCESS <> "000051"
	SET FILTER TO &_cFilter									// Restaura Filtro
	Return()
ENDIF

_cMot := MotReprov() 										// Chama tela para cadastrar o Motivo do Cancelamento.

_cMail := UsrRetMail(ALI->ALI_SOLIC)
_cBody := "Prezado " + ALI->ALI_NOMSOL + CRLF + CRLF
_cBody += "Sua contigência Nr. " + ALI->ALI_CDCNTG + " foi reprovada." + CRLF + CRLF
_cBody += "Data da Reprovação : " + Dtoc(dDataBase) + "  -  Hora :" + Time() + CRLF + CRLF
_cBody += "Motivo:" + CRLF
_cBody += _cMot
ACSendMail( ,,,,_cMail,"Contig. "+ALI->ALI_CDCNTG+" (REPROVADA)",_cBody)

//--< Estorno das contingencias >---------------------------
dbSelectArea("ALJ")
ALJ->(dbSetOrder(1))
ALJ->(dbSeek( xFilial("ALJ") + _cNumCt ))

While !ALJ->(Eof()) .and. ALJ->ALJ_FILIAL == xFilial("ALJ") .and. ALJ->ALJ_CDCNTG == _cNumCt
	
	_cChaveSC1 := Right(Alltrim(ALJ->ALJ_CHAVE),TamSX3("C1_NUM")[1]+TamSX3("C1_ITEM")[1])
	
	SZW->(dbSetOrder(1))
	IF SZW->(MsSeek(xFilial("SZW")+_cChaveSC1))
		
		_cFilBkp := cFilAnt
		While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+_cChaveSC1
			
			cFilAnt := SZW->ZW_CODEMP						// Altera empresa
			
			_NPERCEMP := SZW->ZW_PERC
			
			PcoIniLan("000356")
			PcoDetLan("000356","01","PCOA530",.T.) 			// Deleta Empenho caso exista
			PcoDetLan("000356","02","PCOA530",.T.) 			// Deleta Empenho caso exista
			PcoFinLan("000356")
			
			cFilAnt := _cFilBkp								// Restaura filial
			
			SZW->(dbSkip())
		Enddo
	ELSE
		
		PcoIniLan("000356")
		PcoDetLan("000356","01","PCOA530",.T.) 				// Deleta Empenho caso exista
		PcoDetLan("000356","02","PCOA530",.T.) 				// Deleta Empenho caso exista
		PcoFinLan("000356")
		
	ENDIF
	
	_NPERCEMP := 0
	ALJ->(dbSkip())
Enddo

//--< Libera SC >-------------------------------------------
SC1->(dbSetOrder(1))
SC1->(dbSeek(XFilial("SC1")+_cNumSc))

While SC1->(!Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == _cNumSc
	
	RecLock("SC1",.F.)
		SC1->C1_APROV   := "F" 								// Reprov. Falta de Orçamento
		SC1->C1_XMOTIVO := _cMot
	SC1->(MsUnlock())
	
	SZW->(dbSetOrder(1))
	IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))
		
		_cFilBkp := cFilAnt
		While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
			
			cFilAnt := SZW->ZW_CODEMP						// Altera empresa
			
			_NPERCEMP := SZW->ZW_PERC
			
			//--< Exclui os saldos SC caso exista >---------
			PcoIniLan('000051')
			PcoDetLan('000051','02','MATA110',.T.)
			PcoFinLan('000051')
			
			cFilAnt := _cFilBkp								// Restaura filial
			
			SZW->(dbSkip())
		Enddo
	ELSE
		//--< Exclui os saldos SC caso exista >-------------
		PcoIniLan('000051')
		PcoDetLan('000051','02','MATA110',.T.)
		PcoFinLan('000051')
	ENDIF
	
	_NPERCEMP := 0
	SC1->(dbSkip())
Enddo

SET FILTER TO &_cFilter										// Restaura Filtro

RestArea(_aAreaAtu)
ALI->(RestArea(_aAreaALI))

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} MotReprov
Gerar o Motivo do cancelamento do Pedido de ³Contingencia.

@type function
@author Daniel Tavares - TOTVS
@since 29/02/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Motivo da Reprovação.
/*/
/*/================================================================================================================================/*/

Static Function MotReprov()

Local oOK
Local oGet
Local cGet := Space(60)
Local oMot
Local cRet

Static oDlg

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
DEFINE MSDIALOG oDlg TITLE "Motivo da Reprovação" FROM 000, 000  TO 150, 400 COLORS 0, 16777215 PIXEL

@006,010 SAY oMot PROMPT "Motivo da Reprovação:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
@015,010 MSGET oGet VAR cGet SIZE 174, 030 OF oDlg PICTURE "@!" COLORS 0, 16777215 PIXEL
@050,152 BUTTON oOK PROMPT "OK" SIZE 031, 019 OF oDlg PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If !Empty(cGet)
	cRet := cGet
Else
	cRet:= " "
EndIf

Return(cRet)
