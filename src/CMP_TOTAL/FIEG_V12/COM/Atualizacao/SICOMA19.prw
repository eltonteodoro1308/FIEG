#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA19
Funcao chamada pelo PE MT110TEL (Inclusao de campo no cabecalho de SC).

@type function
@author Claudinei Ferreira - TOTVS
@since 09/12/11
@version P12.1.23

@param oNewDialog, Objeto, Dialog.
@param aPosGet, Array, Array do GetDados.
@param _nOpcx, Numérico, Opção de execução da rotina.
@param _nReg, Numérico, Número do registro.

@obs Projeto ELO Alterado pela FIEG

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SICOMA19(oNewDialog,aPosGet,_nOpcx,_nReg)

Local _aArea 	 := GetArea()
Local oJustCom   
Local nTamJustif := 0
Local lXNewView	 := SuperGetMv("SI_XVIEW19",.F.,.T.)	

Public cJustCom	 := IIF(_nOpcx==3 .or. Empty(SC1->C1_XJUSTIF),Space(7000),SC1->C1_XJUSTIF) 
Public _cItCta	 := IIF(_nOpcx==3 .or. Empty(SC1->C1_ITEMCTA),Space(TamSx3("C1_ITEMCTA")[1]),SC1->C1_ITEMCTA)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Campo Item contabil >---------------------------------
@ 070,aPosGet[1,1] SAY Alltrim(RetTitle("C1_ITEMCTA")) OF oNewDialog PIXEL SIZE 038,006
@ 069,aPosGet[1,2] MSGET _cItCta  F3 CpoRetF3("C1_ITEMCTA") Picture PesqPict("SC1","C1_ITEMCTA") When !(_nOpcx==2 .or. _nOpcx==6) ;
					  Valid NAOVAZIO() .and. CheckSX3("C1_ITEMCTA",_cItCta) .and. Ctb105Item() Of oNewDialog PIXEL HASBUTTON

//--< Campo de Justificativa >------------------------------
@ 086,aPosGet[1,1]  SAY Alltrim(RetTitle("C1_XJUSTIF")) OF oNewDialog PIXEL SIZE 038,006

If lXNewView
	// MsAdvSize - 6 -> Linha final dialog (janela).
	nTamJustif := MsAdvSize()[6]
	nTamJustif := (nTamJustif - 40) * 0.90 					// 90% do tamanho restante
	@ 085,aPosGet[1,2]  GET oJustCom VAR cJustCom MEMO SIZE nTamJustif,40 Valid Validamemo(cJustCom) .And. Transform(cJustCom,"@N!") WHEN !(_nOpcx==2 .or. _nOpcx==6) PIXEL OF oNewDialog
Else
	@ 085,aPosGet[1,2]  GET oJustCom VAR cJustCom MEMO SIZE 606,40 Valid Validamemo(cJustCom) .And. Transform(cJustCom,"@N!") WHEN !(_nOpcx==2 .or. _nOpcx==6) PIXEL OF oNewDialog
EndIf  

RestArea(_aArea)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidaMemo
Validação da Justificativa da Compra, usado no PE MT110TEL (Inclusao de campo no cabecalho de SC).

@type function
@author Claudinei Ferreira - TOTVS
@since 09/12/11
@version P12.1.23

@param cJustCom, Caractere, Texto da Justificativa informada no campo Memo.

@obs Projeto ELO Alterado pela FIEG

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validação for OK.
/*/
/*/================================================================================================================================/*/

Static Function ValidaMemo(cJustCom)

Local lRet	:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Empty(cJustCom)
	MsgInfo("Informe a justificativa da compra.","SICOMA19")
	lRet := .F.
EndIf

If lRet .and. Len(AllTrim(cJustCom)) <= 5
	MsgInfo("Justificativa inválida.","SICOMA19")
	lRet := .F.
EndIf

Return lRet
