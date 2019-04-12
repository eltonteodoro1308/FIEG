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
	Public cJustCom	:= IIF(_nOpcx==3 .or. Empty(SC1->C1_XJUSTIF),Space(500),SC1->C1_XJUSTIF)
	Public _cItCta	:= IIF(_nOpcx==3 .or. Empty(SC1->C1_ITEMCTA),Space(TamSx3("C1_ITEMCTA")[1]),SC1->C1_ITEMCTA)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Campo Item contabil
	@ 070+25,aPosGet[1,1] SAY Alltrim(RetTitle("C1_ITEMCTA")) OF oNewDialog PIXEL SIZE 038,006
	@ 069+25,aPosGet[1,2] MSGET _cItCta  F3 CpoRetF3("C1_ITEMCTA") Picture PesqPict("SC1","C1_ITEMCTA") When !(_nOpcx==2 .or. _nOpcx==6) ;
	Valid NAOVAZIO() .and. CheckSX3("C1_ITEMCTA",_cItCta) .and. Ctb105Item() Of oNewDialog PIXEL HASBUTTON

	//Campo de Justificativa
	@ 086+25,aPosGet[1,1]  SAY Alltrim(RetTitle("C1_XJUSTIF")) OF oNewDialog PIXEL SIZE 038,006
	@ 085+25,aPosGet[1,2] MSGET oJustCom VAR cJustCom SIZE 430,10 VALID NAOVAZIO() WHEN !(_nOpcx==2 .or. _nOpcx==6) PIXEL OF oNewDialog

	RestArea(_aArea)

Return()