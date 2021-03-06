#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCODLIN
Validacao de exclus�o de linha da planilha.

@type function
@author TOTVS
@since 16/03/2012
@version P12.1.23

@param Parametro_01, Num�rico, Informe a descri��o do 1� par�mtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function PCODLIN()

Local _lRet := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF GDFieldGet("AK2_XSTS")  == "1" 							// Or�amento finalizado
	MsgAlert("Este or�amento est� finalizado e n�o poder� ser exclu�do.","Aten��o!")
	_lRet := .F.
ENDIF

Return _lRet
