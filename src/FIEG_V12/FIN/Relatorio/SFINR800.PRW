#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SFINR800
Demonstração Historico de Aplicacoes Financeiras Custom.

@type function
@author Edmar Tinti
@since 30/10/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SFINR800()
	Local cPerg := "SFINR800"
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	If SX1->(! DbSeek(cPerg))
		//		PutSX1(cPerg,"01","Data De ?", 	"Data De ?", "Data De ?",  "MV_CH1","D",8,0,0,"G","","",   "","","MV_PAR01","","","","","","","","","","","","","","","","")
		//		PutSX1(cPerg,"02","Data De ?", 	"Data De ?", "Data De ?",  "MV_CH2","D",8,0,0,"G","","",   "","","MV_PAR02","","","","","","","","","","","","","","","","")
		//		PutSX1(cPerg,"03","Banco De ?",	"Banco De ?","Banco De ?", "MV_CH3","C",3,0,1,"G","","SA6","","","MV_PAR03","","","","","","","","","","","","","","","","")
		//		PutSX1(cPerg,"04","Banco De ?",	"Banco De ?","Banco De ?", "MV_CH4","C",3,0,1,"G","","SA6","","","MV_PAR04","","","","","","","","","","","","","","","","")
		Pergunte(cPerg,.T.)
	Endif
	Pergunte(cPerg,.F.)
	ReportDef(cPerg)
Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Definição do Relatorio.

@type function
@author Edmar Tinti
@since 30/10/2015
@version P12.1.23

@param cPerg, Caractere, Nome do Grupo de Perguntas.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef(cPerg)
	Local oReport := Nil
	Local oSecao1 := Nil
	Local nTamNum := 18
	Local cReport := cPerg
	Local cTitulo := "Histórico de Aplicações II"
	Local cDescri := "Revisão 1.0"
	Local bReport := { |oReport|	ReportPrint( oReport, oSecao1 ) }
	Private nJur, nImp, nRes, nCre, dRes, cCRE
	Private aOrd := {"NÚMERO, REVISÃO","BANCO, NÚMERO, REV."}
	oReport:=TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
	oReport:DisableOrientation()         // Não Alterar Orientação de Pagina
	oReport:SetLandScape(.T.)            // Paisagem
	oReport:SetLandScape()               // Modo Horizontal
	oReport:oPage:SetPaperSize(9)        // Pagina A4
	oReport:HideParamPage()              // Não Imprime a Pagina de Parametros
	oReport:SetTotalInLine(.F.)			 // ToTal em Colunas
	oSecao1:=TRSection():New(oReport,"SECAO", {"SEH"}, aOrd)
	TRCell():New( oSecao1, "NUMERO",,"Número","@!",12,Nil,Nil,"LEFT",.F.,"LEFT")
	TRCell():New( oSecao1, "NBANCO",,"Bco Agenc Conta","",22,Nil,Nil,"LEFT",.F.,"LEFT")
	TRCell():New( oSecao1, "MODELO",,"Mod","@!",5,Nil,Nil,"LEFT",.F.,"LEFT")
	TRCell():New( oSecao1, "DT_APL",,"Data Oper.","",12,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_APL",,"Valor Aplic.","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_SDO",,"Saldo Aplic.","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_JUR",,"Juros","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_IMP",,"Impostos","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "DT_RES",,"Data Resg.","",12,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_RES",,"Resgatado","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "VL_CRE",,"Creditado","@E 999,999,999.99",nTamNum,Nil,Nil,"RIGHT",.F.,"RIGHT")
	TRCell():New( oSecao1, "CT_CRE",,"Conta Cred","",10,Nil,Nil,"RIGHT",.F.,"RIGHT")
	oReport:PrintDialog()
Return(Nil)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportPrint
Função que executa o Relatório.

@type function
@author Edmar Tinti
@since 30/10/2015
@version P12.1.23

@param oRep, objeto, Objeto que representa o retlatório.
@param oSec, objeto, Objeto que representa a section.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

//
Static Function ReportPrint(oRep, oSec)
	Local cQry := GetNextAlias()
	//Dados Linha
	oSec:OnPrintLine( {|| SetValues(cQry)})
	oSec:Cell("NUMERO"):SetBlock({|| SEH->(EH_NUMERO+"/"+EH_REVISAO) } )
	oSec:Cell("NBANCO"):SetBlock({|| SEH->(EH_BANCO+" "+EH_AGENCIA+" "+EH_CONTA) } )
	oSec:Cell("MODELO"):SetBlock({|| SEH->EH_TIPO } )
	oSec:Cell("DT_APL"):SetBlock({|| SEH->EH_DATA } )
	oSec:Cell("VL_APL"):SetBlock({|| xMoeda(SEH->EH_VALOR,1,1) } )
	oSec:Cell("VL_SDO"):SetBlock({|| xMoeda(SEH->EH_SALDO,1,1) } )
	oSec:Cell("DT_RES"):SetBlock({|| dRes } )
	oSec:Cell("VL_JUR"):SetBlock({|| nJur } )
	oSec:Cell("VL_IMP"):SetBlock({|| nImp } )
	oSec:Cell("VL_RES"):SetBlock({|| nRes } )
	oSec:Cell("VL_CRE"):SetBlock({|| nCre } )
	oSec:Cell("CT_CRE"):SetBlock({|| cCre } )
	//Totais
	TRFunction():New(oSec:Cell("VL_APL"),,"SUM",,,,, .F. , .T. )
	TRFunction():New(oSec:Cell("VL_SDO"),,"SUM",,,,, .F. , .T. )
	TRFunction():New(oSec:Cell("VL_JUR"),,"SUM",,,,, .F. , .T. )
	TRFunction():New(oSec:Cell("VL_IMP"),,"SUM",,,,, .F. , .T. )
	TRFunction():New(oSec:Cell("VL_RES"),,"SUM",,,,, .F. , .T. )
	TRFunction():New(oSec:Cell("VL_CRE"),,"SUM",,,,, .F. , .T. )
	//Seleciona dados Conforme Parametros
	oSec:BeginQuery()
	If oRep:nOrder == 1
		BeginSql Alias cQry
			SELECT R_E_C_N_O_
			FROM %table:SEH%
			WHERE	EH_FILIAL = %xfilial:SEH% AND %notDel%
			AND EH_APLEMP = 'APL'
			AND EH_DATA >= %Exp:DTOS(mv_par01)% AND EH_DATA <= %Exp:DTOS(mv_par02)%
			AND EH_BANCO >= %Exp:mv_par03% AND EH_BANCO <= %Exp:mv_par04%
			ORDER BY EH_NUMERO, EH_REVISAO
		EndSql
	Else
		BeginSql Alias cQry
			SELECT R_E_C_N_O_
			FROM %table:SEH%
			WHERE	EH_FILIAL = %xfilial:SEH% AND %notDel%
			AND EH_APLEMP = 'APL'
			AND EH_DATA >= %Exp:DTOS(mv_par01)% AND EH_DATA <= %Exp:DTOS(mv_par02)%
			AND EH_BANCO >= %Exp:mv_par03% AND EH_BANCO <= %Exp:mv_par04%
			ORDER BY EH_BANCO, EH_NUMERO, EH_REVISAO
		EndSql
	Endif
	oSec:EndQuery()
	//Imprime
	oSec:Print()
	(cQry)->(DbCloseArea())
Return(Nil)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetValues
Ajusta Valores de Baixas.

@type function
@author Edmar Tinti
@since 30/10/2015
@version P12.1.23

@param cQry, Caracteres, Alias da query executada.

@obs Desenvolvimento FIEG

@history 29/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Indica se a linha irá compôr o relatório.

/*/
/*/================================================================================================================================/*/

Static Function SetValues(cQry)
	Local lRet, cKey
	SEH->(MsGoto((cQry)->R_E_C_N_O_))
	lRet := SEH->(RecNo()) == (cQry)->R_E_C_N_O_
	dRes := SEH->EH_DATARES
	nJur := nImp := nRes := nCre :=  0
	cCre := ""
	If lRet
		cKey := xFilial("SEI")+"APL"+SEH->(EH_NUMERO+EH_REVISAO)+"NOR"
		SEI->(DbSetOrder(2)) //EI_FILIAL, EI_APLEMP, EI_NUMERO, EI_REVISAO, EI_MOTBX, EI_DTDIGIT, EI_TIPODOC, EI_SEQ
		SEI->(DbSeek(cKey))
		While ! SEI->(Eof()) .And. SEI->(EI_FILIAL+EI_APLEMP+EI_NUMERO+EI_REVISAO+EI_MOTBX) == cKey
			dRes := SEI->EI_DTDIGIT
			Do Case
				Case SEI->EI_TIPODOC == "RG" 					//Valor Resgate
				nRes += xMoeda(SEI->EI_VALOR,1,1)
				Case SubStr(SEI->EI_TIPODOC,1,1) == "I"  	//Impostos e Taxas
				nImp += xMoeda(SEI->EI_VALOR,1,1)
				Case SEI->EI_TIPODOC =="JR" 					//Valor Juros
				nJur += xMoeda(SEI->EI_VALOR,1,1)
				Case SEI->EI_TIPODOC == "VL" 					//Valor Credito
				nCre += xMoeda(SEI->EI_VALOR,1,1)
				cCre := SEI->EI_CONTA
			EndCase
			SEI->(DbSkip())
		End
	Endif
Return(lRet)

