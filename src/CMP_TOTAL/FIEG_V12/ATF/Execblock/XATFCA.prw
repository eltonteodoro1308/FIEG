#Include 'Protheus.ch'
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XATFCA
No caso de constru��es em andamento, manter o c�digo base do ativo e incrementar o item.

@type function
@author Thiago Rasmussen
@since 30/08/2013
@version P12.1.23

@param XFIELD, Caractere, Nome do campo.

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, C�digo do bem.

/*/
/*/================================================================================================================================/*/

User Function XATFCA(XFIELD)

	Local sRETORNO := ""

//	//--< Log das Personaliza��es >-----------------------------
//	U_LogCustom()
//
//	//--< Processamento da Rotina >-----------------------------
//
//	DO CASE
//		CASE XFIELD == "N1_CBASE"
//			IF FunName() == "ATFA012" .AND. SN1->N1_GRUPO == "0104" .AND. SN1->N1_FILIAL == CFILANT
//				MsgAlert("A inclus�o desse ativo est� sendo baseado em uma constru��o em andamento, portanto o c�digo base vai ser mantido e o item vai ser incrementado." + CRLF + CRLF+ "C�digo de Origem: " + SN1->N1_CBASE + CRLF + "Item de Origem: " + SN1->N1_ITEM + CRLF + "Descri��o de Origem: " + SN1->N1_DESCRIC,"XATFCA")
//				sRETORNO := SN1->N1_CBASE
//			ELSE
//				sRETORNO := "00000000"
//			ENDIF
//		CASE XFIELD == "N1_ITEM"
//			IF FunName() == "ATFA012" .AND. SN1->N1_GRUPO == "0104" .AND. SN1->N1_FILIAL == CFILANT
//				sRETORNO := SOMA1(ALLTRIM(SN1->N1_ITEM))
//			ELSE
//				sRETORNO := "0001"
//			ENDIF
//		CASE XFIELD == "N1_DESCRIC"
//			IF FunName() == "ATFA012" .AND. SN1->N1_GRUPO == "0104" .AND. SN1->N1_FILIAL == CFILANT
//				sRETORNO := ALLTRIM(SN1->N1_DESCRIC)
//			ELSE
//				sRETORNO := ""
//			ENDIF
//		CASE XFIELD == "N1_GRUPO"
//			IF FunName() == "ATFA012" .AND. SN1->N1_GRUPO == "0104" .AND. SN1->N1_FILIAL == CFILANT
//				sRETORNO := "0104"
//			ELSE
//				sRETORNO := ""
//			ENDIF
//	ENDCASE

RETURN(sRETORNO)