#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Antes de encerrar a medição, o ponto de entrada é executado para validar informações específicas.

@type function
@author Thiago Rasmussen
@since 01/10/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se todas as validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function CN120VENC()

Local lRet		  := .T.
Local lAcesso     := PARAMIXB[1] // Permissão do Usuário
Local _MV_XINSREC := ""
Local _ALIAS      := GETNEXTALIAS()       

//--< Log das Personalizações >-----------------------------
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
					MsgAlert('Verifique o valor lançado no portal do fornecedor, o mesmo está divergente do valor da medição!' + CRLF + CRLF +;
					         'Valor Portal: R$ ' + ALLTRIM(TRANSFORM((_ALIAS)->VALOR,"@e 999,999,999.99")) + ' || ' +;
					         'Valor Medição Protheus: R$ ' + ALLTRIM(TRANSFORM(CND->CND_VLTOT,"@e 999,999,999.99")),'CN120VENC')
					(_ALIAS)->(DbCloseArea())
					lRet := .F.
				ENDIF
				
				If lRet .and. ALLTRIM((_ALIAS)->STATUS) != 'OK'
					MsgAlert('Medição está bloqueada, a mesma deve ser liberada no SE Suíte!','CN120VENC')
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
		MsgAlert('Usuário não possui permissão para encerrar a medição!','CN120VENC')
		lRet := .F.
	ENDIF
ENDIF
	
RETURN lRet
