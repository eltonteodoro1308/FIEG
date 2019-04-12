#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120APV
Ponto de entrada para alterar o grupo de aprovação.

@type function
@author Carlos Henrique
@since 15/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Grupo de Aprovação.
/*/
/*/================================================================================================================================/*/

USER FUNCTION MT120APV()     

Local aArea		   := GETAREA()
Local cTab		   := GETNEXTALIAS()
Local cGrpAprov    := ""
Local cQry		   := ""
Local nTot		   := 0
Local _MV_XINSREC  := ""
Local lContinue	   := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< 01/10/2016 - Thiago Rasmussen - Para os pedidos de compra gerados através de encerramento de medição, não necessita alçada de aprovação >--
IF FUNNAME() == 'CNTA120'
	_MV_XINSREC := SuperGetMV("MV_XINSREC", .F., "", SUBSTR(cFilAnt,1,4))
	IF cFilAnt $(_MV_XINSREC)
		lContinue := .F.
	ENDIF	
ENDIF	
	
//--< 30/07/2014 - Thiago Rasmussen - Quando registro de preço, direciona para grupo específico. >--
If lContinue
	IF !Empty(SC1->C1_XCONTPR)
		cGrpAprov := SuperGetMV("MV_XGAPSRP", .F.)
	ELSE
		//--< 03/10/2013 - Thiago Rasmussen - Foi criado o campo "COJ_CODGAP", específicamente para gravar o grupo de aprovação de PC. >--
		cQry:= "SELECT COALESCE(COJ_CODGAP,'') AS GRPAPR FROM " + RETSQLNAME("COJ") + " COJ " + CRLF +;
			   "WHERE COJ_FILIAL = '" + XFILIAL("COJ") + "' " 				+ CRLF +;
			   "  AND COJ_PREFIX = SUBSTRING('" + SC7->C7_CONTA + "',1,2) " + CRLF +;
			   "  AND COJ_CUSTO	= '" + SC7->C7_CC + "' " 					+ CRLF +;
			   "  AND COJ.D_E_L_E_T_ = ' ' "

		TcQuery cQry NEW ALIAS (cTab)	                                                   
		(cTab)->(dbSelectArea((cTab)))
		COUNT To nTot         
				  
		(cTab)->(dbGoTop())                               	
		IF(cTab)->(!EOF()) .AND. nTot == 1 
			IF !Empty((cTab)->GRPAPR)		
				cGrpAprov:= (cTab)->GRPAPR
			EndIf	
		EndIf
	EndIf
EndIf

//--< 03/10/2013 - Thiago Rasmussen - Caso não exista nenhum grupo definido para aprovação do PC, sugerir o grupo de aprovação >--
//--<                                 definido como default, na tabela de parâmetros. >-------------------------------------------
IF Empty(cGrpAprov)
	cGrpAprov := SuperGetMV("MV_PCAPROV", .F.) 
EndIf	
	
If Select(cTab) > 0
	(cTab)->(DbCloseArea())
EndIf

RestArea(aArea)
	
Return cGrpAprov
