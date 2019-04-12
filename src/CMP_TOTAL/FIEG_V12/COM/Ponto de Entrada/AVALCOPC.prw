#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AVALCOPC
Ponto de entrada para deletar o pedido de compra.

@type function
@author TOTVS
@since 06/27/2011
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpL1, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function AVALCOPC()

Local cNumPed	:= ''
Local cProd		:= ''
Local cQtde		:= '' 
Local cContr	:= ''
Local cQuery 	:= ''
Local lPrjCni	:= FindFunction("PRJCNI") .Or. GetRpoRelease("R6")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lPrjCni
	cNumPed := SC7->C7_NUM      
	cProd := SC7->C7_PRODUTO
	cQtde := SC7->C7_QUANT   
	cContr:= SC8->C8_XGCT
	cQuery := ''
	IF !EMPTY(cContr) 
		//--< deleta pedido compra >------------------------
		cArqTrb	:= CriaTrab( nil, .F. )  
		cQuery := "SELECT R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("SC7")+" SC7 "
		cQuery += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
		cQuery += "   AND SC7.C7_NUM = '"+cNumPed+"' "
		cQuery += "   AND SC7.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
		
		While !(cArqTrb)->(Eof())	
			SC7->(dbGoTo((cArqTrb)->RECNO))
			
			COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COI_DTHPED","COI_UPED",.T.,/*cUser*/,"COI_DOCPED") 	//Caio.Santos - FSW - 28/02/2012 - Estorno de log PC
			
			Reclock("SC7",.F.)  
				SC7->(DbDelete())
			SC7->(MsUnlock())
			(cArqTrb)->(dbSkip())
		EndDo
		(cArqTrb)->(dbCloseArea())
		
		//--< desamarra com a cotacao >---------------------
		dbSelectArea("SC8")
		cArqTrb	:= CriaTrab( nil, .F. )  
		cQuery := "SELECT R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("SC8")+" SC8 "
		cQuery += " WHERE SC8.C8_FILIAL = '"+xFilial("SC8")+"' "
		cQuery += "   AND SC8.C8_XGCT = '"+cContr+"' "
		cQuery += "   AND SC8.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
		
		While !(cArqTrb)->(Eof())	
			SC8->(dbGoTo((cArqTrb)->RECNO))
			Reclock("SC8",.F.)  
				SC8->C8_NUMPED := 'XXXXXX'
				SC8->C8_ITEMPED := 'XXXX'    
			SC8->(MsUnlock())
			(cArqTrb)->(dbSkip())
		EndDo
		
		(cArqTrb)->( dbCloseArea() ) 
		
		// desamarra SCR - doc bloqueados
		cArqTrb	:= CriaTrab( nil, .F. )  
		cQuery := "SELECT R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("SCR")+" SCR "
		cQuery += " WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
		cQuery += "   AND SCR.CR_NUM = '"+cNumPed+"' "
		cQuery += "   AND SCR.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
		
		While !(cArqTrb)->(Eof())	
			SCR->(dbGoTo((cArqTrb)->RECNO))
			Reclock("SCR",.F.)  
				SCR->(DbDelete())
			SCR->(MsUnlock())
			(cArqTrb)->(dbSkip())
		EndDo
		(cArqTrb)->( dbCloseArea() )    

		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If SB2->(dbseek((XFilial("SB2")+cProd)))
			Reclock("SB2",.F.)  
				SB2->B2_SALPEDI := (SB2->B2_SALPEDI - cQtde)
			SB2->(MsUnlock())	 
		Endif
	Endif	
EndIf

// Lançamento dos movimentos orçamentarios - GAP091
MsgRun("Atualizando Movimentos do PC "+SC7->C7_NUM,"",{|| U_SICOMA11({3,SC7->C7_NUM,1}) })
		
Return .T.
