#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN130INC
Ponto de entrada executado no momeno da inclusao das medicoes de contrato.

@type function
@author Cadubitski - TOTVS
@since Mai/2010
@version P12.1.23

@obs Projeto ELO

@history 11/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array contendo o aHeader e aCols.
/*/
/*/================================================================================================================================/*/

User Function CN130Inc()

Local nx
Local aHeader 	:= ParamIXB[1]
Local aCols 	:= ParamIXB[2]
Local nPosDtEnt	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'CNE_DTENT'})
Local nPosItm   := aScan(aHeader,{|x| AllTrim(x[2]) == 'CNE_ITEM'})
Local nPosObs   := aScan(aHeader,{|x| AllTrim(x[2]) == 'CNE_OBS'})
Local cQuery    := ''
Local cAlias    := GetNextAlias()
Local nPos

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Filtra os itens da planilha >-------------------------
cQuery := "SELECT CNB.CNB_ITEM " //, CNB.CNB_XOBS "
cQuery += "FROM "+RetSQLName("CNB")+" CNB WHERE "
cQuery += "CNB.CNB_FILIAL = '"+xFilial('CNB')+"' AND "
cQuery += "CNB.CNB_CONTRA = '"+M->CND_CONTRA+"' AND "
cQuery += "CNB.CNB_REVISA = '"+M->CND_REVISA+"' AND "
cQuery += "CNB.CNB_NUMERO = '"+M->CND_NUMERO+"' AND "
cQuery += "CNB.D_E_L_E_T_ = ' '"

//--< Executa query >---------------------------------------
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlias, .F., .T. )

//--< Replica informacao de campos criados na CNB para os campos criados na CNE >--
While !(cAlias)->(Eof())
	If (nPos := aScan(aCols,{|x| x[nPosItm] == (cAlias)->CNB_ITEM})) > 0
  		//aCols[nPos,nPosObs] := (cAlias)->CNB_XOBS //Replica de Campo Observação da Planilha do Contrato para Medição
 	EndIf
 	(cAlias)->(dbSkip())
EndDo

Return {aHeader,aCols}
