#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOE01
Tratamento de historico de lancamentos orcamentarios.

@type function
@author Thiago Rasmussen
@since 09/02/12
@version P12.1.23

@param _cItem, Caractere, Opção utilizada no Lançamento Orçamentário (01-Inclusão, 02-Revisão, 03-Simulação, 04-Finalização)

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Histórico do Lançamento.
/*/
/*/================================================================================================================================/*/

User Function SIPCOE01(_cItem)

Local _cHistPco	:= "PLANILHA: "+Alltrim(AK2->AK2_ORCAME)+" - VER: "+Alltrim(AK2->AK2_VERSAO)+" REF.: "
Local _cFile	:= Alltrim(AK2->AK2_XFILE)
Local _cDum		:= Alltrim(AK2->AK2_XDUM)
Local _cOrcto	:= Alltrim(AK2->AK2_XORCTO)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
Do Case
	Case _cItem == "01" 									// item 01 - Inclusão da Planilha
		If IsInCallStack("U_SIPCOA06")						// Importacao planilha
			_cHistPco += "ORC. COMP. "+_cOrcto
		ElseIf IsInCallStack("U_SIPCOA16")					// Importacao planilha
			_cHistPco += "IMP. ARQ. "+_cFile
		ElseIf IsInCallStack("U_SIPCO17D")					// DUM/RUM
			_cHistPco += "DUM/RUM: "+_cDum
		ElseIf IsInCallStack("U_SIPCOA19")					// Simulacao de Saldo Historico
			_cHistPco += "SALDOS HIST. "
		Else
			_cHistPco += "INCL. MANUAL "
		Endif
		
	Case _cItem == "02" 									// item 02 - Revisão da Planilha
		_cHistPco +="SIMULACAO REV. SALDOS"
		
	Case _cItem == "03" 									// item 03 - Simulação de Planilha
		_cHistPco +="SIMULACAO PLANILHA"
		
	OtherWise 												// item 04 - Finalização da Revisão da Planilha
		_cHistPco +="ALTERACAO SALDO"
		
EndCase

Return(_cHistPco)
