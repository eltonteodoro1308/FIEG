#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA1001
Adiciona botoes na tela de PLANILHA ORCAMENTARIA.

@type function
@author TOTVS
@since 01/07/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Array, Op��es da Rotina.
/*/
/*/================================================================================================================================/*/

User Function PCOA1001()

Local _nNivel    := GetNewPar("SI_PCONIV",0)
Local aRetorno   := {}
Local aConsolid  :=	{{ "Exp. Planilha","U_SIPCOA3D",0,4},{ "Imp. Planilha","U_SIPCOA3F",0,4},{ "Relat�rio","U_SIPCOR04(1)",0,4}}  // Consolidacao
Local aIntegr34  :=	{{ "Exp. Planilha","U_SIPCOA15",0,4},{ "Imp. Planilha","U_SIPCOA16",0,4}}  // Import/Export para Excel - Requisito 34
Local aPlanning  :=	{{ "Finaliza Orc" ,"MsgRun('Finalizando Or�amento. Aguarde...',, {|| U_SIPCOA11() } )",0,3},;
					 {"Reabre Orc"    ,"MsgRun('Reabrindo Or�amento. Aguarde...',, {|| U_SIPCOA23() } )",0,3},;
					 {"Aprova Orc"    ,"U_SIPCOA22(1)",0,3},;
					 {"Est. Aprovacao","U_SIPCOA22(2)",0,3},;
					 {"Consulta UO"   ,"MsgRun('Consultando UOs. Aguarde...',, {|| U_SIPCOA13() } )",0,3}} // Controle de aprova��o de or�amento - GAP093

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAdd(aRetorno,{"Consolida��o",aConsolid,0,6})    			// Grupo de Consolidacao
aAdd(aRetorno,{"Simula��o",aIntegr34,0,6})       			// Import/Export dados - Requisito 34

//--< Verifica se usu�rio tem nivel para acessar rotina >--
IF cNivel >= _nNivel
	aAdd(aRetorno,{"Planning",aPlanning,0,6})        		// Controle de aprova��o de or�amento - GAP093
ENDIF

aAdd(aRetorno,{"Gerar DUM", "U_SIPCO17D",0,3 })  			// DUM
aAdd(aRetorno,{"Saldo hist�rico", "U_SIPCOA19",0,3 })		// Saldo Hist�rico

Return(aRetorno)
