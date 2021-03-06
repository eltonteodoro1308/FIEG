#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Antes de encerrar a medi��o, o ponto de entrada � executado para validar informa��es espec�ficas.

@type function
@author Thiago Rasmussen
@since 01/10/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se todas as valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function CN120VENC()

Local lRet		  := .T.
Local lAcesso     := PARAMIXB[1] // Permiss�o do Usu�rio
Local _MV_XINSREC := ""
Local _ALIAS      := GETNEXTALIAS()       

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If FunName() == "CNTA120"
	If lAcesso     
		If CND->CND_ALCAPR <> 'L'
			_MV_XINSREC := SuperGetMV("MV_XINSREC", .F., "", SUBSTR(cFilAnt,1,4))
			If cFilAnt $(_MV_XINSREC)
				
				_SQL := "EXEC LK_SESUITE.SE_SUITE.dbo.SP_VALIDACAO_MEDICAO_PORTAL_FORNECEDOR '" + CND->CND_FILIAL + "', '" + CND->CND_CONTRA + "', '" + CND->CND_FORNECE + "', '" + cValToChar(CND->CND_VLTOT) + "'"
						
				TcQuery _SQL NEW ALIAS (_ALIAS)	                                                   
				dbSelectArea(_ALIAS)
				                                    
				If ALLTRIM((_ALIAS)->STATUS) == 'VALOR'                                  
					MsgAlert('Verifique o valor lan�ado no portal do fornecedor, o mesmo est� divergente do valor da medi��o!' + CRLF + CRLF +;
					         'Valor Portal: R$ ' + ALLTRIM(TRANSFORM((_ALIAS)->VALOR,"@e 999,999,999.99")) + ' || ' +;
					         'Valor Medi��o Protheus: R$ ' + ALLTRIM(TRANSFORM(CND->CND_VLTOT,"@e 999,999,999.99")),'CN120VENC')
					(_ALIAS)->(DbCloseArea())
					lRet := .F.
				ENDIF
				
				If lRet .and. ALLTRIM((_ALIAS)->STATUS) != 'OK'
					MsgAlert('Medi��o est� bloqueada, a mesma deve ser liberada no SE Su�te!','CN120VENC')
					(_ALIAS)->(DbCloseArea())
					lRet := .F.
				ENDIF	

				If lRet
					RecLock("CND",.F.)
						CND->CND_ALCAPR := 'L'
					CND->(MsUnLock())
				EndIf
							
				(_ALIAS)->(DbCloseArea())
			ENDIF	
		ENDIF
	ELSE   
		MsgAlert('Usu�rio n�o possui permiss�o para encerrar a medi��o!','CN120VENC')
		lRet := .F.
	ENDIF
ENDIF
	
RETURN lRet
