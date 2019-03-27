#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XDADOSNF
Obtenção de algumas informações específicas, para impressão de uma pré-nota personalizada.

@type function
@author Iatan Marques
@since 11/09/2013
@version P12.1.23

@param filial, Caractere, Código da Filial.
@param pedido, Caractere, Código do Pedido.
@param fornecedor, Caractere, Código do Fonecedor.
@param loja, Caractere, Código da Loja.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Informações específicas, para impressão de uma pré-nota personalizada.

/*/
/*/================================================================================================================================/*/

User Function XDADOSNF(filial, pedido, fornecedor, loja)

	Local cQuery := ""
	Local _cAlias := GetNextAlias()
	Local dadosNF := ""
	Local dtTemp := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	cQuery  = " SELECT D1_DOC, D1_SERIE, D1_DTDIGIT, D1_EMISSAO"
	cQuery += " FROM SD1010 WITH (NOLOCK)"
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND"
	cQuery += "       D1_FILIAL = '" + filial + "' AND"
	cQuery += "       D1_PEDIDO = '" + pedido + "' AND"
	cQuery += "       D1_FORNECE = '"+ fornecedor + "' AND"
	cQuery += "       D1_LOJA = '"+ loja + "' "

	If Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

	DbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())

	While !(_cAlias)->(Eof())

		dadosNF := TRIM((_cAlias)->D1_DOC) + " " + TRIM((_cAlias)->D1_SERIE) + " "
		If (_cAlias)->D1_DTDIGIT <> ''
			dtTemp := (_cAlias)->D1_DTDIGIT
			dadosNF := dadosNF + SUBSTRING(dtTemp,7,2)+"/"+SUBSTRING(dtTemp,5,2)+"/"+SUBSTRING(dtTemp,1,4)
		Else
			dadosNF := dadosNF + "          "
		EndIf

		dadosNF := dadosNF + "  "

		If (_cAlias)->D1_EMISSAO <> ''
			dtTemp := (_cAlias)->D1_EMISSAO
			dadosNF := dadosNF + SUBSTRING(dtTemp,7,2)+"/"+SUBSTRING(dtTemp,5,2)+"/"+SUBSTRING(dtTemp,1,4)
		Else
			dadosNF := dadosNF + "          "
		EndIf

		(_cAlias)->(dbSkip())
	End

	(_cAlias)->(dbCloseArea())

Return(dadosNF)