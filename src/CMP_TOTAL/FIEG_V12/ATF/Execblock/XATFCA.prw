#Include 'Protheus.ch'
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XATFCA
RdMake utilizado no Inicializador Padr�o de Campos do ATIVO (SN1); No caso de constru��es em andamento, manter o c�digo base do ativo e incrementar o item.

@type function
@author Thiago Rasmussen
@since 30/08/2013
@version P12.1.23

@param XFIELD, Caractere, Nome do campo.

@obs Desenvolvimento FIEG

@return Caractere, C�digo do Ativo, Item Descri��o ou Grupo.

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.
@history 30/04/2019, kley@totvs.com.br, adequa��o do C�digo do Bem para ser carregado do par�metro MV_CBASEAF 
/*/
/*/================================================================================================================================/*/

User Function XATFCA(XFIELD)

Local cRETORNO := ""
Local lGrp0104 := FunName() == "ATFA010" .AND. SN1->N1_GRUPO == "0104" .AND. SN1->N1_FILIAL == CFILANT

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

DO CASE
	CASE XFIELD == "N1_CBASE"
		IF lGrp0104
			MsgAlert("A inclus�o desse ativo est� sendo baseado em uma constru��o em andamento, portanto o c�digo base vai ser mantido e o item vai ser incrementado." + CRLF + CRLF+ "C�digo de Origem: " + SN1->N1_CBASE + CRLF + "Item de Origem: " + SN1->N1_ITEM + CRLF + "Descri��o de Origem: " + SN1->N1_DESCRIC,"XATFCA")
			cRETORNO := SN1->N1_CBASE
		ELSE
			//cRETORNO := "00000000"
			cRETORNO := StrTran(GetMV("MV_CBASEAF"),'"','')
		ENDIF
	CASE XFIELD == "N1_ITEM"
		IF lGrp0104
			cRETORNO := SOMA1(ALLTRIM(SN1->N1_ITEM))
		ELSE
			cRETORNO := "0001"
		ENDIF
	CASE XFIELD == "N1_DESCRIC"
		IF lGrp0104
			cRETORNO := ALLTRIM(SN1->N1_DESCRIC)
		ELSE
			cRETORNO := ""
		ENDIF
	CASE XFIELD == "N1_GRUPO"
		IF lGrp0104
			cRETORNO := "0104"
		ELSE
			cRETORNO := ""
		ENDIF
ENDCASE

RETURN(cRETORNO)
