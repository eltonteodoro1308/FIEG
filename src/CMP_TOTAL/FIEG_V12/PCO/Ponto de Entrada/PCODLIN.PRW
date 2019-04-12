#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCODLIN
Validacao de exclusão de linha da planilha.

@type function
@author TOTVS
@since 16/03/2012
@version P12.1.23

@param Parametro_01, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function PCODLIN()

Local _lRet := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF GDFieldGet("AK2_XSTS")  == "1" 							// Orçamento finalizado
	MsgAlert("Este orçamento está finalizado e não poderá ser excluído.","Atenção!")
	_lRet := .F.
ENDIF

Return _lRet
