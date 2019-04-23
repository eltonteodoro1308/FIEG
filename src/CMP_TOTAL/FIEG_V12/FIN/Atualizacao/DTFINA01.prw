#INCLUDE "PROTHEUS.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao>	 : Funcao de controle de estorno de baixas conforme bordero
<Data>		 : 02/07/2014
<Parametros> : Nenhum
<Retorno>	 : Nenhum
<Processo> : Fieg - Processo de estorno de baixas conforme bordero
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : DoIt Sistemas 
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
User Function DTFINA01( nlOpc, uParam )

	Local uRet
	
	Default nlOpc 	:= 0
	Default uParam	:= Nil
	
	Do Case
	
		Case nlOpc == 1
			uRet := f_Estorna( uParam )
			
		Case nlOpc == 2
			uRet := f_GetDesc( uParam )
			
	EndCase

Return uRet

//---------------------------------------------------
//- Funcao de consulta dos dados a serem estornados -
//---------------------------------------------------
Static Function f_Estorna( clNumBor )

	Local alAreaSE2	:= SE2->( GetArea() )
	Local clPerg		:= "ESTBOR"
	Private cpMsgLog	:= ""
	
	Default clNumBor	:= ""
	
	//-------------------------------
	//- Crio parametro de perguntas -
	//-------------------------------
	f_AjustSX1( clPerg )
	
	if !Empty( clNumBor ) .Or. Pergunte(clPerg, .T.)
	
		clNumBor := MV_PAR01
	
		if !Empty( clNumBor )
			MsgRun("Aguarde o processamento ...", "Aguarde!",{|| f_ProcEst( clNumBor ) })
			
			if !Empty( cpMsgLog )
				Aviso("AtenÁ„o!", cpMsgLog, {"&Fechar"}, 3)
			endif
			
		endif
		
	endif
	
	RestArea( alAreaSE2 )
	
Return
		
Static Function f_ProcEst( clNumBor )

	Local clQuery		:= ""
	Local clAlias		:= GetNextAlias()
	Local clUpdate	:= ""		
			
	clQuery := "SELECT "
	clQuery += "	R_E_C_N_O_ "
	clQuery += "	,E2_PREFIXO "
	clQuery += "	,E2_NUM "
	clQuery += "	,E2_PARCELA "
	clQuery += "	,E2_TIPO "
	clQuery += "	,E2_FORNECE "
	clQuery += "	,E2_LOJA "
		
	clQuery += "FROM "
	clQuery += "	" + RetSQLName("SE2") + " SE2 " 
		
	clQuery += "WHERE "
	clQuery += "	SE2.D_E_L_E_T_ = ' ' "
	clQuery += "	AND E2_FILIAL = '"  + xFilial("SE2") + "' "
	clQuery += "	AND E2_NUMBOR = '" + clNumBor + "' " 
	
	dbUseArea(.f., "TOPCONN", TcGenQry(,, clQuery), clAlias, .F., .F.)
	
	While ( clAlias )->( !Eof() )
	
		SE2->( dbGoTo( ( clAlias )->R_E_C_N_O_ ) )
		
		if ( clAlias )->R_E_C_N_O_ == SE2->( Recno() )
		
			BEGIN TRANSACTION
	
				if f_EstAuto()
				
					//---------------------------------------------------------------------
					//- Se o titulo foi cancelado com sucesso, mantem o cÛdigo do bordero -
					//---------------------------------------------------------------------
					SE2->( dbGoTo( ( clAlias )->R_E_C_N_O_ ) )
			
					if ( clAlias )->R_E_C_N_O_ == SE2->( Recno() )
					
						clUpdate := "UPDATE " + RetSQLName("SEA") 
						clUpdate += " SET D_E_L_E_T_ = ' ' "
						clUpdate += " WHERE D_E_L_E_T_ = '*' "
						clUpdate += " AND EA_FILIAL = '" + SE2->E2_FILIAL + "' "
						clUpdate += " AND EA_FILORIG = '" + SE2->E2_FILORIG + "' "
						clUpdate += " AND EA_NUMBOR = '" + clNumBor + "' "
						clUpdate += " AND EA_PREFIXO = '" + SE2->E2_PREFIXO + "' "
						clUpdate += " AND EA_NUM = '" + SE2->E2_NUM + "' "
						clUpdate += " AND EA_PARCELA = '" + SE2->E2_PARCELA + "' "
						clUpdate += " AND EA_TIPO = '" + SE2->E2_TIPO + "' "
						clUpdate += " AND EA_FORNECE = '" + SE2->E2_FORNECE + "' "
						clUpdate += " AND EA_LOJA = '" + SE2->E2_LOJA + "' "
						
						if RecLock("SE2", .F.)
							SE2->E2_NUMBOR := clNumBor
							SE2->( MsUnLock() )
						endif
						
						if TcSQLExec( clUpdate ) < 0
							cpMsgLog += " Erro na execuÁ„o de update:" + CRLF + TcSQLError() + CRLF + Replicate("-", 30) 
							DisarmTransaction()
						endif
				
					endif
			
				endif
				
			END TRANSACTION
			
		endif
	
		( clAlias )->( dbSkip() )
	EndDo
	( clAlias )->( dbCloseArea() )

Return

//-----------------------------------------------------------
//- Funcao de execucao da execauto de cancelamento de baixa -
//-----------------------------------------------------------
Static Function f_EstAuto()

	Local alVetEs			:= {}
	Local clLog
	Private lMsErroAuto	:= .F.
	
	AADD(alVetEs,{"E2_FILIAL" 	,SE2->E2_FILIAL	, Nil } )
	AADD(alVetEs,{"E2_PREFIXO"	,SE2->E2_PREFIXO	, Nil } )
	AADD(alVetEs,{"E2_NUM"		,SE2->E2_NUM		, Nil } )
	AADD(alVetEs,{"E2_PARCELA"	,SE2->E2_PARCELA	, Nil } )
	AADD(alVetEs,{"E2_TIPO"   	,SE2->E2_TIPO		, Nil } )
	AADD(alVetEs,{"E2_FORNECE"	,SE2->E2_FORNECE	, Nil } )
	AADD(alVetEs,{"E2_LOJA   "	,SE2->E2_LOJA		, Nil } )
	AADD(alVetEs,{"E2_NATUREZ"	,SE2->E2_NATUREZ	, Nil } )
	
	MsExecAuto({|x,y| FINA080(x,y)}, alVetEs, 5)
	
	if lMsErroAuto
		clLog := AllTrim(MemoRead(NomeAutoLog()))
		MemoWrite(NomeAutoLog()," ")
		cpMsgLog += clLog + CRLF + Replicate("-", 30)
	endif
    
Return !lMsErroAuto

Static Function f_AjustSX1( clPerg )
		
	PutSX1(clPerg,"01","Num. BorderÙ ?     ","Num. BorderÙ ?     ","Num. BorderÙ ?     ","mv_ch1","C",6,0,0, "G", "", "", "", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", Nil)	

Return

Static Function f_GetDesc()
Return "Estorna Baixa BorderÙ"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Funcao para controle de versao
<Autor> : Doit Sistemas
<Data> : 02/09/2014
<Parametros> :
<Retorno> : Nil
<Processo> :  
<Rotina> :  
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Obs> :
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/

User Function DTFIN01V() 

Local cRet  := ""                         

cRet := "20140902001" 
        
Return (cRet) 