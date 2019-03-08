#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA19
Funcao chamada pelo PE MT110TEL (Inclusao de campo no cabecalho de SC).

@type function
@author Claudinei Ferreira
@since 09/12/2011
@version P12.1.23

@param oNewDialog, Objeto, Objeto da Dialog da Solicitação de Compras.
@param aPosGet, Array, Array contendo a posiçãi dos Gets da Solicitação de Compras.
@param _nOpcx, Numérico, Opção selecionada na solicitação de compras (Inclusão, Alteração, Exclusão e Consulta).
@param _nReg, Numérico, Numero do recno do registro da solicitação de co mpras selecionada.

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA19(oNewDialog,aPosGet,_nOpcx,_nReg)
	Local _aArea := GetArea()
	Local oJustCom
	Local nTamJustif := 0
	Local lXNewView	:= SuperGetMv("SI_XVIEW19",.F.,.T.)
	Public cJustCom	:= IIF(_nOpcx==3 .or. Empty(SC1->C1_XJUSTIF),Space(7000),SC1->C1_XJUSTIF)
	Public _cItCta	:= IIF(_nOpcx==3 .or. Empty(SC1->C1_ITEMCTA),Space(TamSx3("C1_ITEMCTA")[1]),SC1->C1_ITEMCTA)

	//Campo Item contabil
	@ 070,aPosGet[1,1] SAY Alltrim(RetTitle("C1_ITEMCTA")) OF oNewDialog PIXEL SIZE 038,006
	@ 069,aPosGet[1,2] MSGET _cItCta  F3 CpoRetF3("C1_ITEMCTA") Picture PesqPict("SC1","C1_ITEMCTA") When !(_nOpcx==2 .or. _nOpcx==6) ;
	Valid NAOVAZIO() .and. CheckSX3("C1_ITEMCTA",_cItCta) .and. Ctb105Item() Of oNewDialog PIXEL HASBUTTON

	//Campo de Justificativa
	@ 086,aPosGet[1,1]  SAY Alltrim(RetTitle("C1_XJUSTIF")) OF oNewDialog PIXEL SIZE 038,006

	If lXNewView
		// MsAdvSize - 6 -> Linha final dialog (janela).
		nTamJustif := MsAdvSize()[6]
		nTamJustif := (nTamJustif - 40) * 0.90 // 90% do tamanho restante
		@ 085,aPosGet[1,2]  GET oJustCom VAR cJustCom MEMO SIZE nTamJustif,40 Valid Validamemo(cJustCom) .And. Transform(cJustCom,"@N!") WHEN !(_nOpcx==2 .or. _nOpcx==6) PIXEL OF oNewDialog
	Else
		@ 085,aPosGet[1,2]  GET oJustCom VAR cJustCom MEMO SIZE 606,40 Valid Validamemo(cJustCom) .And. Transform(cJustCom,"@N!") WHEN !(_nOpcx==2 .or. _nOpcx==6) PIXEL OF oNewDialog
	EndIf

	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Validamemo
Valida o o canteúdo da justificativa definida no campo campo Memo.

@type function
@author Claudinei Ferreira
@since 09/12/2011
@version P12.1.23

@param cJustCom, Objeto, .

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para conteúdo válido.

/*/
/*/================================================================================================================================/*/
Static Function Validamemo(cJustCom)

	Local lRet := .T.

	If Empty(cJustCom)
		MsgInfo("Informe a justificativa da compra.","SICOMA19")
		lRet := .F.
	EndIf

	If Len(AllTrim(cJustCom))<=5
		MsgInfo("Justificativa inválida.","SICOMA19")
		lRet := .F.
	EndIf

Return lRet
