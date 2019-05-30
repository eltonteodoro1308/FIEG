#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNTA120E
Ponto de entrada para refazer a query retirando os contratos compartilhados.

@type function
@author Bruna Paola - TOTVS
@since 03/02/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 28/05/2019, elton.alves@TOTVS.com.br, Retirada do campo CN9_VLDCTR das condições de pesquisa da query.

@return Caractere, String com query para ser adicionada ao Filtro.
/*/
/*/================================================================================================================================/*/

User Function CN120QCC()

Local cQuery1 := PARAMIXB[1]
//Local cQuery2 := PARAMIXB[2]
//Local cQuery3 := PARAMIXB[3]
Local cQuery4 := PARAMIXB[4]
Local cQuery5 := PARAMIXB[5]

Local cQuery  := ""
Local cQuery6 := ""
Local cParam  := GetMV("SI_XCRP")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Se não puder fazer medição de contrato de registro de preço e compartilhado pela rotina de medição >--
If (cParam == 'N')
	// Filtrar contratos de registro de preço
	// Filtrar contratos do gestor do contrato
	// Filtrar contratos compartilhados
	cQuery6 := " CN9.CN9_XREGP <> '1' " //" and CN9.CN9_XREGP <> '1' "
	cQuery6 += " and CNN.CNN_USRCOD = '" + RetCodUsr() + "'"
	cQuery6 += " and not exists (select PB1.* from " + RetSqlName("PB1") + " PB1 "
	cQuery6 += "                 where PB1.PB1_NUMERO = CN9.CN9_NUMERO "
	cQuery6 += "                   and PB1.PB1_REVISA = CN9.CN9_REVISA "
	cQuery6 += "                   and PB1.PB1_FILCN9 = '" + xFilial("CN9") + "' "
	cQuery6 += "                   and PB1.D_E_L_E_T_ = ' ' ) "
EndIf

cQuery := cQuery1
cQuery +=/* cQuery2+*/" "+cQuery6+" "+cQuery4+" "+cQuery5

//IF CN9->(FieldPos("CN9_VLDCTR"))> 0
//	cQuery := cQuery1
//	cQuery += cQuery2+" "+cQuery6+" "+cQuery4
//	cQuery += " UNION "
//	cQuery += cQuery1
//	cQuery += cQuery3+" "+cQuery6+" "+cQuery4+" "+cQuery5
//ELSE
//	cQuery := cQuery1
//	cQuery += cQuery3+" "+cQuery6+" "+cQuery4+" "+cQuery5
//ENDIF

Return cQuery
