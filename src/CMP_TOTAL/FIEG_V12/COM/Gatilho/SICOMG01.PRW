#Include "Protheus.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMG01
Gatilho no campo C1_PRODUTO, para atualizar a finalidade da compra e conta contabil.

@type function
@author CADUBITSKI
@since Jan/2012
@version P12.1.23

@obs Projeto ELO

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpC, retorno o código do Produto em memória.
/*/
/*/================================================================================================================================/*/


User Function SICOMG01()

Local aArea 	:= GetArea()
Local lOracle	:= "ORACLE"$Upper(TCGetDB())
Local cARQPROD	:= Upper(Alltrim(GetMv("MV_ARQPROD"))) 		//Configura se os dados de indicadores de produto serao considerados pela tabela "SB1" ou "SBZ"
Local cFil		:= ""
Local cCod		:= ""
Local cCodWh	:= ""
Local cFinCom	:= ""
Local cDel		:= ""
Local cConta	:= ""
Local cFrom		:= ""
Local cAli 		:= GetNextAlias()							//Carrega o proximo alias disponivel

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Monta as variaveis a serem utilizadas na select conforme o MV_ARQPROD se SB1 ou SBZ >--
cFil		:= "% "+SubStr(cARQPROD,2,2)+"_FILIAL = '"+xFilial(cARQPROD)+"' %"
cCod		:= "% "+SubStr(cARQPROD,2,2)+"_COD %"
cCodWh		:= "% "+SubStr(cARQPROD,2,2)+"_COD = '"+M->C1_PRODUTO+"' %"
cFinCom		:= "% "+SubStr(cARQPROD,2,2)+"_FINCOM %"
cDel		:= "% "+cARQPROD+".D_E_L_E_T_ = ' ' %"
cConta		:= 	Iif(lOracle,"% NVL(ZO_XCONTC,' ') %","% ISNULL(ZO_XCONTC,' ') %")
cFrom		:= "% "+RetSqlName(cARQPROD)+" "+cARQPROD+" %"
		
//Verifica a conta contabil vinculado a finalidade de compra conforme MV_ARQPROD se SB1 ou SBZ
BeginSQL Alias cAli

	SELECT 
		%Exp:cCod%		AS COD,
		%Exp:cFinCom%	AS FINCOM,
		%Exp:cConta%	AS CONTA
		
	FROM %Exp:cFrom%
	
	LEFT OUTER JOIN %table:SZO% SZO ON 
		ZO_FILIAL = %xFilial:SZO%  
		AND ZO_FINCOM = %Exp:cFinCom%
		AND SZO.%NotDel% 
	
	WHERE 
		%Exp:cFil%
		AND %Exp:cCodWh%
		AND %Exp:cDel%

EndSQL

//MemoWrite("\SYSTEM\SICOMG01.SQL",GetLastQuery()[2])		// Gera a query em arquivo para diagnóstico

DbSelectArea((cAli))

If Select((cAli)) > 0
	If !Empty((cAli)->CONTA)
		GDFieldPut("C1_CONTA" , (cAli)->CONTA,  n)
		GDFieldPut("C1_FINCOM", (cAli)->FINCOM, n)
	EndIf
EndIf

(cAli)->(DbCloseArea())

RestArea(aArea)

Return(M->C1_PRODUTO)
