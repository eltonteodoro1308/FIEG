#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120APV
Ponto de entrada para alterar o grupo de aprova��o.

@type function
@author Carlos Henrique
@since 15/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Caractere, Grupo de Aprova��o.
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

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< 01/10/2016 - Thiago Rasmussen - Para os pedidos de compra gerados atrav�s de encerramento de medi��o, n�o necessita al�ada de aprova��o >--
IF FUNNAME() == 'CNTA120'
	_MV_XINSREC := SuperGetMV("MV_XINSREC", .F., "", SUBSTR(cFilAnt,1,4))
	IF cFilAnt $(_MV_XINSREC)
		lContinue := .F.
	ENDIF	
ENDIF	
	
//--< 30/07/2014 - Thiago Rasmussen - Quando registro de pre�o, direciona para grupo espec�fico. >--
If lContinue
	IF !Empty(SC1->C1_XCONTPR)
		cGrpAprov := SuperGetMV("MV_XGAPSRP", .F.)
	ELSE
		//--< 03/10/2013 - Thiago Rasmussen - Foi criado o campo "COJ_CODGAP", espec�ficamente para gravar o grupo de aprova��o de PC. >--
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

//--< 03/10/2013 - Thiago Rasmussen - Caso n�o exista nenhum grupo definido para aprova��o do PC, sugerir o grupo de aprova��o >--
//--<                                 definido como default, na tabela de par�metros. >-------------------------------------------
IF Empty(cGrpAprov)
	cGrpAprov := SuperGetMV("MV_PCAPROV", .F.) 
EndIf	
	
If Select(cTab) > 0
	(cTab)->(DbCloseArea())
EndIf

RestArea(aArea)
	
Return cGrpAprov
