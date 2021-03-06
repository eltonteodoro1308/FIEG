#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT140LOK
Ponto de entrada no linhaok da pre-nota.

@type function
@author Carlos Henrique
@since 15/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function MT140LOK()

Local lRet		  := .T.
Local _MV_XNFPARC := SuperGetMV("MV_XNFPARC", .F.)   
Local _aAreaSD1	  := {}
Local I           := 1  

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< 08/11/2016 - Thiago Rasmussen - Caso seja uma pr�-nota relacionada a um pedido de medi��o, n�o permitir a exclus�o >--
If aCols[n][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMMED" })] == '1' .AND. aCols[n][Len(aCols[n])]
	If !(RetCodUsr()$_MV_XNFPARC)
		MSGALERT("Essa pr�-nota trata-se de um pedido gerado atrav�s de uma medi��o, portanto deve ser lan�ada integralmente.","MT140LOK")
		lRet := .F.
	EndIf	
EndIf

//--< 20/02/2018 - Jos� Fernando - Se o pedido for de origem de medi��o, verificar se existe diferen�a entre o total do item do pedido e o total do item da pr�-nota >--
If lRet .and. aCols[n][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMMED" })] == '1'
	_aAreaSD1 := SD1->(GetArea())

	For I := 1 To Len(aCols)
		If aCols[I][Len(aHeader)+1] == .F.    
			_ARRAY := GetAdvFVal("SC7", { "C7_XRESTPG", "C7_TOTAL" }, XFILIAL("SF1")+aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_PEDIDO" })]+aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMPC" })], 1, { "", "" })       
			
			If _ARRAY[1] != "3"
				_C7_TOTAL := _ARRAY[2]
                                                                                          
  				_DIFERENCA := ABS(aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_TOTAL" })] - _C7_TOTAL)
  				
				If _DIFERENCA > 0.00 .AND. _DIFERENCA < 0.03
					MsgAlert("O seguinte item " + aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEM" })] + " vai ter o seu valor total ajustado conforme o pedido de compra." + CRLF + CRLF +;
					         "De R$ " + ALLTRIM(Transform(aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_TOTAL" })],"@e 999,999,999.99")) + " para R$ " + ALLTRIM(Transform(_C7_TOTAL,"@e 999,999,999.99")),"MT140LOK")  
	
					aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_TOTAL" })] := _C7_TOTAL
				EndIf
			EndIf	
		EndIf	
	Next
	
	("SD1")->(dbCloseArea())

	RestArea(_aAreaSD1) 
EndIf

//--< 08/11/2016 - Thiago Rasmussen - Caso seja uma pr�-nota relacionada a um pedido de medi��o, n�o permitir a exclus�o >--
If lRet .and. (INCLUI .OR. ALTERA)
	lRet := U_SIESTA11(.T.)
EndIf  

RETURN lRet
